package com.forge.live

import com.google.ai.edge.litertlm.Backend
import com.google.ai.edge.litertlm.Contents
import com.google.ai.edge.litertlm.Conversation
import com.google.ai.edge.litertlm.ConversationConfig
import com.google.ai.edge.litertlm.Content
import com.google.ai.edge.litertlm.Engine
import com.google.ai.edge.litertlm.EngineConfig
import com.google.ai.edge.litertlm.Message
import com.google.ai.edge.litertlm.MessageCallback
import com.google.ai.edge.litertlm.OpenApiTool
import com.google.ai.edge.litertlm.ToolCall
import com.google.ai.edge.litertlm.tool
import com.google.gson.JsonArray
import com.google.gson.JsonElement
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import android.util.Base64
import java.io.File
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledFuture
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

/** LiteRT-LM inference serialized over the selected, reusable native Engine. */
object LiteRtEngineFacade {
    private const val REQUEST_TIMEOUT_SECONDS = 120L
    private const val MAX_OUTPUT_TOKENS = 1024
    // A worker blocked in a native async send must not block the queue forever. The lock below
    // serializes actual access to the shared Engine; timed-out workers release it when they return.
    private val executor = Executors.newCachedThreadPool()
    private val watchdog = Executors.newSingleThreadScheduledExecutor()
    private val requests = ConcurrentHashMap<String, RequestState>()
    private val recentlyFinished = ConcurrentHashMap<String, Long>()
    private val conversationLock = Any()
    @Volatile private var sharedEngine: Engine? = null
    @Volatile private var sharedModelPath: String? = null
    @Volatile private var sharedBackend: String = "CPU"

    private class RequestState(
        val requestId: String,
        val complete: (String?, String?, String, String?) -> Unit,
    ) {
        val finished = AtomicBoolean(false)
        val cleaned = AtomicBoolean(false)
        val asyncDone = CountDownLatch(1)
        @Volatile var resetEngine = false
        @Volatile var engine: Engine? = null
        @Volatile var conversation: Conversation? = null
        @Volatile var backend = "CPU"
        @Volatile var timeout: ScheduledFuture<*>? = null

        fun finish(content: String?, error: String?, toolCallsJson: String? = null) {
            if (finished.compareAndSet(false, true)) {
                timeout?.cancel(false)
                recentlyFinished[requestId] = System.currentTimeMillis()
                complete(content, error, backend, toolCallsJson)
            }
        }
    }

    @JvmStatic
    fun warmModel(
        modelPath: String,
        supportsImageInput: Boolean,
        supportsAudioInput: Boolean,
        supportsToolCalling: Boolean,
        contextTokens: Int,
        cacheBaseDir: String,
        allowCpuFallback: Boolean,
        onProgress: (String) -> Unit,
        complete: (String?, String?) -> Unit,
    ) {
        try {
            executor.execute {
                synchronized(conversationLock) {
                    try {
                        if (sharedEngine != null && sharedModelPath == modelPath) {
                            complete(sharedBackend, null)
                            return@synchronized
                        }
                        closeSharedEngine()
                        onProgress("Loading model on GPU…")
                        var candidate: Engine? = null
                        var backendName = "GPU"
                        try {
                            candidate = Engine(EngineConfig(
                                modelPath = modelPath,
                                backend = Backend.GPU(),
                                visionBackend = if (supportsImageInput) Backend.GPU() else null,
                                audioBackend = if (supportsAudioInput) Backend.CPU() else null,
                                maxNumTokens = contextTokens.takeIf { it > 0 },
                                cacheDir = ensureCacheDir(cacheBaseDir, modelPath),
                            )).also { it.initialize() }
                        } catch (gpuError: Throwable) {
                            try { candidate?.close() } catch (_: Throwable) {}
                            candidate = null
                            if (!allowCpuFallback) throw gpuError
                            onProgress("GPU unavailable; loading model on CPU…")
                            backendName = "CPU fallback"
                            candidate = Engine(EngineConfig(
                                modelPath = modelPath,
                                backend = Backend.CPU(),
                                visionBackend = if (supportsImageInput) Backend.CPU() else null,
                                audioBackend = if (supportsAudioInput) Backend.CPU() else null,
                                maxNumTokens = contextTokens.takeIf { it > 0 },
                                cacheDir = ensureCacheDir(cacheBaseDir, modelPath),
                            )).also { it.initialize() }
                        }
                        sharedEngine = candidate
                        sharedModelPath = modelPath
                        sharedBackend = backendName
                        complete(backendName, null)
                    } catch (error: Throwable) {
                        complete(null, error.message ?: "LiteRT-LM could not load this model")
                    }
                }
            }
        } catch (error: RuntimeException) {
            complete(null, error.message ?: "LiteRT-LM could not queue model loading")
        }
    }

