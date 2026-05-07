# Tenant Hardening

Several Microsoft Entra ID tenant settings were adjusted to reduce unnecessary exposure and improve governance.

---

## Guest User Restrictions

Guest users were configured with the most restrictive access model.

Configured setting:
- Guest users can access only their own directory objects and properties

Reason:
prevent external identities from enumerating users, groups, or directory structure information.

---

## Guest Invitation Restrictions

Only administrators are allowed to invite guest users.

Reason:
reduce uncontrolled external collaboration and improve tenant governance.

---

## Guest Self-Service Sign-Up

Guest self-service sign-up was disabled.

Reason:
prevent uncontrolled onboarding of external identities into the tenant.

---

## Microsoft Entra Admin Center Restrictions

Access to the Microsoft Entra admin center was restricted.

Reason:
limit administrative portal exposure to authorized administrators only.

---

## Application Registration Restrictions

User ability to register applications was disabled.

Reason:
reduce the risk of unauthorized app registrations, credential abuse, or persistence mechanisms.

---

## Security Group Creation Restrictions

User ability to create security groups was disabled.

Reason:
maintain centralized governance and avoid uncontrolled privilege delegation.

---

## Persistent Session Prompt

The "Keep user signed in" option was disabled.

Reason:
reduce long-lived authenticated sessions and improve security posture.

---

## Security Approach

The tenant configuration follows a restrictive-by-default model:
- centralized administration
- minimal default permissions
- controlled guest access
- reduced attack surface

This aligns with least privilege and security-first identity governance principles.
