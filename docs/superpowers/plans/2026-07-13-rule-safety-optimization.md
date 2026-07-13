# Rule Safety Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preserve fixed proxy behavior while protecting Tailscale MagicDNS, correcting YouTube routing, reducing module side effects, pinning MITM code, and adding automated regression checks.

**Architecture:** A dependency-free shell validator defines the repository invariants and runs locally and in GitHub Actions. Configuration and module changes are minimal line edits, and README documentation mirrors the enforced behavior.

**Tech Stack:** Shadowrocket configuration, POSIX shell, awk, grep, GitHub Actions, Markdown

## Global Constraints

- `100.100.100.100/32` is the only direct exception inside `100.0.0.0/8`.
- All other `100.*` addresses remain proxied.
- Proxy selection remains manual; no `url-test` or fallback policy group may be introduced.
- Existing legacy module URLs remain available.
- The validator must not require third-party packages.

---

### Task 1: Add the failing repository validator

**Files:**
- Create: `scripts/validate-rules.sh`
- Create: `.github/workflows/validate-rules.yml`

**Interfaces:**
- Consumes: both `.conf` files, `youtube-adblock-basic.sgmodule`, and `youtube-adblock-mitm-v2.sgmodule`
- Produces: `scripts/validate-rules.sh`, returning 0 only when all design invariants hold

- [x] **Step 1: Create the validator**

Implement shell assertions for exact rule counts, Quad100-before-100/8 order, Tailscale domains, absence of automatic groups, YouTube-specific-before-generic order, valid policy references, removed broad basic-module domains, and a 40-character SHA in both MITM script URLs.

- [x] **Step 2: Run the validator and confirm RED**

Run:

```bash
sh scripts/validate-rules.sh
```

Expected: non-zero exit with failures for missing Quad100, incorrect YouTube ordering, broad module rules, and unpinned MITM URLs.

- [x] **Step 3: Create the GitHub Actions workflow**

Configure Ubuntu checkout and execute `sh scripts/validate-rules.sh` on pushes and pull requests affecting configuration, modules, README, the validator, or the workflow.

### Task 2: Make configuration and module behavior pass

**Files:**
- Modify: `shadowrocket-cn-direct-overseas-proxy.conf`
- Modify: `shadowrocket-cn-direct-overseas-proxy-simple.conf`
- Modify: `youtube-adblock-basic.sgmodule`
- Modify: `youtube-adblock-mitm-v2.sgmodule`

**Interfaces:**
- Consumes: validator from Task 1
- Produces: configurations and modules satisfying every validator invariant

- [x] **Step 1: Add the Quad100 exception**

Add `IP-CIDR,100.100.100.100/32,DIRECT,no-resolve` immediately before `IP-CIDR,100.0.0.0/8,PROXY,no-resolve` in both configurations.

- [x] **Step 2: Correct YouTube routing priority**

Move `DOMAIN-SUFFIX,youtubei.googleapis.com,YouTube` before `DOMAIN-SUFFIX,googleapis.com,Google` in the full configuration, retaining exactly one copy.

- [x] **Step 3: Remove broad and invalid basic-module rules**

Delete the five rules listed in the design: Google Analytics, the `play.google.com/log` path, App Measurement, Firebase Installations, and Firebase Logging.

- [x] **Step 4: Pin the MITM script**

Replace both `Maasea/sgmodule/master` URLs with `Maasea/sgmodule/bbd30c9318e06e129a71abae1be3812f25f43e3f`.

- [x] **Step 5: Run the validator and confirm GREEN**

Run:

```bash
sh scripts/validate-rules.sh
```

Expected: `All rule checks passed.` and exit code 0.

### Task 3: Document, verify, commit, and publish

**Files:**
- Modify: `README.md`
- Modify: `docs/superpowers/plans/2026-07-13-rule-safety-optimization.md`

**Interfaces:**
- Consumes: passing implementation from Task 2
- Produces: documented behavior, completed plan, and published GitHub commit

- [x] **Step 1: Update README**

Document the Quad100 exception, reduced basic-module scope, HTTPS decryption implications, and the pinned third-party MITM script.

- [x] **Step 2: Run final verification**

Run:

```bash
sh scripts/validate-rules.sh
git diff --check
```

Expected: validator passes and Git reports no whitespace errors.

- [x] **Step 3: Commit only intended files**

Stage the two configs, two modules, README, validator, workflow, design, and completed plan. Commit with message `Optimize rule safety and validation`.

- [x] **Step 4: Publish**

Fetch `origin/main`, verify it is still the branch base, push the feature branch, and fast-forward `main` only if the remote has not changed. Verify the remote commit after push.