    @JvmStatic
    fun stopModel(complete: (String?) -> Unit) {
        requests.values.toList().forEach { state ->
            state.resetEngine = true
            try { state.conversation?.cancelProcess() } catch (_: Throwable) {}
            state.finish(null, "Offline model deselected")
            LiteRtLmBridgePlugin.rejectInferenceCall(state.requestId, "Offline model deselected")
            state.asyncDone.countDown()
        }
        try {
            executor.execute {
                synchronized(conversationLock) {
                    closeSharedEngine()
                    complete(null)
                }
            }
        } catch (error: RuntimeException) {
            complete(error.message ?: "Could not queue model shutdown")
        }
    }

    private fun closeSharedEngine() {
        try { sharedEngine?.close() } catch (_: Throwable) {}
        sharedEngine = null
        sharedModelPath = null
        sharedBackend = "CPU"
    }

    @JvmStatic
    fun cancel(requestId: String) {
        val state = requests[requestId] ?: return
        state.resetEngine = true
        try { state.conversation?.cancelProcess() } catch (_: Throwable) {}
        state.finish(null, "LiteRT-LM request cancelled")
        LiteRtLmBridgePlugin.rejectInferenceCall(requestId, "LiteRT-LM request cancelled")
        state.asyncDone.countDown()
    }

