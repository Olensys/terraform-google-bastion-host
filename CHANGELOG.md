# Changelog

## [1.1.2](https://github.com/Olensys/terraform-google-bastion-host/compare/v1.1.1...v1.1.2) (2026-10-24)


### Bug Fixes

* **examples:** unique application slug so concurrent integration runs do not collide ([#2](https://github.com/Olensys/terraform-google-bastion-host/issues/2)) ([6a2919f](https://github.com/Olensys/terraform-google-bastion-host/commit/6a2919f574a2d2419be8a5bc7bc7ac1cb689bb1f))

## [1.1.1](https://github.com/Olensys/terraform-google-bastion-host/compare/v1.1.0...v1.1.1) (2026-10-24)


### Bug Fixes

* run integration on change and weekly instead of nightly ([548210c](https://github.com/Olensys/terraform-google-bastion-host/commit/548210c1539c32a40ad3c97f30a0e9d945530c22))

## 1.1.0

### Fixes

- normalise `context.extra_tags` keys and values to valid GCP label syntax (lowercase, invalid characters to `-`, 63 characters); `labels` still win

### Tests

- `test_tags_contract` covers a mixed-case tag key and a value with a space

### Docs

- README usage shows the naming module

### Behaviour changes

- `context.extra_tags` entries now appear as normalised labels (for example `Team = "Core Team"` becomes `team = "core-team"`). Callers that relied on unnormalised keys must read the normalised ones; values that previously failed GCP label validation now succeed.

## 1.0.1

### Fixes

- widen google-beta bound, require letter-leading name, expose ip_address

## 1.0.0

- Bastion VM with no external IP, IAP-only SSH, OS Login and a shielded Debian 12 image, for named IAM members, wrapping terraform-google-modules/bastion-host/google 9.0.0.
