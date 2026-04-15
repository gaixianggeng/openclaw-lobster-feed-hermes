# Commercial solution offering for openclaw-lobster-feed-hermes

## Overview

`openclaw-lobster-feed-hermes` is a distribution-ready migration package for teams or operators who need to move an existing OpenClaw environment to Hermes with lower rollout friction and explicit validation.

This solution turns the repository from a useful installer into a **customer-facing migration offer**:

- a repeatable migration entrypoint
- clear operator defaults
- supportable delivery artifacts
- acceptance criteria that can be reviewed after each run

The commercial value is not the script alone. The value is the combination of **installation path + migration workflow + validation evidence + handoff discipline**.

---

## Who this is for

### Good fit

This solution is a good fit for:

1. individual operators who already run OpenClaw and want a faster move to Hermes
2. small teams that need a repeatable internal migration workflow
3. service providers who want a supportable migration package instead of ad-hoc terminal work
4. organizations that need mirror-friendly or policy-aware delivery in constrained networks

### Not a fit

This solution is **not** a good fit when:

1. the source machine does not actually have a usable OpenClaw directory
2. the buyer expects every secret, provider integration, or pairing to migrate losslessly
3. the buyer needs a fully managed hosting product rather than a migration package
4. the buyer requires a compliance certification product by itself

---

## Core offer summary

### What the solution provides

The solution is built around these repository assets:

- installer entrypoint: `install.sh`
- Hermes skill definition: `SKILL.md`
- product documentation: `README.md`, `README.zh-CN.md`
- demo evidence: `docs/demo-cli-invalid-source.md`
- design baseline: `docs/commercial-delivery-design.md`

### What the delivery service adds

The commercial layer adds:

- environment intake and migration planning
- an approved execution pattern for local / Raw / CDN / mirror usage
- guided or standardized operator execution
- validation evidence collection
- exception reporting and handoff documentation

---

## Offer ladder

| Offer | Target buyer | Included deliverables | Acceptance boundary |
|---|---|---|---|
| Self-serve base | technical operators | public repo, installer, skill, README, demo | user can run the installer and self-check with `hermes --version` and `hermes doctor` |
| Assisted migration | individual or small-team buyer | intake checklist, guided execution, validation review, handoff summary | source directory confirmed, migration executed, `hermes doctor` executed, exceptions documented |
| Team rollout package | multi-machine or multi-operator team | rollout SOP, approved invocation patterns, support/escalation guide, acceptance checklist | reproducible command path exists for each rollout case and support ownership is clear |
| Enterprise network add-on | restricted-network or policy-heavy org | mirror strategy, approved source list, security review checklist, log handling guidance | organization has a documented approved install path and operator controls |

---

## Deliverables

### Standard deliverable set

Every paid engagement should produce these artifacts:

| Deliverable | Purpose | Minimum content |
|---|---|---|
| Scope statement | defines what is being migrated | source host or environment, preset, support boundary, exclusions |
| Execution record | shows what was actually run | exact command(s), operator notes, source directory used |
| Validation record | proves post-run checks happened | `hermes --version`, `hermes doctor`, and agreed follow-up checks |
| Migration exceptions list | documents what did not migrate cleanly | skipped items, conflicts, manual follow-up items, non-portable secrets |
| Handoff summary | closes the engagement with ownership clarity | what changed, remaining actions, next owner |

### Optional packaging deliverables

Depending on the tier, the package can also include:

- onboarding session notes
- team rollout SOP
- approved mirror/source policy
- support escalation matrix
- internal operator checklist
- pricing appendix or statement of work

---

## Acceptance criteria

A migration engagement should not be marked complete unless all applicable acceptance checks are satisfied.

| Area | Acceptance check |
|---|---|
| Source readiness | a real OpenClaw source directory was identified and recorded |
| Execution | the migration command was actually executed with an explicit preset |
| Validation | `hermes doctor` was actually executed |
| Evidence | exact commands and result summaries were captured in the delivery record |
| Exceptions | skipped/conflicted items were reported honestly |
| Handoff | next actions and ownership were written down |

### Minimum execution standard

A standard delivery should preserve these defaults unless the customer explicitly approves a different scope:

```bash
hermes claw migrate --source "$OPENCLAW_DIR" --preset full --yes
hermes doctor
```

The commercial package should **not** default to `--overwrite` unless the operator or buyer explicitly authorizes replacement of existing Hermes data.

---

## Engagement flow

### 1. Intake

Collect:

- target machine or environment
- source directory location
- whether the buyer wants self-serve, assisted, or team rollout support
- whether restricted-network or internal mirror constraints exist
- whether overwrite behavior is allowed

### 2. Pre-migration review

Confirm:

- the source directory exists
- required prerequisites such as `git` and `curl` exist
- the chosen entrypoint is acceptable: local script, Raw, CDN, or approved mirror
- the buyer understands the known migration limits

### 3. Execution

Run the approved command path and capture:

- exact installer invocation
- actual migration command
- any warnings, conflicts, or manual steps

### 4. Validation

Run and record:

```bash
hermes --version
hermes doctor
```

Optionally add follow-up checks such as:

```bash
hermes model
hermes config path
```

### 5. Handoff

Deliver:

- execution record
- validation record
- migration exceptions list
- next-step guidance

---

## Risk disclosure

### 1. Not every secret is portable

Some OpenClaw secret sources, especially file-based or exec-based references, may require manual follow-up.

### 2. Pairing-style integrations may not migrate cleanly

Messaging or pairing relationships such as WhatsApp-style flows should be treated as potential manual work.

### 3. `curl | bash` may be unacceptable in some environments

For security-sensitive buyers, the offer should allow reviewed commit pinning, vendored scripts, or approved internal mirrors.

### 4. Restricted-network installs may need a mirror-first plan

If public GitHub Raw or CDN endpoints are not reliable or permitted, the engagement should define an approved source override path before rollout.

### 5. Success must be tied to evidence, not assumptions

The engagement should never claim success solely because the installer ran. Completion requires execution evidence, validation output, and exception reporting.

---

## Optional pricing placeholders

This document does not set final commercial pricing, but it supports a reusable quoting structure.

| Package | Pricing placeholder |
|---|---|
| Self-serve base | free / open-source |
| Assisted migration | fixed fee per machine or environment |
| Team rollout package | project fee based on scope and machine count |
| Enterprise network add-on | premium add-on for mirror, policy, and review work |

### Pricing drivers

Final pricing can scale with:

- number of machines or environments
- support level: self-serve vs. guided vs. done-with-you
- required response time or SLA
- documentation depth and customization
- network/policy complexity

---

## Recommended customer-facing positioning

Use this short positioning statement in proposals, landing pages, or outbound material:

> `openclaw-lobster-feed-hermes` is a low-friction migration solution for moving existing OpenClaw environments to Hermes with explicit defaults, validation steps, and supportable handoff artifacts.

Short version:

> Move from OpenClaw to Hermes faster, with clearer rollout defaults and auditable validation.

---

## Decision

The recommended commercial packaging model is:

1. keep the repository open as the self-serve acquisition layer
2. sell assisted migration and rollout support as the first paid offer
3. add enterprise network/policy packaging where public installer paths are not sufficient
4. define completion around executed commands, validation evidence, and written handoff

This keeps the commercial offer aligned with real delivery value while preserving the repository as a trustworthy distribution surface.
