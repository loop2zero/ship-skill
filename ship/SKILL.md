---
name: ship
description: Use when taking a single tracked requirement from intake through delivery — clarify, design, build, verify, demo, review, close out, write status back. Triggers: "/ship", "ship this requirement", "走完整交付流程", "把这个需求做完".
---

# ship — Requirement Delivery Orchestrator

You are the **conductor**, not the band. `ship` sequences existing skills
(Superpowers, OpenSpec, your tracker integration) through a gated pipeline and
enforces the human checkpoints. It owns *order and gates*, not *content* — each
stage's real work is delegated to its specialist skill. This file is the
actionable map.

## Binding profile

`ship` is **product-neutral**. Bind three abstract roles to your stack at Stage 0;
the Stage Map refers only to the roles:

- **tracker** — where requirements live + where status is written back (e.g.
  Linear / Jira / GitHub Issues / a Base). Generic terminal status used below:
  **ready-for-validation**.
- **deploy-demo** — where the Live Demo runs (e.g. Vercel / Fly / a staging box /
  "real local runtime" for CLIs & libraries).
- **docs target** — where team/methodology docs live (e.g. the repo's `docs/`, a
  wiki, a separate docs project).

Swap these per project; keep the gate semantics.

## When to use

- A single requirement is prioritized and ready to refine + deliver.
- Invocations: `/ship`, `/ship <REQ-ID>`, "ship this requirement".

**Not** for: multi-requirement prioritization, cross-req dependency mapping, or
roadmap/portfolio restructuring — decompose those first.

## How to run

Run **Stage 0** first, then create a TodoWrite from the *applicable* Stage Map
rows and walk them in order.

- **GATE** = a checkpoint that must be *satisfied with recorded evidence* before
  advancing; the agent may proceed once it is.
- **HARD-GATE** = a human stop: no auto-advance, an explicit human OK is required.
- On a failed check, don't patch in place — classify the root cause, **flow back**
  to the owning upstream stage, then re-run downstream.

## Stage Map

Stages run **in order**. A `*Conditional*` / ceremony stage that doesn't apply
(per the Stage 0 path) is marked `N/A (+reason)`, which **waives only that stage's
own gate** — the **non-waivable gates always apply**.

