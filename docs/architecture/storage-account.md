# Storage Account

## Private Access Only (No Public Exposure)

Public network access was disabled to ensure that the storage account is not exposed to the internet. Access is only possible through a Private Endpoint integrated with the Virtual Network.

This approach reduces the attack surface and aligns with a security-first architecture.

---

## Private Endpoint

A dedicated Private Endpoint was deployed within the private subnet of the Virtual Network.

This allows secure communication with the storage account over the internal Azure network without exposing the service publicly.

---

## Azure Private DNS Integration

Private DNS zone integration was enabled using:

`privatelink.blob.core.windows.net`

This configuration allows the storage account name to resolve automatically to a private IP address without requiring application-level configuration changes.

---

## Microsoft Entra ID Authentication

Shared key access was disabled to avoid the use of static credentials such as access keys and SAS-based authentication.

Access is intended to be managed through Microsoft Entra ID and Azure RBAC to support identity-based access control and improved security visibility.

---

## Data Protection

The following protection mechanisms were enabled:
- Blob soft delete
- Container soft delete

The following features were intentionally disabled:
- Point-in-time restore
- Versioning
- Change feed

This configuration provides basic protection against accidental deletion while avoiding unnecessary complexity and additional cost in a lab environment.

---

## Secure Transfer Enforcement

Secure transfer was enforced and the minimum TLS version was set to 1.2.

This ensures that all communication with the storage account is encrypted and aligned with modern security standards.

---

## Restricted Copy Operations

Copy operations were restricted to storage accounts using private endpoints within the same virtual network boundary.

This reduces the risk of unintended data movement outside trusted network paths.

---

## Encryption Strategy

Microsoft-managed keys (MMK) were used together with the default encryption-at-rest provided by Azure Storage.

Infrastructure encryption was not enabled because the project does not require double encryption scenarios typically associated with highly regulated environments.

---

## Microsoft Defender for Storage

Microsoft Defender for Storage was not enabled.

The project is designed as a lab environment without production traffic or external users. Threat detection and advanced monitoring features would be considered in a production deployment.

---

## Cost-Optimized Configuration

The following configuration was selected:
- Standard performance tier
- Locally redundant storage (LRS)
- Hot access tier

This setup provides a balance between usability, simplicity, and cost-efficiency for a development/lab scenario.

---

## Tagging Strategy

Consistent resource tags were applied:
- `project: azure-secure-internal-platform`
- `env: lab`

This supports resource organization, governance, and cost tracking practices.
