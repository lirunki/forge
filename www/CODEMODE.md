# Code mode: `run_program` (enabled)

`run_program({ code, description? })` is available alongside the other workspace
tools. It runs a sandboxed JS script that **orchestrates** workspace tools
deterministically — **no LLM in the middle**. Inside the script,
`forge.tools.run(name, args)` calls any other workspace tool (`fs_write`,
`gen_image`, `web_search`, … — see `forge.tools.list()`), `forge.sleep(ms)`,
`forge.print(...)`, and `forge.finish(result)` ends the script and feeds
`result` back to you as the `run_program` tool result.

## The one rule: use `run_program` to orchestrate, not to write content you already have

`run_program` is for **batching / looping / branching on tool results** — many
tool calls in one turn, a loop over a dataset, or a value you can only know
after calling a tool. It is **not** a wrapper for producing files whose content
you already know how to write.

- **Static files you can write now → `fs_write` directly.** An `index.html`, a
  CSS file, a JS module, a data file you've already computed — call `fs_write`.
  Never wrap a single known-content write in `run_program`.
- **A single tool call → call the tool directly.** One `gen_image` or one
  `web_fetch` is a direct tool call; don't spin up a script for one call.
- **Reach for `run_program` when** you'd otherwise emit the same tool call many
  times, or need to branch on a tool's output before the next step.

If you're about to write a `run_program` whose body is mostly `fs_write(...)`
with the content inlined in the script, stop — those are direct `fs_write`
calls. Put the orchestration (loops, parallel calls, result aggregation) in
`run_program` and the content (the actual HTML/CSS/JS text) in `fs_write`.

### Worked example: an app with 10 generated images

Don't write one `run_program` that both generates the images *and* writes
`index.html`. Split the concerns:

1. **`fs_write` `index.html` directly**, referencing the image paths the app
   will use. `gen_image` writes `images/gen_1.png`, `images/gen_2.png`, … in the
   order its calls finish, so a batch of 10 produces `images/gen_1.png` …
   `images/gen_10.png`. Reference them up front:
   ```html
   <img src="@asset('images/gen_1.png')" alt="1">
   …
   <img src="@asset('images/gen_10.png')" alt="10">
   ```
2. **Generate the images** — either as 10 direct `gen_image` calls, or, to do
   them in one turn, **one** `run_program` that loops
   `forge.tools.run('gen_image', …)` in parallel and `forge.finish()`es with the
   list of paths it actually produced:
   ```js
   const prompts = [ /* …10 prompts… */ ];
   const paths = await Promise.all(
     prompts.map(p => forge.tools.run('gen_image', { prompt: p }).then(r => r.path))
   );
   forge.finish({ paths });
   ```
3. If a produced path differs from what `index.html` references, `fs_edit`
   `index.html` to swap the placeholder for the real path. (With `gen_image`'s
   numbered paths this is usually unnecessary.)

The point: `index.html` was always a direct `fs_write`; `run_program` earned its
place only by batching the 10 image generations into one turn.

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
