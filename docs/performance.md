# Performance guide

Goals: minimal MethodChannel traffic, zero reflection, small allocations, no UI-thread blocking on native sides.

## Do

- Call `saveBatch` / `updateMany` when writing multiple keys or widgets
- Prefer code-generated `toFlowEntries()` over building maps by hand
- Store remote images once via `FlowWidget.saveImage` and reference by key
- Keep `enableDebugLogging` off in release (forced off when `kReleaseMode`)
- Use timelines for predictable UI changes instead of polling

## Don't

- Call `updateAll` on a high-frequency timer
- Send large binary blobs repeatedly — cache image keys
- Box dynamic JSON trees on every frame; pre-encode with `FlowWidgetValue.json`

## Codec

`FlowWidgetValue` uses a discriminant (`t`) so native switches stay O(1) without Dart runtimeType checks on the hot path.
