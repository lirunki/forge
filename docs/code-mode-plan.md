# Forge Code Mode — v1 Plan (not yet implemented)

Status: **Design plan. Not implemented. Do not ship until smoke tests pass.**
High-level design lives at the top of `session.md` ("Future feature — Forge code
mode"). This doc is the concrete v1 plan, grounded in the existing agentic
builder loop (2.7.8) so the delta is minimal.

## One-line summary

The LLM writes a short JavaScript program that orchestrates Forge tools
(fetch/filter/aggregate/retry/parallelize); the program runs in a restricted
sandbox with **zero LLM calls in the middle**; then the LLM is called **once
more** with the clean, compact result to assemble the final mini-app. Two LLM
calls total (write program + assemble), deterministic middle.

This is distinct from the agentic builder loop (24 LLM rounds, model decides
each step). Code mode front-loads all decisions into one program; determinism
runs the show.

## Opt-in (mirror the agentic loop exactly)

Per-provider flag, identical shape to `forge_agentic_loop_v1`:

| Agentic loop (exists) | Code mode (new) |
|---|---|
| `LS.agenticLoop = 'forge_agentic_loop_v1'` | `LS.codeMode = 'forge_code_mode_v1'` |
| `getAgenticLoopMap()` / `isAgenticLoopEnabled()` / `setAgenticLoopEnabled()` / `syncAgenticLoopCheckbox()` | `getCodeModeMap()` / `isCodeModeEnabled()` / `setCodeModeEnabled()` / `syncCodeModeCheckbox()` |
| `<input type="checkbox" id="genAgenticLoop">` in Builder capabilities | `<input type="checkbox" id="genCodeMode">` beside it |
| `ai.agenticLoop` / `ai.agenticLoopHint` i18n keys | `ai.codeMode` / `ai.codeModeHint` |
| Drive backup: `agenticLoop: getAgenticLoopMap()` in bundle + restore-merge | same line for `codeMode` |
| `genLog` on toggle | same |

**Default off.** Both flags are independent; a provider can have either, both,
or neither. When both are on, the model picks per-build (see "Per-build
opt-in" below) — code mode is offered as a second tool alongside
`read_loop_md`.

## Per-build opt-in (mirror `read_loop_md`)

Round 1 of `forgeApp` already offers one tool (`read_loop_md`) when
`isAgenticLoopEnabled()`. Code mode adds a second round-1 tool,
`read_code_mode_md`, offered when `isCodeModeEnabled()`:

- Model ignores both → round-1 content flows through the **classic path**
  unchanged (byte-for-byte today's behavior).
- Model calls `read_loop_md` → agentic builder loop (existing).
- Model calls `read_code_mode_md` → CODE_MODE.md returned as tool result;
  code-mode runtime armed; the two-stage flow begins.

The BUILD OPTION paragraph in `forgeApp`'s system prompt gains one sentence
when `isCodeModeEnabled()`:

> BUILD OPTION (code): If this app needs many tool calls, parallel asset/data
> operations, or heavy preprocessing before the final app, call
> `read_code_mode_md` to load the code-mode protocol. You write a short JS
> orchestrator, it runs deterministically (no LLM in the middle), then you get
> one final call to assemble the app. Use it only when the classic one-shot
> or the round-by-round loop are a poor fit.

## The two-stage flow

```
forgeApp(userText)
  ├─ round 1: system + user; tools = [read_code_mode_md] (if flag on)
  ├─ model calls read_code_mode_md → returns CODE_MODE.md
  ├─ round 2: full code-mode toolset registered; tools = [write_program]
  │    model calls write_program({ code, description }) → host stores program
  ├─ STAGE 1 (deterministic, no LLM): runCodeModeProgram(code, { signal })
  │    sandboxed Worker executes the program via async MessageChannel RPC:
  │      forge.tools.run('web_search', {...})   → host runs tool → result
  │      forge.tools.run('web_fetch', {...})     → ...
  │      forge.llm({ messages, ... })            → ONE allowed LLM call? (see open q)
  │      forge.sleep(ms)                         → host setTimeout
  │      forge.print(...args)                    → captured to console
  │      forge.finish({ context, assets })       → ends stage 1
  │    returns { context, assets, printed }
  ├─ STAGE 2 (one LLM call): assembleApp(context, assets, userText)
  │    system = SYSTEM_PROMPT + "Assemble the final app from this processed
  │             context. Return the full JSON payload as specified."
  │    user = userText + "\n\nProcessed context:\n" + JSON.stringify(context)
  │    → extractJson → app (same as classic forgeApp tail)
  └─ app loaded / saved / shared (unchanged runtime contract)
```

**Key invariant:** Stage 1 makes **zero LLM calls** by default. The whole
point is the deterministic middle. `forge.llm` is listed in the API surface
but **gated behind a budget** (default 0; raise via a setting if ever
needed) — see open question.

## Sandbox: extend the `run_js` Worker (option 1)

Forge already has `BUILDER_WORKER_SRC` — a neutered Web Worker (fetch/XHR
undefined, no DOM, 10s terminate, code-size cap, `api.*` allowlist). Code mode
needs the *opposite* of run_js's offline-pure stance: the program must call
back to the host **asynchronously**. Same Worker, add a `MessageChannel`
request/response loop.

### Worker boot neuter list (complete — test each)

```
self.fetch = undefined;
self.XMLHttpRequest = undefined;
self.WebSocket = undefined;
self.importScripts = undefined;     // no further code loading
self.indexedDB = undefined;
self.caches = undefined;            // Cache Storage API
self.BroadcastChannel = undefined;
self.Worker = undefined;            // no nested workers
self.SharedWorker = undefined;
self.ServiceWorker = undefined;
self.SharedArrayBuffer = undefined; // no shared mem / Atomics races
self.Atomics = undefined;
self.navigator = undefined;        // no userAgent / geolocation stub
self.location = { };                // neuter (some libs read location.href)
self.close = undefined;            // can't self-terminate
// postMessage to self.parent is replaced by the MessageChannel (see below)
```

### Async host RPC via MessageChannel

- Host creates `const mc = new MessageChannel();`
- Worker receives `mc.port1`; host keeps `mc.port2`.
- Program calls `await forge.tools.run('web_search', {query})` → worker posts
  `{rpc:'call', id, name, args}` on `port1` → host listens on `port2`,
  executes through **existing risk tiers / confirm / veto** (reuse
  `tools.run` / `agentConfirmTool`), posts `{rpc:'result', id, ok, result,
  error}` back → worker resolves the promise.
- A pending-call map keyed by `id` tracks in-flight RPCs so `terminate` and
  abort can reject them all.

### `forge.*` API surface (narrow, allowlist-by-construction)

```js
forge.tools.run(name, args)   // → Promise<any>; host risk-tiered
forge.tools.list()            // → Promise<{tools}>; read-only catalog
forge.sleep(ms)               // → Promise<void>; host-capped
forge.print(...args)          // → captured to AI-tab console (genLog)
forge.finish({ context, assets })  // → ends stage 1; assets = {path: dataUrl}
// forge.llm({ messages })     // OPTIONAL; budget-gated, default 0 (see open q)
```

`forge.finish` is the only way to end stage 1. A program that returns
without calling `finish` is treated as `finish({})` (empty context). A
program that runs to the wall-clock cap is terminated and the build fails
with a clear error.

### Limits (host-enforced, new where marked)

| Limit | Value | Enforcement |
|---|---|---|
| Code size | 256 KB (reuse `BUILDER_JS_MAX_CODE_BYTES`) | reject before run |
| Wall-clock | 60 s (vs run_js 10 s — code mode does real I/O) | `terminate` + reject pending RPCs |
| **Tool-call count** (new) | 40 | reject the 41st `forge.tools.run` |
| **LLM-call count** (new) | 0 default / configurable | reject over budget |
| Output size (context + assets) | 8 MB | reject `finish` over cap |
| Per-tool-call timeout | 30 s | host-side; counts toward wall-clock |
| Concurrency | `Promise.all` allowed; cap 8 in-flight RPCs | host queue |

### Abort / Stop (reuse existing)

- `abortController.signal` from `forgeApp` is checked each RPC round-trip;
  abort rejects all pending RPCs and terminates the worker.
- The morphed Stop button + `abandonCurrentGeneration()` already abort
  `abortController`; code mode's stage 1 honors it (the worker terminate is
  immediate; the late-arriving stage-2 result is discarded via the existing
  `genToken`/`genAbandoned` gate).
- FGS keep-alive (`aiFgsAcquire`) wraps stage 1 + stage 2 so backgrounding
  doesn't kill network mid-tool-call — same as `forgeApp` today.

## CODE_MODE.md (the protocol asset, mirrors LOOP.md)

A new `www/CODE_MODE.md` ≡ `assets/public/CODE_MODE.md` (synced by
`build_forge.sh`, parity-checked by `forge_check.sh` step 2, inline fallback
constant if fetch fails). Contents: workflow, the `forge.*` API reference,
limits, assembly rules, examples (image pipeline, web-research aggregation,
parallel asset fetch). The model reads it via `read_code_mode_md`.

## Files (estimated)

| File | Change |
|---|---|
| `www/index.html` (+ assets sync) | `LS.codeMode`; get/is/set/sync helpers; checkbox + i18n; BUILD OPTION sentence; `read_code_mode_md` round-1 tool; `write_program` tool; `runCodeModeProgram` (Worker + MessageChannel + neuter list + limits); `assembleApp` (one LLM call → extractJson → app); wire into `forgeApp` (classic fallback when model skips); Drive backup field; `forge_check` neuter-list self-test |
| `www/CODE_MODE.md` (+ assets sync) | the protocol |
| `~/downloads/build_forge.sh` | sync CODE_MODE.md to assets |
| `~/downloads/forge_check.sh` | CODE_MODE.md parity step; neuter-list presence check |
| `android/app/build.gradle`, `package.json`, `docs/api.md`, `docs/tools.md` | version bump + baselines |

No native Java touched. No new dependencies (SES is the v2 upgrade path,
not v1).

## Smoke tests (must pass before enabling by default)

1. Flag OFF → Forge it tic-tac-toe → classic path, identical behavior
   (byte-for-byte; the `read_code_mode_md` tool is never registered).
2. Flag ON → simple prompt → model skips `read_code_mode_md` → classic path
   (no extra LLM call cost).
3. Flag ON → "build an app that searches the web for 3 topics, summarizes
   each, and shows cards" → model calls `read_code_mode_md` → `write_program`
   → stage 1 runs 3 `forge.tools.run('web_search')` (some parallel via
   `Promise.all`) → `finish({context})` → stage 2 assembles → app runs.
4. Infinite loop in program (`while(true){}`) → wall-clock terminates at 60s,
   host UI stays responsive, clear error.
5. `forge.tools.run` over the call-count cap (41) → 41st rejected with clear
   error, program can `finish` or fail.
6. Stop mid-stage-1 → worker terminated, "Stopped.", late stage-2 result
   discarded (genToken gate).
7. Backgrounded mid-stage-1 → FGS keeps network; return → completes.
8. Program calls `forge.llm` with budget 0 → rejected with clear error.
9. Neuter list: program attempts `fetch('...')` → `fetch is not defined`;
   `XMLHttpRequest` → undefined; `importScripts` → undefined. Each verified.
10. `www/CODE_MODE.md` ≡ `assets/public/CODE_MODE.md` (gate step).
11. Both flags on (agentic + code) → model picks one per build; no conflict.
12. Drive backup → restore on second device → codeMode flag survives.

## Open questions (decide before implementation)

1. **`forge.llm` in stage 1.** The design doc lists it in the API surface,
   but the whole point of code mode is "no LLM in the middle." v1: **budget
   0 by default** (the call is registered but always rejected), with a
   future setting to raise it. This keeps the contract honest while leaving
   the door open for hybrid flows.
2. **`finish` vs implicit return.** Require explicit `forge.finish({...})`
   (clear contract) or treat a returned value as the context (ergonomic)?
   v1: require `finish` — matches the agentic loop's explicit `finish` and
   makes the final-result contract unambiguous.
3. **Auto-offer vs explicit.** Always offer `read_code_mode_md` when flag on
   (model decides), or add a "force code mode" toggle? v1: model decides
   (mirrors agentic loop); a force toggle is a v2 nicety.
4. **Reforge in code mode.** v1: **not supported** — Reforge keeps the
   agentic/classic paths. Code-mode Reforge (seed the program with the
   current app as context) is a follow-up.
5. **Code mode + car (AA) mode.** v1: stage 2 system prompt includes
   `CAR_COMPAT_SYSTEM_ADDON` when `wantCar`; stage 1 is car-agnostic (it's
   just tool orchestration). Verify in smoke.
6. **Progress feed.** Stage 1 emits `genProgress` rows per `forge.tools.run`
   / `forge.print` / `finish` (reuse the 2.7.10 feed). Confirm glyphs.
