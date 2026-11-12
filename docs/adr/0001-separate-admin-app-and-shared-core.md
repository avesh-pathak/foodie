# ADR 0001: Separate Admin App with Shared Core Package

## Status
Accepted

## Context
The customer app is Flutter. Admin functionality must be separate, with no auth initially.

## Decision
- Build a separate Flutter app under `admin/`.
- Extract shared models, DTOs, and API client into `packages/foodie_core`.
- Both apps depend on the shared package via path dependency.

## Consequences
- Admin concerns stay isolated.
- Monorepo builds must include `packages/foodie_core`.