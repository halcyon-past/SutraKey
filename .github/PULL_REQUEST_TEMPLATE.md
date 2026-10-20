## Description
Summary of the changes introduced by this pull request.

## Branch Policy Compliance
- [ ] PR target is one of: `dev`, `uat`, `main`
- [ ] Source branch complies with naming conventions:
  - Core: `dev`, `uat`, `main`
  - Feature: `feature/<env>/<feature-name>` (lowercase alphanumeric & hyphens)
  - Hotfix: `hotfix/<feature-name>`

## Quality Checklist
- [ ] Swift 6 strict concurrency adhered to (`@MainActor`, `Sendable`, `actor`).
- [ ] No force unwraps (`!`) used outside unit tests.
- [ ] `swift test` passes 100% locally with zero warnings.
- [ ] Output files strictly route to `~/Downloads` without directory traversal.
