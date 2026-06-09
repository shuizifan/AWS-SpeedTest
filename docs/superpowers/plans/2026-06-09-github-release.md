# AWS-SpeedTest GitHub Release Preparation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prepare the flat Windows utility directory for a professional, GPL-compliant GitHub release.

**Architecture:** Keep all end-user runtime files in the repository root. Add repository documentation and metadata around the existing scripts and the unmodified upstream `cfst.exe`, then verify documentation consistency and runtime file integrity.

**Tech Stack:** Markdown, PowerShell 5.1, Windows batch, Git

---

### Task 1: User documentation

**Files:**
- Create: `README.md`
- Delete: `使用说明.txt`

- [x] **Step 1: Write README content**

Document project scope, requirements, quick start, workflow, configuration, recovery, security warnings, upstream attribution, binary checksum, license, and disclaimer.

- [x] **Step 2: Remove duplicate instructions**

Delete `使用说明.txt` after all useful instructions are represented in `README.md`.

- [x] **Step 3: Verify documentation**

Run a text check for the expected upstream version, license identifier, checksum, administrator warning, and hosts recovery instructions.

### Task 2: Repository metadata and legal notices

**Files:**
- Create: `LICENSE`
- Create: `NOTICE`
- Create: `CHANGELOG.md`
- Create: `SECURITY.md`
- Create: `.gitignore`
- Create: `.gitattributes`
- Create: `docs/RELEASE.md`

- [x] **Step 1: Add GPL and attribution files**

Add the GNU GPL v3 license text and a notice distinguishing the unmodified upstream binary from this project's scripts and configuration.

- [x] **Step 2: Add repository maintenance files**

Add changelog, security policy, line-ending rules, generated-file ignores, and release instructions.

- [x] **Step 3: Verify repository metadata**

Check that generated output is ignored and all legal documents consistently identify GPL-3.0-only and CloudflareSpeedTest v2.3.4.

### Task 3: Script provenance and release verification

**Files:**
- Modify: `update-host.ps1`
- Modify: `亚马逊测速.bat`

- [x] **Step 1: Add concise SPDX headers**

Add project copyright and `SPDX-License-Identifier: GPL-3.0-only` comments without changing runtime behavior.

- [x] **Step 2: Run syntax and binary checks**

Parse `update-host.ps1`, invoke `cfst.exe -h`, and verify the binary SHA-256.

- [x] **Step 3: Inspect final release contents**

Confirm the repository has the intended flat runtime layout and contains no generated `result.csv`, hosts backups, logs, or release archives.
