---
globs:
  - "snowflake.yml"
  - "manifest.yml"
  - "setup_script.sql"
  - "setup.sql"
  - "**/PROVIDER_STUDIO.md"
---

# Snowflake Native App Corrections

## Release Directive Syntax

When release channels are enabled (default in newer versions), legacy SQL syntax fails.

| If Claude suggests... | Use instead... |
|----------------------|----------------|
| `ALTER APPLICATION PACKAGE ... SET DEFAULT RELEASE DIRECTIVE VERSION = V1_0 PATCH = 0` | `snow app release-directive set default --version V1_0 --patch 0 --channel DEFAULT` |

Check if channels enabled: `snow app release-channel list`

## Data Sharing Syntax

| If Claude suggests... | Use instead... |
|----------------------|----------------|
| `GRANT REFERENCE_USAGE ON DATABASE ... TO SHARE` | `GRANT REFERENCE_USAGE ON DATABASE ... TO SHARE IN APPLICATION PACKAGE pkg_name` |

## External Access Integration Reset

**Critical**: External access integration attachment resets on EVERY `snow app run`.

After each deploy, re-run:
```sql
ALTER STREAMLIT [APP_NAME].config_schema.[streamlit_name]
  SET EXTERNAL_ACCESS_INTEGRATIONS = (integration_name);
```

## Artifact Mapping

Directory mappings nest the folder. Always list files explicitly:

| If Claude suggests... | Use instead... |
|----------------------|----------------|
| `src: app/streamlit/` with `dest: streamlit/` | List individual files explicitly |

```yaml
# WRONG - creates streamlit/streamlit/
artifacts:
  - src: app/streamlit/
    dest: streamlit/

# CORRECT - flat structure
artifacts:
  - src: app/streamlit/environment.yml
    dest: streamlit/environment.yml
  - src: app/streamlit/streamlit_app.py
    dest: streamlit/streamlit_app.py
```

## Manifest Privileges

| If Claude suggests... | Use instead... |
|----------------------|----------------|
| Privileges section in manifest.yml | Remove privileges section entirely |
| GRANT ALL/FUTURE in setup_script.sql | Use specific table grants only |

Native Apps cannot declare privileges in manifest.

## Snowpark Row Access

| If Claude suggests... | Use instead... |
|----------------------|----------------|
| `dict(result[0])` for Snowpark Row | `row['COLUMN_NAME']` explicit access |

```python
# WRONG
config = dict(result[0])

# CORRECT
row = result[0]
config = {'COLUMN_A': row['COLUMN_A'], 'COLUMN_B': row['COLUMN_B']}
```

## Security Review Statuses

Include all 5 statuses:
- `NOT_REVIEWED` - Scan hasn't run
- `IN_PROGRESS` - Scan running
- `APPROVED` - Passed
- `REJECTED` - Failed
- `MANUAL_REVIEW` - Human reviewing (can take business days)

## Provider Studio

- Description field uses WYSIWYG editor - cannot paste raw HTML
- Business Needs require individual descriptions (not just selection)
- **Data Dictionary is MANDATORY for data listings (2025)**

## Paid Listing

Cannot convert free listing to paid. Must create new paid listing.
