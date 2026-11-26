# Elm Practice Sandbox

A minimal Elm 0.19.1 project for experimenting with browser lifecycle,
conditional subscriptions, ports, frontend state modeling and rendering
performance.

## Run it

Prerequisites: Node.js 18 or newer.

```bash
npm install
npm start
```

Open <http://localhost:8000>, wait for a few refreshes, and then switch to a
different browser tab. The subscription should stop while the page is hidden.

For an optimized build:

```bash
npm run build:optimized
npm run serve
```

## Project shape

```text
src/Main.elm       Elm model, update, view and conditional subscription
public/index.js    Page Visibility API adapter
public/index.html  Host page
public/styles.css  Minimal presentation
PRACTICE.md        Progressive exercises and acceptance criteria
```

The JavaScript boundary deliberately owns only browser-specific lifecycle
behavior. Elm owns application state and decides whether the timer subscription
exists.

The starting application is complete; `PRACTICE.md` contains bounded changes
that let you evolve it without first repairing the scaffold.
