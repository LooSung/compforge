"""Compforge architecture review.

Read-only PR-diff reviewer. New or worsened hard-rule findings on the
changed surface. Pure stdlib. Non-blocking.

Layout:
  model       -- ReviewRun, value objects, RuleCatalog
  changeset   -- parse `git diff -U0` into added line ranges
  detectors   -- React/TS scans into candidate Violations
  delivery    -- summary comment + machine JSON + correction prompt
  main        -- reviewPullRequest orchestration + CLI
"""
