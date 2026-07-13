# Connectivity Rule Shadow Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Android connectivity checks use `DIRECT`, protect the ordering with an automated shadow detector, and verify behavior in Shadowrocket.

**Architecture:** Extend the existing dependency-free validator to detect cross-policy domain-suffix shadowing. Reorder one rule in the full configuration, publish the tested commit, then use Shadowrocket's UI or logs for three policy-match probes.

**Tech Stack:** Shadowrocket configuration, POSIX shell/awk, GitHub Actions, Computer Use

## Global Constraints

- Do not change proxy nodes or unrelated rules.
- `connectivitycheck.gstatic.com` must match `DIRECT` before generic `gstatic.com` matches `Google`.
- `youtubei.googleapis.com` must remain `YouTube`.
- Preserve Tailscale and manual fixed-proxy behavior.
- Restore any temporary Shadowrocket UI/config state after live testing.

---

### Task 1: Add failing shadow detection

**Files:**
- Modify: `scripts/validate-rules.sh`

**Interfaces:**
- Consumes: ordered `DOMAIN-SUFFIX` rules from the full configuration
- Produces: a validation failure whenever an earlier parent suffix shadows a later child suffix assigned to a different policy

- [x] **Step 1: Add the generic shadow detector**

Use `awk` to store earlier suffix/policy/line values and report a failure when a later suffix equals or ends with `.` plus an earlier suffix and the policies differ.

- [x] **Step 2: Run RED verification**

Run `sh scripts/validate-rules.sh`. Expected: non-zero exit identifying `gstatic.com -> Google` shadowing `connectivitycheck.gstatic.com -> DIRECT`.

### Task 2: Reorder and verify the rule

**Files:**
- Modify: `shadowrocket-cn-direct-overseas-proxy.conf`

**Interfaces:**
- Consumes: failing detector from Task 1
- Produces: specific connectivity-check rule before generic Google static rule

- [x] **Step 1: Move the rule**

Move the exact `connectivitycheck.gstatic.com,DIRECT` line before `gstatic.com,Google` and remove its old occurrence.

- [x] **Step 2: Run GREEN verification**

Run the full validator and semantic probes for connectivity-check, ordinary gstatic, YouTube API, Quad100, and 100/8.

- [x] **Step 3: Commit and publish**

Commit the validator, config, design, and completed plan. Fetch `origin/main`, require a fast-forward base, push to `main`, and require successful GitHub Actions.

### Task 3: Shadowrocket live test

**Files:**
- No repository changes

**Interfaces:**
- Consumes: published raw configuration and installed Shadowrocket app
- Produces: observed policy results for three hostnames, with original app state restored

- [ ] **Step 1: Inspect current Shadowrocket state**

Record the active configuration/routing state without changing it.

- [ ] **Step 2: Use rule test UI if available**

Test `connectivitycheck.gstatic.com`, `ajax.gstatic.com`, and `youtubei.googleapis.com`, expecting `DIRECT`, `Google`, and `YouTube` respectively.

- [ ] **Step 3: Fall back to minimal requests and logs if needed**

If no rule test UI exists, use the published configuration, send one request per hostname without changing the selected proxy node, and inspect the Shadowrocket logs.

- [ ] **Step 4: Restore and report**

Restore any temporary UI/config selection and report exact observed results and limitations.
