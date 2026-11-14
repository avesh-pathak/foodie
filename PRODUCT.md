# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Hiring managers and reviewers evaluating a portfolio build. Their job is to decide, within a few minutes, whether the work is real, deep, and well-crafted.

## Product Purpose

Showcase the Foodie restaurant-ordering system: a Flutter customer app, an admin console and a kitchen board on one Hono + Neon Postgres backend. The page must prove the build is real and scoped honestly, not perform marketing.

## Positioning

A real, locally runnable full-stack build with an explicit "real vs. simulated" split. The differentiator is honesty about scope plus a documented architecture (diagram, four flows, twelve tables, API surface, six decisions) rather than a hero screenshot.

## Operating Context

Reviewers arrive from a portfolio link, skim on desktop first, then check mobile. They open source files and run the build. They expect labelled controls, reduced motion, and a 44 px tap-target floor.

## Capabilities and Constraints

- Static Next.js showcase (`web/showcase`); Flutter apps live elsewhere in the repo and are not runnable in-browser.
- Demo data: six restaurants, 28 dishes. Admin and kitchen writes persist; customer login and payments are simulated.
- One brand palette: red `#DC2B3B`, deep red `#A8121F`, soft red `#FDEBEE`, warm paper `#FFF8F4`, ink `#1C1516`.
- Reduced motion is supported on the page (`prefers-reduced-motion`).

## Brand Commitments

- Name: Foodie. Mark: `foodie-mark.svg` / `foodie-admin-logo.png`.
- Font: Plus Jakarta Sans, 400–800.
- The architecture diagram is the spine of the page; do not remove or replace it without a redesign decision.

## Evidence on Hand

- Selected screen captures (`/assets/img/screens/*.webp`), 30-second tour video, source-file review list (`lib/state/foodie_app_state.dart`, `server/src/routes/orders.ts`, etc.).
- No hosted demo; credentials are local-build only.

## Product Principles

- Prove, don't claim: every statement must be checkable against source or a screenshot.
- Scope honestly: separate "real in this build" from "simulated on purpose".
- Preserve identity: warm, food-led, red; never generic portfolio chrome.

## Accessibility & Inclusion

- 44 px tap targets on labelled controls; reduced motion; color-plus-label cues; 12 px minimum supporting type.