    @JvmStatic
    fun generate(
        requestId: String,
        modelPath: String,
        systemPrompt: String,
        historyJson: String,
        prompt: String,
        promptRole: String,
        promptContentJson: String,
        toolsJson: String,
        supportsToolCalling: Boolean,
        supportsImageInput: Boolean,
        supportsAudioInput: Boolean,
        contextTokens: Int,
        cacheBaseDir: String,
        allowCpuFallback: Boolean,
        onProgress: (String) -> Unit,
        onDelta: (String) -> Unit,
        complete: (String?, String?, String, String?) -> Unit,
    ) {
        val previousFinish = recentlyFinished[requestId]
        if (previousFinish != null && System.currentTimeMillis() - previousFinish > 60_000L) {
            recentlyFinished.remove(requestId, previousFinish)
        } else if (previousFinish != null) {
            // Reused IDs are safe now: callbacks are correlated by native PluginCall registry and
            // per-request terminal state. The UI's stream subscription is always removed at finish.
            recentlyFinished.remove(requestId, previousFinish)
        }
        val state = RequestState(requestId, complete)
        if (requests.putIfAbsent(requestId, state) != null) {
            complete(null, "A LiteRT-LM request with this ID is already active", "unknown", null)
            return
        }
        state.timeout = watchdog.schedule({
            state.resetEngine = true
            try { state.conversation?.cancelProcess() } catch (_: Throwable) {}
            val message = "LiteRT-LM timed out after ${REQUEST_TIMEOUT_SECONDS}s. The model may be too slow or incompatible with this device."
            state.finish(null, message)
            LiteRtLmBridgePlugin.rejectInferenceCall(requestId, message)
            state.asyncDone.countDown()
        }, REQUEST_TIMEOUT_SECONDS, TimeUnit.SECONDS)
        try {
            executor.execute {
                var engine: Engine? = null
                try {
                    if (state.finished.get()) {
                        requests.remove(requestId, state)
                        return@execute
                    }
                    synchronized(conversationLock) {
                        if (state.finished.get()) {
                            requests.remove(requestId, state)
                            return@execute
                        }
                        var activeEngine = sharedEngine.takeIf { it != null && sharedModelPath == modelPath }
                        if (activeEngine == null) {
                            closeSharedEngine()
                            var initializationError: Throwable? = null
                            onProgress("Initializing GPU backend…")
                            try {
                                val candidate = Engine(EngineConfig(
                                    modelPath = modelPath,
                                    backend = Backend.GPU(),
                                    visionBackend = if (supportsImageInput) Backend.GPU() else null,
                                    audioBackend = if (supportsAudioInput) Backend.CPU() else null,
                                    maxNumTokens = contextTokens.takeIf { it > 0 },
                                    cacheDir = ensureCacheDir(cacheBaseDir, modelPath),
                                ))
                                candidate.initialize()
                                sharedEngine = candidate
                                sharedModelPath = modelPath
                                sharedBackend = "GPU"
                                activeEngine = candidate
                            } catch (error: Throwable) {
                                initializationError = error
                            }
                            if (activeEngine == null) {
                                if (!allowCpuFallback) throw initializationError ?: IllegalStateException("GPU initialization failed and CPU fallback is disabled")
                                if (state.finished.get()) return@execute
                                onProgress("Initializing CPU backend…")
                                val cpu = Engine(EngineConfig(
                                    modelPath = modelPath,
                                    backend = Backend.CPU(),
                                    visionBackend = if (supportsImageInput) Backend.CPU() else null,
                                    audioBackend = if (supportsAudioInput) Backend.CPU() else null,
                                    maxNumTokens = contextTokens.takeIf { it > 0 },
                                    cacheDir = ensureCacheDir(cacheBaseDir, modelPath),
                                ))
                                cpu.initialize()
                                sharedEngine = cpu
                                sharedModelPath = modelPath
                                sharedBackend = "CPU fallback"
                                activeEngine = cpu
                            }
                        }
                        engine = activeEngine
                        state.engine = activeEngine
                        state.backend = sharedBackend
                        if (state.finished.get()) return@execute
                        val effectiveContextTokens = if (contextTokens > 0) contextTokens else 2048
                        val requestMaxOutputTokens = maxOf(128, minOf(MAX_OUTPUT_TOKENS, effectiveContextTokens / 4))
                        onProgress("Model loaded on ${state.backend}; streaming response (up to $requestMaxOutputTokens tokens)…")
                        val parsedHistory = parseHistory(historyJson, supportsToolCalling, supportsImageInput, supportsAudioInput)
                        val tools = parseTools(toolsJson, supportsToolCalling)
                        val config = ConversationConfig(
                            systemInstruction = (systemPrompt.takeIf { it.isNotBlank() }
                                ?: if (tools.isNotEmpty()) "You are a helpful assistant. Use the available functions only when needed." else null)
                                ?.let { Contents.of(it) },
                            initialMessages = parsedHistory,
                            tools = tools,
                            automaticToolCalling = false,
                            maxOutputToken = requestMaxOutputTokens,
                        )
                        val conversation = (activeEngine ?: throw IllegalStateException("LiteRT-LM engine did not initialize"))
                            .createConversation(config)
                        state.conversation = conversation
                        if (state.finished.get()) {
                            state.resetEngine = true
                            cleanup(state, engine, requestId)
                            return@execute
                        }
                        val output = StringBuilder()
                        var toolCallsJson: String? = null
                        var thinkDepth = 0
                        var partialTag = ""
                        val messageChannelsSeen = linkedSetOf<String>()
                        val callback = object : MessageCallback {
                            override fun onMessage(message: Message) {
                                if (state.finished.get()) return
                                val text = message.contents.toString()
                                if (message.channels.isNotEmpty()) {
                                    messageChannelsSeen.addAll(message.channels.keys)
                                    onProgress("Received ${message.channels.keys.joinToString()} channel")
                                }
                                val isQwenThinking = modelPath.contains("qwen3", ignoreCase = true)
                                val channelThink = message.channels["think"].orEmpty()
                                val visible = if (isQwenThinking) filterQwenThinking(text, channelThink, thinkDepth, partialTag)
                                    else VisibleText(text, thinkDepth, partialTag)
                                thinkDepth = visible.thinkDepth
                                partialTag = visible.partialTag
                                if (visible.text.isNotEmpty()) {
                                    output.append(visible.text)
                                    onDelta(visible.text)
                                }
                                if (message.toolCalls.isNotEmpty()) {
                                    val array = JsonArray()
                                    message.toolCalls.forEachIndexed { index, call ->
                                        val item = JsonObject()
                                        item.addProperty("id", "litert_" + System.nanoTime() + "_" + (index + 1))
                                        item.addProperty("type", "function")
                                        val fn = JsonObject()
                                        fn.addProperty("name", call.name)
                                        fn.add("arguments", com.google.gson.Gson().toJsonTree(call.arguments))
                                        item.add("function", fn)
                                        array.add(item)
                                    }
                                    toolCallsJson = array.toString()
                                }
                            }
                            override fun onDone() {
                                if (partialTag.isNotEmpty() && thinkDepth == 0) {
                                    output.append(partialTag)
                                    onDelta(partialTag)
                                }
                                val finalText = output.toString().trim()
                                if (finalText.isEmpty() && toolCallsJson == null) {
                                    state.resetEngine = true
                                    val channelNames = messageChannelsSeen.joinToString().ifEmpty { "none" }
                                    state.finish(null, "LiteRT-LM returned no displayable text (channels: $channelNames). The model may have emitted only a hidden reasoning channel, or the selected model/runtime may be incompatible with this prompt.")
                                } else {
                                    state.finish(output.toString(), null, toolCallsJson)
                                }
                                state.asyncDone.countDown()
                            }
                            override fun onError(error: Throwable) {
                                state.resetEngine = true
                                state.finish(null, error.message ?: "LiteRT-LM streaming failed")
                                state.asyncDone.countDown()
                            }
                        }
                        val promptContents = parseContents(promptContentJson, prompt, supportsImageInput, supportsAudioInput)
                        val finalContents = Contents.of(promptContents)
                        val finalMessage = when (promptRole) {
                            "assistant" -> Message.model(finalContents)
                            "tool" -> Message.tool(finalContents)
                            else -> Message.user(finalContents)
                        }
                        val extraContext = if (modelPath.contains("qwen3", ignoreCase = true)) mapOf<String, Any>("enable_thinking" to false) else emptyMap()
                        conversation.sendMessageAsync(finalMessage, callback, extraContext = extraContext, maxOutputToken = requestMaxOutputTokens)
                        if (!state.asyncDone.await(REQUEST_TIMEOUT_SECONDS, TimeUnit.SECONDS)) {
                            state.resetEngine = true
                            try { conversation.cancelProcess() } catch (_: Throwable) {}
                            val message = "LiteRT-LM streaming callback did not complete before timeout"
                            state.finish(null, message)
                            LiteRtLmBridgePlugin.rejectInferenceCall(requestId, message)
                        }
                        cleanup(state, engine, requestId)
                    }
                } catch (error: Throwable) {
                    state.resetEngine = true
                    val message = error.message ?: "LiteRT-LM could not generate a response"
                    state.finish(null, message)
                    LiteRtLmBridgePlugin.rejectInferenceCall(requestId, message)
                    cleanup(state, engine, requestId)
                    state.asyncDone.countDown()
                } finally {
                    if (state.finished.get()) requests.remove(requestId, state)
                }
            }
        } catch (error: RuntimeException) {
            state.resetEngine = true
            val message = error.message ?: "LiteRT-LM inference executor rejected the request"
            state.finish(null, message)
            LiteRtLmBridgePlugin.rejectInferenceCall(requestId, message)
            requests.remove(requestId, state)
        }
    }

