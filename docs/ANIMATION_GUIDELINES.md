# Animation & Ticker Guidelines (Flutter)

This project uses a lot of small, always-on micro-interactions (pulses, blinks,
rotations). These are great for UX, but they’re also a common source of
**runtime ticker errors** and **memory/perf leaks** if not handled carefully.

## Core rules

### Dispose everything you create

- **`AnimationController`**: must be disposed in `@override void dispose()`.
- **`PageController` / `ScrollController`**: dispose in `dispose()`.
- **`Timer` / `Timer.periodic`**: cancel in `dispose()`.
- **`StreamSubscription`**: cancel in `dispose()`.

If you start a controller with **`.repeat()`**, it’s still safe as long as the
controller is properly disposed when the widget is removed.

### Don’t create controllers in `build()`

Controllers belong in:
- `initState()` (most common), or
- `didUpdateWidget()` (when the animation depends on updated props)

Creating controllers in `build()` can recreate tickers repeatedly and leak
resources / tank performance.

### Pick the right ticker mixin

- **One** `AnimationController` in the `State` → `SingleTickerProviderStateMixin`
- **Two or more** `AnimationController`s in the same `State` → `TickerProviderStateMixin`

If you use `SingleTickerProviderStateMixin` and later add another controller,
you’ll hit the runtime error:

> “...a SingleTickerProviderStateMixin but multiple tickers were created...”

### Prefer `late final` controllers owned by the `State`

Good pattern:
- Create in `initState()`
- Use in `build()` via `AnimatedBuilder`, `FadeTransition`, `ScaleTransition`, etc.
- Dispose in `dispose()`

Avoid:
- controllers created inside helper methods called from `build()`
- controllers created in callbacks that can run multiple times without disposal

## Repeatable checklist for PRs

- [ ] Any `AnimationController(` has a corresponding `.dispose()` in the same `State`.
- [ ] Any `.repeat()` controller is owned by a widget that disposes it.
- [ ] Any `Timer.periodic` is cancelled in `dispose()`.
- [ ] Any `StreamSubscription` is cancelled in `dispose()`.
- [ ] No controllers are created in `build()`.
- [ ] `SingleTickerProviderStateMixin` is used only when there is exactly one controller.

## Helpful patterns used in this repo

- **`AnimationUtils`**: wrapper helpers for creating/disposing controllers safely:
  see `lib/base/utils/animation_utils.dart`.

