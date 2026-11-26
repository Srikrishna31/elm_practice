# Practice path

Work through these in order or pick the architectural concern you want to
explore. Each change is small enough for one focused session.

## 1. Inspect the effect boundary (5 minutes)

Trace `ManualRefresh` through `Task.perform RefreshTick Time.now`. Explain why
Elm requests the current time as an effect instead of calling a synchronous
clock function from `update`.

Acceptance criteria:

- **Refresh now** increments the counter only when the page is visible.
- No current time is stored or calculated in JavaScript.

## 2. Frontend state design (10–15 minutes)

Replace the Boolean visibility state with:

```elm
type PollingState
    = Running
    | Paused PauseReason

type PauseReason
    = PageHidden
    | UserRequested
```

Add a Pause/Resume button. Derive the timer subscription from `PollingState`.
Decide what should happen if the user pauses, hides the tab, and then returns.

## 3. Performance investigation (10 minutes)

Add 500 result rows and use browser profiling to compare:

- a normal list view;
- `Html.Lazy.lazy` around the result subtree;
- `Html.Keyed.ul` with stable IDs.

Do not retain an optimization unless the profile shows a meaningful reduction
in DOM work.

## 4. Micro-frontend contract (15–20 minutes)

Replace the Boolean visibility port payload with a versioned command:

```json
{
  "version": 1,
  "type": "visibility-changed",
  "instanceId": "status-widget-1",
  "payload": { "visible": true }
}
```

Decode it in Elm, reject unsupported versions, and ignore messages addressed
to another instance. Keep one incoming port rather than adding a port for each
host command.

## 5. Failure-mode experiment (5 minutes)

Comment out `disposeElmPracticeApp`'s final `send(false)`. Remove the widget's
DOM node and inspect whether its Elm timer continues. Restore cleanup and note
the distinction between removing a DOM node and terminating application work.
