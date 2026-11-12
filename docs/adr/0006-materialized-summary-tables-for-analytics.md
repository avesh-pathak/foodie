# ADR 0006: Materialized Summary Tables for Analytics

## Status
Accepted

## Decision
- Maintain summary tables (daily restaurant/area aggregates).
- Update summaries incrementally on order insert/status change.
- Provide endpoints for area, restaurant, dish, time, AOV, and return metrics.