    private fun ensureCacheDir(cacheBaseDir: String, modelPath: String): String {
        val modelKey = File(modelPath).name.hashCode().toUInt().toString(16)
        val base = File(cacheBaseDir)
        if (!base.exists() && !base.mkdirs()) {
            throw IllegalStateException("Could not create LiteRT-LM cache base directory: ${base.absolutePath}")
        }
        val directory = File(base, "litertlm-$modelKey")
        if (!directory.exists() && !directory.mkdirs()) {
            throw IllegalStateException("Could not create LiteRT-LM cache directory: ${directory.absolutePath}")
        }
        if (!directory.isDirectory || !directory.canWrite()) {
            throw IllegalStateException("LiteRT-LM cache directory is not writable: ${directory.absolutePath}")
        }
        return directory.absolutePath
    }

    private fun cleanup(state: RequestState, engine: Engine?, requestId: String) {
        if (!state.cleaned.compareAndSet(false, true)) return
        try { state.conversation?.close() } catch (_: Throwable) {}
        state.conversation = null
        if (engine != null) {
            if (sharedEngine === engine && state.resetEngine) closeSharedEngine()
            else if (sharedEngine !== engine) try { engine.close() } catch (_: Throwable) {}
        }
        requests.remove(requestId, state)
    }

    internal data class VisibleText(val text: String, val thinkDepth: Int, val partialTag: String)

