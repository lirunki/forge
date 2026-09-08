# Forge code-mode protocol

You are now in **code mode**: instead of emitting the app as one JSON payload
(or building it round-by-round in the agentic loop), you write a short JavaScript
program that orchestrates Forge tools deterministically — **no LLM calls in the
middle** — and the host then gives you one final call to assemble the app from
the program's output. Read this whole document once, then build.

## When to use this mode

You called `read_code_mode_md` because the app benefits from many tool calls,
parallel asset/data operations, or heavy preprocessing before the final app is
assembled. Good fits: search-and-summarize several sources, fetch + filter +
normalize a dataset, generate/filter/select images, aggregate multiple API
calls. Commit to code mode now: do **not** also return the classic JSON payload
or the agentic-loop tools — `write_program` + `finish` is the only way to deliver.

## Workflow

1. **Plan briefly**: what tools to call, in what order, what to preprocess.
2. **Call `write_program`** with a single JavaScript program that:
   - Uses `forge.tools.run('tool_name', { ...args })` to call Forge tools
     deterministically (web_search, web_fetch, get_location, list_contacts,
     etc. — see the catalog via `forge.tools.list()`).
   - May run calls in parallel with `Promise.all([ ... ])`.
   - Preprocesses/summarizes/filters the results into a compact `context`
     object (small enough to hand back to you in the final call).
   - Calls `forge.finish({ context, assets? })` exactly once with the
     processed context. `assets` is an optional map of `{ path: dataUrl }`
     for images/files the final app should embed.
   - May call `forge.print(...)` for debug output (captured to the console).
   - May call `forge.sleep(ms)` when a short wait is needed.
   - Must **not** call `forge.llm` unless the LLM-call budget is > 0 (it is 0
     by default — the call will be rejected with a clear error).
3. The host runs your program in a sandboxed Worker (offline except for the
   `forge.*` bridge; no DOM, no `fetch`, no `XMLHttpRequest`, no `WebSocket`,
   no filesystem). When it calls `forge.finish`, stage 1 ends.
4. You get **one final LLM call** with the original prompt + the processed
   `context` (+ `assets`). Return the full JSON app payload exactly as in
   classic mode (`{ "title", "summary", "html", "message"? }`). The app must
   be a single self-contained HTML string using only `window.ForgeHost` APIs.

## The `forge.*` API (your program's only surface)

- `await forge.tools.run(name, args)` → any tool result. Goes through the
  host's risk tiers (safe auto-runs; sensitive/confirm/danger may prompt the
  user or be denied). Errors throw — wrap in try/catch if you want to adapt.
- `await forge.tools.list()` → `{ tools: [{ name, description, … }] }`.
  Read-only catalog of available tools.
- `await forge.sleep(ms)` → resolves after `ms` (capped by the wall-clock).
- `forge.print(...args)` → captured to the AI-tab console (not the app).
- `await forge.finish({ context, assets? })` → ends stage 1. `context` is any
  JSON-serializable object (keep it compact — it becomes your final-call
  context). `assets` is `{ path: dataUrl }` for images/files to embed in the
  final app (use real `data:` URLs; never `blob:`).
- `await forge.llm({ messages, ... })` → **only if the LLM-call budget > 0**.
  With the default budget 0 this is always rejected. Do not rely on it.

## Limits (host-enforced; configurable in AI settings)

- **Wall-clock**: stage 1 runs up to the configured seconds (default 60s);
  over the cap the worker is terminated and the build fails.
- **Tool-call count**: at most the configured number of `forge.tools.run`
  calls (default 40). The 41st throws.
- **LLM-call budget**: at most the configured number of `forge.llm` calls
  (default 0 = none). Over budget the call is rejected.
- **Output size**: `finish({ context, assets })` total capped (default 8 MB).
- **Per-call timeout**: each `forge.tools.run` call capped (default 30s).
- **Concurrency**: at most the configured in-flight RPCs (default 8).
- **Code size**: program source capped at 256 KB.

If you hit a limit, simplify: fewer tool calls, smaller context, fewer assets,
or preprocess more aggressively in the program.

## Program rules

- The program is plain async JavaScript. Top-level `await` is allowed.
- It runs in a Worker: no `window`, no `document`, no `fetch`, no `XHR`,
  no `WebSocket`, no `importScripts`, no `indexedDB`. Only `forge.*` + the JS
  language core (Math, JSON, Array, Object, String, RegExp, Date, Map, Set,
  Promise, etc.).
- Call `forge.finish` exactly once. If the program returns without calling it,
  an empty context is used (the final call still happens; you'll likely need
  the context, so don't forget).
- Do not put secrets/API keys in the program — it never sees them; the host
  injects credentials into tool calls server-side.
- Keep `context` compact (a few KB is ideal; the host will hand it back to
  you verbatim in the final call). Big `context` wastes your output budget.

## Final call (stage 2)

After stage 1 finishes, you receive one more turn. Its system + user messages
include your original prompt plus:

```
Processed context from your code-mode program:
{ ...your context here... }

Assemble the final app from this processed context. Return the full JSON app
payload exactly as specified (title, summary, html, optional message). The
app must be a single self-contained HTML string using only window.ForgeHost
APIs — same rules as the classic one-shot path.
```

Return the standard payload: `{ "title": "...", "summary": "...", "html":
"...", "message": "..." }`. The host loads it exactly like a classic build.

## Failure recovery

- Tool errors throw inside your program — catch and adapt (retry with
  different args, or skip and continue).
- If the program throws before `finish`, stage 1 fails and the build errors
  out with the program's error message.
- If you cannot complete the app, `finish` with the best partial context so
  the final call can still produce something usable.
- Do not loop forever — the wall-clock will terminate the worker.
