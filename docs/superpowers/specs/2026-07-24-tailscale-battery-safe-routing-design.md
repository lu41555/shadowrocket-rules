# Tailscale Battery-Safe Routing Design

## Goal

Reduce the risk of nested VPN/proxy retries on iPhone while preserving the
existing rule that non-Tailscale `100.*` addresses use the manually selected
proxy.

## Routing behavior

- Route `tailscale.com`, `tailscale.io`, and `ts.net` directly.
- Route Tailscale's `100.64.0.0/10` address range directly.
- Keep the MagicDNS address `100.100.100.100/32` direct.
- Route the rest of `100.0.0.0/8` through `PROXY`.
- Place both specific direct IP rules before the broad `100.0.0.0/8` proxy
  rule so first-match routing is deterministic.

## Scope

Apply the same behavior to the full and simple configurations. Update the
README and comments to match. Do not alter policy groups, automatic switching,
other service routing, or tunnel exclusions.

## Verification

The validator will require each rule exactly once, reject the previous
Tailscale-domain proxy rules, and verify that both specific direct IP rules
precede the broad `100.0.0.0/8` proxy rule. The existing complete validation
suite must still pass.

## Self-review

The design has one unambiguous precedence order, covers both distributed
configurations, and leaves unrelated routing behavior unchanged.
