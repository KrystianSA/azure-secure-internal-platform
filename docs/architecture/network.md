# Network

A Virtual Network was created using the 10.0.0.0/16 address space with a dedicated subnet (10.0.0.0/24) for private endpoints.

The subnet was configured as a private subnet to restrict direct outbound internet access. This supports a security-first approach where resources are not publicly exposed and communication is expected to remain within the private network boundary.

This design aligns with cloud security best practices by reducing the attack surface and enforcing private connectivity between services.
