# Changelog

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
