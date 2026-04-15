# Commercial delivery design for openclaw-lobster-feed-hermes

## Goal

Define the **minimum commercializable delivery design** for this repository without changing the existing migration logic.

This document is intentionally a **design brief**, not the final external solution document. It answers: *what can be sold, to whom, with what deliverables, and on what acceptance boundary*.

---

## Current product baseline

The repository already has the assets required for an entry-level distributable product:

- user-facing installer: `install.sh`
- publishable skill definition: `SKILL.md`
- English product page: `README.md`
- Chinese product page: `README.zh-CN.md`
- CLI demo proof: `docs/demo-cli-invalid-source.md`
- repository metadata for discovery: `.github/settings.yml`

That means the project is already suitable for an **open-source self-serve base offer**. The commercial design should therefore layer packaging, support, and compliance-friendly delivery on top of the existing repo, instead of adding new runtime behavior.

---

## Commercial positioning

### Core value proposition

> Upgrade an existing OpenClaw installation to Hermes with a low-friction, distribution-ready migration path that preserves reusable configuration and finishes with explicit validation.

### Buyer problems this can solve

1. individual power users want a fast migration path
2. small teams want a repeatable onboarding or rollout procedure
3. service providers want a supported migration package instead of ad-hoc terminal work
4. organizations in constrained networks want mirror-friendly delivery and operator guidance

### Positioning boundary

This product should be positioned as:

- **migration bootstrap + delivery package**
- **repeatable operator workflow**
- **supportable onboarding artifact**

It should **not** be positioned as:

- a full managed hosting product
- a guaranteed zero-loss migration for every secret/provider integration
- a compliance certification product by itself

---

## Recommended commercial offer ladder

### Offer A — Open-source self-serve base

**Target user**
- individual developers already using OpenClaw
- technically capable operators who can run a script and review docs

**What is included**
- public repository access
- `install.sh`
- `SKILL.md`
- English and Chinese README
- CLI demo transcript

**Commercial role**
- top-of-funnel acquisition
- proof of usefulness
- adoption driver for later paid migration/support services

**Acceptance boundary**
- installer is publicly runnable
- docs explain defaults, limits, and safety notes
- user can self-verify with `hermes --version` and `hermes doctor`

---

### Offer B — Assisted migration package

**Target user**
- solo founders, small teams, or operators who want faster success and lower migration risk

**What is sold**
- remote onboarding session
- pre-migration checklist
- guided execution of the installer
- post-migration validation review
- written handoff summary

**Suggested deliverables**
- environment intake checklist
- exact migration command used
- migration result summary
- validation checklist (`hermes --version`, `hermes doctor`, selected config checks)
- operator follow-up notes

**Acceptance boundary**
- a named source directory was validated
- migration command was executed with explicit preset
- `hermes doctor` was executed
- skipped/conflicted items were documented honestly

**Why customers pay**
- less operator uncertainty
- faster troubleshooting
- a human-verified handoff instead of only a script

---

### Offer C — Team rollout package

**Target user**
- companies moving multiple OpenClaw workstations or agent environments to Hermes

**What is sold**
- internal rollout runbook
- team-specific distribution entrypoint guidance
- mirror/source policy recommendations
- repeatable support workflow for multiple operators

**Suggested deliverables**
- team rollout SOP
- approved invocation patterns for local / Raw / CDN usage
- environment matrix by team or host type
- support escalation guide
- standard acceptance checklist for each migrated machine

**Acceptance boundary**
- at least one approved runbook exists for repeat use
- each migration path has a reproducible command
- support owners know what counts as success vs. manual follow-up

**Why customers pay**
- converts a one-off script into an internal productized process
- reduces onboarding inconsistency across machines and teams

---

### Offer D — Enterprise network and compliance add-on

**Target user**
- buyers with restricted outbound connectivity, internal mirror requirements, or stricter operator controls

**What is sold**
- private mirror strategy for installer sources
- approved source override policy (`HERMES_INSTALL_URL`, `HERMES_INSTALL_FALLBACK_URLS`)
- security review checklist for `curl | bash` alternatives
- controlled distribution guidance

**Suggested deliverables**
- mirror deployment recommendation
- approved install source list
- script review/sign-off checklist
- secret handling and log redaction guidance

**Acceptance boundary**
- organization has a documented approved source path
- operators know when to avoid public Raw/CDN endpoints
- migration logs and sensitive outputs have handling rules

**Why customers pay**
- turns an otherwise blocked open-source workflow into an adoptable internal process

---

## Packaging model

The cleanest minimum commercial model is:

1. **keep the repo open-source and self-serve**
2. **sell service/support layers around successful migration and rollout**
3. **add enterprise packaging for network and policy constraints**

This is preferable to prematurely closing the installer because:

- the repo itself is a strong distribution channel
- open visibility increases trust for migration-related workflows
- commercial value comes from execution certainty, documentation, support, and internal rollout design

---

## Minimum deliverables per paid engagement

Any paid version should include these artifacts at minimum:

1. **Scope statement** — what source machine(s), what preset, what support boundary
2. **Execution record** — exact command(s) used and operator/environment notes
3. **Validation record** — `hermes --version`, `hermes doctor`, and any agreed follow-up checks
4. **Migration exceptions list** — skipped items, conflicts, non-portable secrets, manual follow-up items
5. **Handoff summary** — what changed, what remains, who owns next actions

Without these, the offer is hard to price, hard to support, and easy to dispute.

---

## Recommended pricing logic

This task does not set final prices, but it does define a pricing structure.

### Pricing dimensions

Price should scale by:

- number of machines or operator environments
- whether execution is self-serve vs. guided vs. done-with-you
- need for restricted-network/private-mirror packaging
- required response time / support SLA
- documentation depth and customization level

### Suggested packaging logic

- **free**: open-source self-serve repo
- **fixed-fee**: single-machine assisted migration
- **project-fee**: multi-machine/team rollout package
- **premium add-on**: enterprise network/compliance packaging

This keeps monetization aligned with real delivery effort rather than charging for the script alone.

---

## Delivery risks and mitigation

### Risk 1 — users overestimate what migration can preserve

**Mitigation**
- keep README and service handoff explicit about non-portable secrets and pairings
- require exception reporting in paid engagements

### Risk 2 — `curl | bash` triggers security objections

**Mitigation**
- offer reviewed commit pinning, internal vendoring, or approved mirror paths
- keep script reviewable and small

### Risk 3 — success criteria are fuzzy

**Mitigation**
- define completion around executed commands and validation evidence
- never call a migration complete without `hermes doctor`

### Risk 4 — China-network or restricted-network installs fail mid-rollout

**Mitigation**
- keep fallback/mirror guidance as a paid packaging option
- document approved source override patterns before rollout

---

## What should happen next

To make this commercially usable, the next document should translate this design into a **customer-facing solution document** with:

- offer summary
- who it is for / not for
- deliverable table
- acceptance table
- engagement flow
- risk disclosure
- optional pricing placeholders

That customer-facing artifact is intentionally left for the next task so this run only completes the design step.

---

## Decision summary

The recommended minimum viable commercial design is:

- keep the repository as the open-source acquisition layer
- commercialize **assisted migration**, **team rollout**, and **enterprise network/compliance packaging**
- sell certainty, documentation, support, and repeatable execution
- define acceptance around executed commands, validation evidence, and written handoff
- avoid promising universal or lossless migration
