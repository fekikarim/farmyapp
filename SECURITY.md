# Security Policy

## Supported Versions

Security fixes are prioritized for the latest active code on `main`.

| Version | Supported |
|--------:|:---------:|
| main    | ✅        |
| older branches/tags | ⚠️ best effort |

---

## Reporting a Vulnerability

If you discover a security vulnerability, **please do not open a public GitHub issue**.

Instead, report it privately to the maintainer:

- **Repository owner:** `@fekikarim`
- Use a private communication channel available to the maintainer (email or direct contact).

If no private channel is listed yet, create one and update this policy with official contact details.

---

## What to Include in a Report

Please include as much of the following as possible:

1. Vulnerability type (e.g., auth bypass, insecure storage, data exposure)
2. Affected file(s), module(s), and platform(s)
3. Reproduction steps
4. Potential impact
5. Proof-of-concept (if safe to share)
6. Suggested remediation (optional)

---

## Response Expectations (Target)

- **Acknowledgment:** within 72 hours
- **Initial triage:** within 7 days
- **Fix timeline:** depends on severity and complexity

Severity guidance:
- **Critical:** immediate action
- **High:** accelerated patch cycle
- **Medium/Low:** scheduled remediation

---

## Security Best Practices for Contributors

- Never commit API keys, tokens, or credentials
- Keep sensitive values in environment variables / secure stores
- Validate all inputs and server responses
- Avoid storing sensitive data in plain local storage
- Review permission usage (camera, microphone, files)
- Keep dependencies updated and monitored for advisories

---

## Disclosure Policy

After a fix is released:
- A brief advisory may be published
- Details should avoid exposing exploit paths before users can update

---

## Scope Notes

This policy covers:
- Mobile, web, and desktop app surfaces in this repository
- Build and runtime configuration relevant to this codebase

Out-of-scope:
- Third-party services not controlled by this repository owner
- Issues requiring privileged access without realistic threat model context
