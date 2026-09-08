# Code mode: `run_program` (enabled)

`run_program({ code, description? })` is available alongside the other workspace
tools. It runs a sandboxed JS script that batches workspace tools deterministically
— **no LLM in the middle**: `forge.tools.run(name, args)` calls any other workspace
tool (`fs_write`, `gen_image`, `web_search`, … — see `forge.tools.list()`),
`forge.sleep(ms)`, `forge.print(...)`, and `forge.finish(result)` ends the script
with a value fed back to you as the `run_program` tool result.

## When to use it

Use `run_program` to parallelize many tool calls in one turn (`Promise.all([...])`),
then continue with more tools, another `run_program`, or `finish` — whichever
fits. It's naturally hybrid: mix scripts, direct tool calls, and prose as needed.
Good fits: fetch several URLs in parallel, generate/filter/select images, aggregate
multiple tool calls, preprocess a dataset before the final app.

## The `forge.*` API (the script's only surface)

- `await forge.tools.run(name, args)` → any workspace tool result. Errors throw —
  wrap in try/catch if you want to adapt.
- `await forge.tools.list()` → `{ tools: [{ name, description, … }] }`.
- `await forge.sleep(ms)` → resolves after `ms` (capped by the wall-clock).
- `forge.print(...args)` → captured to the AI-tab console (not the app).
- `await forge.finish(result)` → ends the script with `result` (any compact
  JSON-serializable value). This is the only way to end the script; the value is
  fed back to you as the `run_program` tool result.

The script **cannot** call `run_program` (no nesting) or the workspace `finish` —
return a value via `forge.finish(result)` instead.

## Hard constraint

Every script must call `forge.finish(result)` exactly once. A script that returns
without calling it gets an empty `{ __implicit: true }` result. A script that
throws before `finish` fails — the error is fed back to you and you can retry
with a corrected script.

## Limits (host-enforced; the actual values are appended below)

- **Wall-clock per script**: over the cap the worker is terminated.
- **Tool-call count per script**: at most the configured `forge.tools.run` calls.
- **Concurrency**: at most the configured in-flight RPCs (queued, not rejected).
- **Output size**: `forge.finish(result)` total capped — keep `result` compact.
- **Per-call timeout**: each `forge.tools.run` call capped.
- **Code size**: program source capped at 256 KB.

If you hit a limit, simplify: fewer tool calls, a smaller result, or preprocess
more aggressively in the script.

## `run_program` vs `run_js`

`run_js` stays for **offline pure compute** over workspace files (`api.readText`,
`api.readBase64`, `api.write`, `api.list`, `api.print` — no network, no tool
calls, 10s limit). Use `run_program` when you need to **call tools** (including
network-via-tools) or parallelize many calls in one turn.
