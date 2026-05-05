## Resource Group Design

A dedicated resource group was created to logically group all components of the project and simplify lifecycle management.

The Poland Central region was selected to ensure low latency and regional consistency.

Basic tagging was introduced to support resource organization and reflect real-world governance practices.

## Network Design

A Virtual Network was created using the 10.0.0.0/16 address space with a dedicated subnet (10.0.0.0/24) for private endpoints.

The subnet was configured as a private subnet to prevent direct outbound internet access. This enforces a security-first approach where resources are not exposed publicly and all communication is expected to remain within the private network.

This design aligns with best practices by minimizing the attack surface and ensuring that access to services is controlled through private connectivity.

## Storage Account Design Decisions

### Private Access Only (No Public Exposure)
The storage account was configured with public network access disabled.  
Access is only possible through a Private Endpoint integrated with the Virtual Network.

Reason: eliminate exposure to the public internet and reduce attack surface.

---

### Use of Private Endpoint
A Private Endpoint was created and placed in a dedicated subnet.

Reason: ensure secure, private connectivity to the storage account over the internal Azure network.

---

### Azure Private DNS Integration
Private DNS zone integration was enabled (`privatelink.blob.core.windows.net`).

Reason: allow seamless name resolution of the storage account to a private IP without requiring application changes.

---

### Microsoft Entra ID over Shared Key Access
Shared key (access key) authentication was disabled.  
Access is intended to be managed via Microsoft Entra ID (RBAC).

Reason: avoid static credentials and enforce identity-based access control.

---

### Minimal Data Protection Configuration
Enabled:
- Blob soft delete
- Container soft delete

Disabled:
- Point-in-time restore
- Versioning
- Change feed

Reason: provide basic protection against accidental deletion while avoiding unnecessary complexity and cost in a lab environment.

---

### Secure Transfer Enforcement
Secure transfer (HTTPS) was required and minimum TLS version set to 1.2.

Reason: ensure encrypted communication and align with security best practices.

---

### Restricted Copy Scope
Copy operations were limited to storage accounts with private endpoints in the same virtual network.

Reason: prevent unintended data movement outside the trusted network boundary.

---

### Encryption Strategy
Used Microsoft-managed keys (MMK) with default encryption at rest.  
Infrastructure encryption was not enabled.

Reason: sufficient security for the lab scenario without added complexity of double encryption.

---

### Defender for Storage Disabled
Microsoft Defender for Storage was not enabled.

Reason: project is a lab with no real user traffic or production workload; feature would be considered in production.

---

### Cost-Optimized Configuration
- Standard performance tier
- Locally redundant storage (LRS)
- Hot access tier

Reason: balance between cost and usability for a development/lab scenario.

---

### Tagging Strategy
Applied consistent tags:
- project: azure-secure-internal-platform
- env: lab

Reason: enable cost tracking and resource organization aligned with real-world governance practices.
