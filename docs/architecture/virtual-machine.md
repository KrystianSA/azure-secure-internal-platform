# Virtual Machine

## Purpose

A dedicated virtual machine was deployed inside the management subnet to provide administrative access and validate private connectivity to internal Azure resources.

The VM is intended for:
- management access
- network validation
- private endpoint testing
- RBAC and Microsoft Entra ID access testing

---

## Network Segmentation

The virtual machine was placed in a dedicated subnet:

`snet-management (10.0.1.0/24)`

This subnet is separated from the private endpoint subnet to maintain clear network segmentation and reduce unnecessary exposure between infrastructure components.

---

## Controlled Public Access

A Public IP address was assigned to the VM to allow administrative SSH connectivity.

However:
- inbound public access rules were not automatically enabled
- SSH access is intended to be restricted later using NSG rules and source IP filtering

This approach avoids exposing the VM to unrestricted internet traffic by default.

---

## Authentication Strategy

SSH public key authentication was used instead of passwords.

Configuration:
- SSH key type: Ed25519
- Authentication method: SSH public key

Reason:
- improved security
- resistance against brute-force attacks
- modern authentication standard for Linux administration

---

## Microsoft Entra ID Integration

Microsoft Entra ID login was enabled together with a system-assigned managed identity.

This allows:
- centralized identity management
- RBAC-based VM access control
- MFA enforcement through Entra ID
- reduced reliance on local VM accounts

The configuration also prepares the environment for future RBAC validation scenarios.

---

## Security Configuration

The VM was configured using:
- Trusted Launch
- Secure Boot
- virtual TPM (vTPM)

Reason:
establish a stronger security baseline aligned with modern Azure security recommendations.

---

## Cost-Optimized Lab Configuration

The following decisions were made to reduce operational cost and complexity:
- Standard SSD storage
- no additional data disks
- no backup configuration
- no load balancer
- accelerated networking disabled
- monitoring features minimized

This keeps the VM lightweight while remaining fully functional for testing and validation purposes.

---

## Monitoring and Diagnostics

Boot diagnostics were enabled using a managed storage account.

Reason:
support troubleshooting and VM startup diagnostics while keeping management overhead minimal.

Additional guest monitoring and application health monitoring were intentionally disabled because the VM is not hosting production workloads.

---

## Resource Lifecycle Management

Automatic cleanup options were enabled:
- delete OS disk with VM
- delete NIC and Public IP with VM

Reason:
avoid orphaned resources and unnecessary costs in the lab environment.

---

## Tagging Strategy

Consistent tags were applied:
- `project: azure-secure-internal-platform`
- `env: lab`

This supports resource organization and governance consistency across the project.
