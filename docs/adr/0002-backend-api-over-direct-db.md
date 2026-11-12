# ADR 0002: Backend API Owns Database Credentials

## Status
Accepted

## Decision
- Use a Hono/Node backend API as the only DB client.
- Store `DATABASE_URL` server-side.
- Flutter apps call REST endpoints; writes require an admin token.