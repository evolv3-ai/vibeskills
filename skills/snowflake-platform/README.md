# snowflake-platform

Build on Snowflake's AI Data Cloud with snow CLI, Cortex AI functions, Native Apps, and Snowpark.

## Auto-Trigger Keywords

This skill activates when conversations include:

**Platform:**
- snowflake
- snow cli
- snowflake cli
- snowflake connection
- snowflake account

**Cortex AI:**
- cortex ai
- snowflake cortex
- AI_COMPLETE
- AI_SUMMARIZE
- AI_TRANSLATE
- AI_FILTER
- AI_CLASSIFY
- AI_SENTIMENT
- SNOWFLAKE.CORTEX
- cortex llm
- cortex functions

**Native Apps:**
- native app
- snowflake native app
- snowflake marketplace
- provider studio
- application package
- release channels
- snow app run
- snow app deploy
- snow app publish
- setup_script.sql
- manifest.yml

**Authentication:**
- snowflake jwt
- snowflake authentication
- account locator
- rsa key snowflake
- snowflake private key

**Snowpark:**
- snowpark
- snowpark python
- snowflake dataframe
- snowflake udf
- snowflake stored procedure

**Errors:**
- jwt validation error snowflake
- account identifier
- REFERENCE_USAGE
- external access integration
- release directive
- security review status

## What This Skill Covers

1. **Snow CLI** - Project management, SQL execution, app deployment
2. **Cortex AI** - LLM functions in SQL (COMPLETE, SUMMARIZE, TRANSLATE, etc.)
3. **Native Apps** - Development, versioning, marketplace publishing
4. **Authentication** - JWT key-pair, account identifiers (critical gotcha)
5. **Snowpark** - Python DataFrame API, UDFs, stored procedures
6. **Marketplace** - Security review, Provider Studio, paid listings

## What This Skill Does NOT Cover

- Streamlit in Snowflake (use `streamlit-snowflake` skill)
- Data engineering/ETL patterns
- BI tool integrations (Tableau, Looker)
- Advanced ML model deployment

## Key Corrections

- Account identifier confusion (org-account vs locator)
- External access integration reset after deploys
- Release channel syntax (CLI vs legacy SQL)
- Artifact nesting in snowflake.yml
- REFERENCE_USAGE grant syntax for shared data

## Related Skills

- `streamlit-snowflake` - Streamlit apps in Snowflake
