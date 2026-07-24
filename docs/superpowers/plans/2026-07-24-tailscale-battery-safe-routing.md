# Tailscale Battery-Safe Routing Implementation Plan

1. Update validator expectations for direct Tailscale domains and
   `100.64.0.0/10`, including rule-order checks.
2. Run the validator against the old configurations and confirm it fails for
   the expected missing/new rules.
3. Update both configurations and README wording without changing unrelated
   routing.
4. Run the complete validator, inspect the diff, and confirm only intended
   files changed.
5. Commit, push to `main`, and verify the GitHub Actions validation result.