    internal fun filterQwenThinking(text: String, channelThink: String, initialDepth: Int, initialPartial: String): VisibleText {
        // LiteRT-LM can surface Qwen3 thought-channel chunks separately or expose inline
        // <think>…</think> delimiters. Keep thought out of mini-app display and completion content.
        if (channelThink.isNotEmpty() && text.isEmpty()) return VisibleText("", initialDepth, initialPartial)
        val input = initialPartial + text
        val lower = input.lowercase()
        val open = "<think>"
        val close = "</think>"
        val output = StringBuilder()
        var depth = initialDepth
        var cursor = 0
        while (cursor < input.length) {
            if (lower.startsWith(open, cursor)) {
                depth++
                cursor += open.length
                continue
            }
            if (lower.startsWith(close, cursor)) {
                if (depth > 0) depth--
                cursor += close.length
                continue
            }
            if (depth == 0) output.append(input[cursor])
            cursor++
        }
        var keep = 0
        for (tag in listOf(open, close)) {
            for (length in 1 until tag.length) {
                if (lower.endsWith(tag.substring(0, length))) keep = maxOf(keep, length)
            }
        }
        val visible = output.toString()
        val carry = if (keep > 0) input.takeLast(keep) else ""
        return VisibleText(visible, depth, carry)
    }

    private fun parseTools(toolsJson: String, supported: Boolean): List<com.google.ai.edge.litertlm.ToolProvider> {
        val array = JsonParser.parseString(toolsJson).asJsonArray
        if (array.size() > 0 && !supported) throw IllegalArgumentException("The selected LiteRT-LM model is not verified for tool calling")
        return array.map { item ->
            val fn = item.asJsonObject.getAsJsonObject("function")
                ?: throw IllegalArgumentException("Invalid function tool schema")
            val schema = JsonObject()
            schema.add("name", fn.get("name"))
            if (fn.has("description")) schema.add("description", fn.get("description"))
            schema.add("parameters", fn.get("parameters") ?: JsonObject())
            val schemaJson = schema.toString()
            tool(object : OpenApiTool {
                override fun getToolDescriptionJsonString() = schemaJson
                override fun execute(paramsJsonString: String): String =
                    throw IllegalStateException("Tools are executed only by Forge's permission-checked host tool loop")
            })
        }
    }

    private fun parseHistory(historyJson: String, supportsToolCalling: Boolean, supportsImageInput: Boolean, supportsAudioInput: Boolean): List<Message> {
        val history = JsonParser.parseString(historyJson).asJsonArray
        return history.mapNotNull { node ->
            if (!node.isJsonObject) return@mapNotNull null
            val item = node.asJsonObject
            val role = item.get("role")?.asString ?: "user"
            val contentElement = item.get("content")
            val content = if (contentElement == null || contentElement.isJsonNull) ""
                else if (contentElement.isJsonPrimitive) contentElement.asString else contentElement.toString()
            val contents = if (contentElement != null && contentElement.isJsonArray) parseContents(content, "", supportsImageInput, supportsAudioInput) else listOf(Content.Text(content))
            val messageContents = Contents.of(contents)
            when (role) {
                "assistant" -> {
                    val calls = item.getAsJsonArray("tool_calls")
                    if (calls != null && calls.size() > 0) {
                        if (!supportsToolCalling) throw IllegalArgumentException("The selected LiteRT-LM model is not verified for tool-call history")
                        val parsed = calls.map { callNode ->
                            val fn = callNode.asJsonObject.getAsJsonObject("function")
                            val args = fn.get("arguments")
                            val obj = if (args != null && args.isJsonObject) args.asJsonObject
                                else JsonParser.parseString(args?.asString ?: "{}").asJsonObject
                            ToolCall(fn.get("name").asString, obj.toMap())
                        }
                        Message.model(messageContents, parsed)
                    } else Message.model(messageContents)
                }
                "tool", "function" -> {
                    if (!supportsToolCalling) throw IllegalArgumentException("The selected LiteRT-LM model is not verified for tool responses")
                    Message.tool(messageContents)
                }
                else -> Message.user(messageContents)
            }
        }
    }

