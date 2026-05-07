# Identity & Access Architecture

Microsoft Entra ID was used as the centralized identity provider for the environment.

The platform follows an identity-based access model where access to Azure resources is controlled through Azure RBAC instead of shared credentials or local accounts.

The virtual machine was integrated with Microsoft Entra ID to support centralized authentication and future RBAC validation scenarios.

This approach improves:
- access governance
- security visibility
- least privilege enforcement
- centralized identity management

A system-assigned managed identity was also enabled for the virtual machine to support secure service-to-service authentication without storing credentials directly inside the VM.
