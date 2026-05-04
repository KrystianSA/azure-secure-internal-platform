## Resource Group Design

A dedicated resource group was created to logically group all components of the project and simplify lifecycle management.

The Poland Central region was selected to ensure low latency and regional consistency.

Basic tagging was introduced to support resource organization and reflect real-world governance practices.

## Network Design

A Virtual Network was created using the 10.0.0.0/16 address space with a dedicated subnet (10.0.0.0/24) for private endpoints.

The subnet was configured as a private subnet to prevent direct outbound internet access. This enforces a security-first approach where resources are not exposed publicly and all communication is expected to remain within the private network.

This design aligns with best practices by minimizing the attack surface and ensuring that access to services is controlled through private connectivity.