    private fun parseContents(contentJson: String, fallbackText: String, supportsImageInput: Boolean, supportsAudioInput: Boolean): List<Content> {
        if (contentJson.isBlank()) return listOf(Content.Text(fallbackText))
        val root = JsonParser.parseString(contentJson)
        if (!root.isJsonArray) return listOf(Content.Text(root.asString))
        val parts = root.asJsonArray.mapNotNull { item ->
            if (item.isJsonPrimitive) return@mapNotNull Content.Text(item.asString)
            if (!item.isJsonObject) return@mapNotNull null
            val obj = item.asJsonObject
            val type = obj.get("type")?.asString ?: ""
            when {
                type == "text" -> Content.Text(obj.get("text")?.asString.orEmpty())
                type == "image_url" || type == "input_image" -> {
                    if (!supportsImageInput) throw IllegalArgumentException("The selected LiteRT-LM model does not support image input")
                    val url = if (obj.has("image_url") && obj.get("image_url").isJsonObject) obj.getAsJsonObject("image_url").get("url")?.asString.orEmpty() else obj.get("url")?.asString.orEmpty()
                    Content.ImageBytes(decodeDataUrl(url, setOf("image/jpeg", "image/png"), 5 * 1024 * 1024))
                }
                type == "input_audio" -> {
                    if (!supportsAudioInput) throw IllegalArgumentException("The selected LiteRT-LM model does not support audio input")
                    val audio = obj.getAsJsonObject("input_audio") ?: throw IllegalArgumentException("Audio input payload is missing")
                    if (!audio.has("format") || audio.get("format").asString.lowercase() != "wav") throw IllegalArgumentException("Offline audio input currently requires WAV format")
                    val bytes = Base64.decode(audio.get("data")?.asString.orEmpty(), Base64.DEFAULT)
                    if (bytes.size < 44 || bytes.size > 25 * 1024 * 1024 || bytes[0] != 'R'.code.toByte() || bytes[1] != 'I'.code.toByte() || bytes[2] != 'F'.code.toByte() || bytes[3] != 'F'.code.toByte() || bytes[8] != 'W'.code.toByte() || bytes[9] != 'A'.code.toByte() || bytes[10] != 'V'.code.toByte() || bytes[11] != 'E'.code.toByte()) throw IllegalArgumentException("Audio input must be a valid WAV file (max 25 MB)")
                    val wav = java.nio.ByteBuffer.wrap(bytes).order(java.nio.ByteOrder.LITTLE_ENDIAN)
                    if (wav.getShort(20).toInt() != 1 || wav.getShort(22).toInt() != 1 || wav.getInt(24) != 16000 || wav.getShort(34).toInt() != 16) throw IllegalArgumentException("Offline audio input requires mono, 16 kHz, 16-bit PCM WAV audio")
                    Content.AudioBytes(bytes)
                }
                else -> throw IllegalArgumentException("This LiteRT-LM model cannot process the attached file type")
            }
        }
        val text = parts.filterIsInstance<Content.Text>()
        val media = parts.filterNot { it is Content.Text }
        if (media.any { it is Content.ImageBytes } && media.any { it is Content.AudioBytes }) throw IllegalArgumentException("Offline multimodal models do not support combining image and audio in one turn")
        if (media.any { it is Content.ImageBytes } && media.count { it is Content.ImageBytes } > 1) throw IllegalArgumentException("Qwen3.5 VL supports one image per turn")
        return (text + media).ifEmpty { listOf(Content.Text(fallbackText)) }
    }

    private fun decodeDataUrl(value: String, allowedMime: Set<String>, maxBytes: Int): ByteArray {
        val match = Regex("^data:([^;,]+);base64,(.+)$", RegexOption.IGNORE_CASE).matchEntire(value)
            ?: throw IllegalArgumentException("Offline vision requires an inline PNG or JPEG image")
        if (match.groupValues[1].lowercase() !in allowedMime) throw IllegalArgumentException("Offline vision accepts PNG or JPEG images only")
        val bytes = Base64.decode(match.groupValues[2], Base64.DEFAULT)
        if (bytes.isEmpty() || bytes.size > maxBytes) throw IllegalArgumentException("Image attachment is empty or exceeds 5 MB")
        return bytes
    }

    private fun JsonObject.toMap(): Map<String, Any?> = entrySet().associate { it.key to it.value.toNativeValue() }

    private fun JsonElement.toNativeValue(): Any? = when {
        isJsonNull -> null
        isJsonObject -> asJsonObject.toMap()
        isJsonArray -> asJsonArray.map { it.toNativeValue() }
        asJsonPrimitive.isBoolean -> asBoolean
        asJsonPrimitive.isNumber -> asNumber
        else -> asString
    }
}
