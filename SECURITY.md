# Security Policy

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Email **chopra.cc1@gmail.com** with a description of the issue. I will acknowledge within 72 hours and aim to release a patch within 14 days.

---

## Scope

**In scope:**

- Logic that modifies TCC database entries
- JavaScript injection surface in the WKWebView layer
- Any scenario where user data (file contents, database values) could be exposed or transmitted unintentionally

**Out of scope:**

- Issues that require SIP (System Integrity Protection) to be disabled
- Social engineering or phishing attacks

---

## Notes

Clearance always operates on a user-provided copy of the TCC database. It does not request elevated privileges, does not access `/var/db/TCC`, and does not modify any file the user has not explicitly opened.
