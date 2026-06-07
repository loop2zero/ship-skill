# ship — Requirement Delivery Orchestrator (Claude Code skill)

A **conductor** skill for [Claude Code](https://claude.com/claude-code): it takes a
single tracked requirement from intake → clarify → design → build → verify → live
demo → review → closeout → status writeback → learning triage, through a **gated
pipeline**. It doesn't do the work itself — it *sequences and gates* other skills
([Superpowers](https://github.com/obra/superpowers), OpenSpec, your tracker
integration) and enforces the human checkpoints.

Product-neutral: you bind three roles (**tracker / deploy-demo / docs target**) to
your own stack at Stage 0. Works Full (team ceremony) or Lite (solo/personal).

## Why

Two failure modes this skill is hardened against, both learned the hard way:

- **Per-task review + unit tests miss cross-cutting & integration bugs.** So the
  pipeline bakes in a **holistic final review by a *different* engine** (Stage 5.0)
  and a **live closed-loop demo** (Stage 4.5) as non-waivable gates — a
  different-engine pass once caught a showstopper + 5 bugs that per-task reviews all
  missed, and 2 more only appeared live.
- **Important steps buried as "tips" get skipped.** Every learning lives in an
  executable stage/gate, not a footnote.

## Install

```bash
git clone https://github.com/loop2zero/ship-skill.git
cd ship-skill && ./install.sh
```

This copies the `ship` and `ship-upgrade` skills into `~/.claude/skills/`
(override with `CLAUDE_SKILLS_DIR`). Then in Claude Code:

```
/ship            # or: /ship <REQ-ID>, "ship this requirement"
```

Upgrade later with `/ship-upgrade`.

## Pipeline (overview)

`0 Preflight` (bind roles + Full/Lite + delegate check) → `1.x` intake/clarify/
conflict/backfill/contract → `2.x` design/mock/team-context/plan → `3.x` baseline/
build/review → `4.0` verification (5-test loop) → `4.5` live demo (closed loop) →
`5.0` holistic different-engine review → `5.1` spec closeout → `5.5` human decision
→ `6.x` branch closeout + status writeback → `7.0` learning triage.

See [`ship/SKILL.md`](ship/SKILL.md) for the full Stage Map and the non-waivable
gates.

## Gates that never get skipped

Stage 0 preflight · 1.1 clarification (human) · 1.2 conflict (human) · 3.1 green
baseline · 4.0 verification · **4.5 live demo before any writeback** (most-violated)
· **5.0 different-engine holistic review** · 5.1 spec closeout · 5.5 human decision
· 7.0 learning triage.

## Relationship

Coordinates, does not replace: **Superpowers** (brainstorming, writing-plans,
subagent-driven-development, TDD, requesting-code-review, verification-before-
completion, finishing-a-development-branch, writing-skills), **OpenSpec** (optional
contract/closeout), and your **tracker** integration.

## License

MIT — see [LICENSE](LICENSE).
