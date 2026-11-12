# ADR 0003: Neon Postgres as System of Record

## Status
Accepted

## Decision
- Migrate all demo data to Neon Postgres.
- Remove runtime mock data usage after successful seed.
- Use summary tables for fast analytics reads.