| Stage | Action | Delegates to | Gate |
|---|---|---|---|
| **0 Preflight** | Bind roles (tracker / deploy-demo / docs); choose path — **default Full**; **Lite** = solo/personal or no-team-ceremony (drops ceremony **1.3/1.4/2.5/2.7/6.2/6.3**; **2.0 design still runs** even without 1.4; **never drops a non-waivable gate**; needs human OK); mark dropped stages `N/A (+reason)`; verify delegate skills installed — name any missing + the chosen fallback (keep gate semantics, don't fake) | — | GATE: bindings + path + delegate check recorded |
| **1.0 Intake** | Read tracker/context. Don't auto-complete. Produce Intake Summary, Missing/Ambiguous Fields, **Workflow Routing/Coverage** table | tracker skills | — |
| **1.1 Brainstorming** | Clarify intent/constraints/success criteria; output Brainstorming Summary | `superpowers:brainstorming` | HARD-GATE before 1.2 |
| **1.2 Conflict/Overlap Check** | *Lightweight* — surface conflict/overlap/dependency vs in-flight reqs (record search scope) | tracker read | GATE: no blocking conflict; **any overlap/dependency → human proceed/split/merge/defer decision (agent can't self-clear)** |
| **1.3 Tracker Backfill** | Write back **only** user-facing stable info (summary, product behavior, links) — no process logs | tracker skills | GATE before 1.4 |
| **1.4 OpenSpec propose** | *Conditional* (full track): proposal + specs/GWT + design/tasks skeleton | OpenSpec | HARD-GATE: human OK before Stage 2 |
| **2.0 Solution Design** | design doc: API/data/state machine/perms/errors/UI relations | OpenSpec design | — |
| **2.5 HTML Mock** | *Conditional* (UI/Admin/IA → default ON): mock + click-through | mock tooling | GATE: manual point-check w/ evidence (mock path, click-through notes, screens) |
| **2.7 Team Context** | docs target `<slug>/`: requirements, implementation plan, test-cases, mocks | — | — |
| **2.8 Execution Plan** | Derive agent execution plan **from** team context (2.7); on **Lite** (2.7 dropped) derive directly from the spec/design (1.4/2.0) | `superpowers:writing-plans` | — |
| **3.1 Build Baseline** | **Before dispatching any implementer**: run the project's existing tests *its real way* + confirm the actual test/commit commands (hooks) work; record commands + evidence | — | GATE: green baseline (or explicit human waiver) |
| **3.2 Build** | subagent-driven-development + TDD; each subagent reads team context | `superpowers:subagent-driven-development`, `:test-driven-development` | per-task review (3.3) |
| **3.3 Per-task Review** | Between-tasks code review after each task | `superpowers:requesting-code-review` | GATE: Critical=0; Important addressed or human-waived; Minor tracked |
| **3.5 Vertical Slice** | *Conditional* (multi-stream/high-risk/UI main path): minimal real happy path, early-failure gate | — | GATE: human confirms slice evidence (or objective happy-path pass) |
| **4.0 Verification** | **verification-before-completion** + 5-test loop: Unit/E2E/Integration/Security/UI; each type → one outcome **with evidence** | `superpowers:verification-before-completion` | GATE: each type → Passed/Covered/Manual/N/A(+reason); Failed → reflow |
| **4.5 Live Demo (closed loop)** | Deploy/open the **real runtime**; exercise main paths (desktop/mobile/admin). Backend/CLI → **runtime-like** evidence (live API call / DB / log / trace, not just unit output). Capture URL/recording/screens. On failure: classify → owning stage (1.1 clarify · 2.0 design · 2.5 mock · 3.2 build · 4.0 tests), fix, rerun, **repeat** | deploy-demo binding | GATE before final status writeback / branch archive |
| **5.0 Final Review** | **Holistic full-diff review (merge-base→HEAD) by a DIFFERENT engine than the per-task reviewers** — e.g. `codex exec --sandbox read-only` review when primary=Claude (or Claude/external when primary=Codex). Verify findings before acting. (OpenSpec closeout is separate → 5.1) | `superpowers:requesting-code-review` + different-engine review | GATE: reviewer engine recorded; Critical=0; Important addressed or human-waived |
| **5.1 Spec Lifecycle** | *Conditional* (spec delta/accepted drift): **OpenSpec closeout review** + reverse-sync drift + merge spec delta **before** branch merge (archive happens at 6.0) | OpenSpec | GATE: OpenSpec closeout passed |
| **5.5 Human Decision** | merge / keep / discard / handoff | — | HARD-GATE (human only) |
| **6.0 Branch Closeout** | Execute the 5.5 decision: **merge** → land + archive spec (if 5.1 ran) + cleanup worktree; **keep** → preserve branch+worktree; **handoff** → package + transfer; **discard** → delete branch+worktree. Then dev report + evidence links. **NOT terminal — return to ship for 6.2/6.3/7.0** | `superpowers:finishing-a-development-branch` | — |
| **6.2 Tracker Writeback** | Status **per the 5.5 decision**: **merge** → ready-for-validation + prechecked entry + evidence; **keep** → in-progress + next action; **handoff** → transferred; **discard** → abandoned/closed (**NOT** ready-for-validation) | tracker skills | — |
| **6.3 Docs Project** | Merge methodology + interim process docs into the **docs target** (NOT the code repo's change docs) | — | — |
| **7.0 Learning Triage** | Triage. Skillize **only** durable, reusable learnings. Capture "user said no to next step" signals | `superpowers:writing-skills` | GATE: triage done (or explicit "no reusable learning") before final-answering |

## Non-waivable gates

**Every Stage Map gate is mandatory whenever its stage runs** — the list below is the never-skippable critical subset (an N/A stage waives only its *own* gate, with reason; these are never waived):

1. **0 Preflight** — bindings + Full/Lite path + delegate check recorded before any work.
2. **1.1 HARD-GATE** — human confirms clarification before 1.2.
3. **1.2 conflict gate** — any overlap/dependency/conflict → human proceed/split/merge/defer; agent can't self-clear.
4. **3.1 baseline gate** — green baseline + confirmed real test/commit commands before dispatching implementers.
5. **4.0 verification gate** — each of the 5 test types has evidence; required = Passed/Covered/Manual; "actually fixed" with proof.
6. **4.5 pre-writeback gate** — Live Demo / runtime evidence passes *before* any final status writeback / archiving. **The single most-violated gate.**
7. **5.0 review gate** — holistic full-diff review by a **different engine** than the per-task reviewers; reviewer engine recorded; Critical=0; Important addressed or human-waived.
8. **5.1 closeout** — if spec delta, closeout + reverse-sync runs *before* branch merge.
9. **5.5 human decision** — merge/keep/discard/handoff is a human choice, not the agent's.
10. **7.0 triage gate** — learning triage done (or explicit "no reusable learning") before final-answering. Branch-finishing (6.0) is NOT terminal.

## Verification checklist (Stage 4)

Every run, each of the 5 test types gets one outcome — Passed / Covered by
existing / Not applicable (+reason) / Failed (→fix loop) / Manual evidence:

- [ ] **Unit** — test command + output
- [ ] **E2E** — Playwright/browser path + log
- [ ] **Integration** — API/DB/service test output
- [ ] **Security/Permission** — negative/unauth/wrong-role case
- [ ] **UI** — screenshot / visual check / mock comparison

Stage 4 is a **closed loop**: on failure, classify (test gap → 2.7, design → 2.0,
req → 1.1, impl bug → 3.2, drift → implementation Spec Drift) and re-run until all
five pass with evidence.

## Reflow rule

A failed check never gets patched in place at the failing stage. Classify the root
cause, return to the owning stage, fix, then re-run downstream.

## Common pitfalls

- **Writing back ready-for-validation before Live Demo/evidence.** The status must
  hand the reviewer a prechecked, clickable entry — not just a flipped flag.
- **Letting writing-plans author the team docs.** The implementation plan is the
  *upstream* team tech plan; writing-plans derives the agent plan *from* it, never
  the reverse.
- **Polluting the tracker with process logs.** Tracker = user-facing stable info
  only; brainstorming/AI-reasoning/stage detail stays out.
- **Polluting the OpenSpec proposal with implementation/process.** GWT from
  observable actor behavior; no stage-flow logs.
- **Skipping the human decision gate** by auto-merging. Always present
  merge/keep/discard/handoff.
- **Auto-skillizing every run.** Stage 7 is *triage*; only durable, reusable
  patterns become skills.
- **Faking absent skills.** If a delegate skill isn't installed, say so and carry
  the *execution* with a dynamic workflow — but keep the gate's semantics; don't
  pretend it ran. (Detected at Stage 0.)

> **Field-tested:** four learnings were promoted from pitfalls into executable
> stages/gates because pitfalls get read last and skipped — **3.1 green baseline
> before build**, **5.0 holistic different-engine review**, **4.5 live closed-loop**,
> **7.0 not-terminal**. In one run a different-engine holistic review caught a
> showstopper + 5 bugs that per-task reviews missed; 2 more bugs only surfaced in
> the live run; 7.0 was nearly skipped because closeout felt terminal.

## Relationship to other skills

`ship` calls and coordinates — it does **not** replace:

- **Superpowers**: brainstorming, writing-plans, subagent-driven-development,
  test-driven-development, requesting-code-review, verification-before-completion,
  finishing-a-development-branch, writing-skills.
- **OpenSpec**: contract format + closeout review (optional, full track).
- **Tracker integration**: your tracker's read/writeback skill or CLI.

If a delegated skill conflicts with user instructions (CLAUDE.md / AGENTS.md), the user wins.
