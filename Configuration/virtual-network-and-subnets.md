## Virtual Network & Subnets

**VNet:** `vn-secure-internal-platform` — (Poland Central)

| Subnet Name | Purpose | Outbound Access Type |
| :--- | :--- | :--- |
| `AzureBastionSubnet` | Required exact name for Azure Bastion service | Default outbound access |
| `snet-vm` | Hosts the user workstation VMs | **Default outbound enabled** |
| `snet-pe` | Hosts Private Endpoint NICs for storage accounts | Private subnet (no default outbound) |

### Decisions & reasoning

- **Azure Bastion enabled at VNet creation** — avoids exposing the workstation
  VM to the internet via a public IP/RDP.
  - Azure Firewall,
  - DDoS Network Protection,
  - Virtual network encryption were left disabled: both are paid services that add value at scale/production, not for a single-VM lab environment.

- **`snet-vm` initially had "private subnet" (no default outbound access)
  enabled by default — this was corrected.** A VM with no outbound internet
  access cannot complete Windows Update/activation, and more importantly
  cannot reliably complete Microsoft Entra ID join/sync, which depends on
  outbound connectivity to Microsoft identity endpoints. Outbound access was
  re-enabled for this subnet.

- **`snet-pe` keeps "private subnet" (no default outbound access).** A
  Private Endpoint doesn't initiate outbound traffic — it's an inbound-only
  network presence representing the storage account inside the VNet — so
  this restriction is safe and consistent with the "no unnecessary exposure"
  goal of the platform.

- **Tags** `project=secure-internal-platform`, `environment=lab` applied
  consistently, inherited from the resource group convention.
