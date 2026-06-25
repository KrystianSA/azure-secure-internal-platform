## Network Security Group — vm-workstation1-nsg

### Discovery: built-in default rules

After connecting to the VM via Bastion successfully (before any custom rules
were added), inspecting the NSG revealed it was **not actually empty** — Azure
attaches built-in, non-removable default rules to every NSG:

| Priority | Name | Source | Destination | Action |
|---|---|---|---|---|
| 65000 | `AllowVnetInBound` | VirtualNetwork | VirtualNetwork | Allow |
| 65001 | `AllowAzureLoadBalancer` | AzureLoadBalancer | Any | Allow |
| 65500 | `DenyAllInBound` | Any | Any | Deny |
| 65000 | `AllowVnetOutBound` | VirtualNetwork | VirtualNetwork | Allow |
| 65001 | `AllowInternetOutBound` | Any | Internet | Allow |
| 65500 | `DenyAllOutBound` | Any | Any | Deny |

**This explains why RDP-via-Bastion worked immediately**, without any custom
rule: Bastion's subnet (`AzureBastionSubnet`) and the VM's subnet (`snet-vm`)
are both part of the same VNet, so traffic between them matched
`AllowVnetInBound` (priority 65000) before ever reaching `DenyAllInBound`.

> 📌 **Key takeaway:** these built-in rules cannot be deleted — they always
> exist at priority 65000+. The only way to override their behavior is to add
> custom rules with a **lower** priority number (= higher precedence), which
> get evaluated first.

### Problem identified

`AllowVnetInBound` is broader than intended: it permits **any traffic, on any
port, from anywhere in the VNet** to reach the VM — not just RDP from Bastion.
This conflicts with the platform's "zero unnecessary exposure" principle: in
its current state, anything else later added to this VNet could reach the VM
on any port, not only Bastion over RDP.

### Planned fix (in progress)

Add two custom inbound rules, evaluated before the built-in ones:

| Priority | Name | Source | Destination | Port | Protocol | Action |
|---|---|---|---|---|---|---|
| 100 | `AllowRDPFromBastion` | `10.0.1.0/26` (AzureBastionSubnet) | Any | 3389 | TCP | Allow |
| 200 | `DenyAllInbound...` | Any | Any | Any | Any | Deny |

- **Source `10.0.1.0/26` over a specific IP** — Bastion can use more than one
  internal address within its subnet for scaling, so the rule targets the
  whole subnet range rather than a single address.
- **Destination: `Any`** — sufficient and safe here, since this NSG is bound
  to this VM's NIC specifically; "Any" in this context can only ever mean
  "this VM's private IP", not any wider scope.
- **Ordering matters operationally:** the Allow rule (priority 100) must be
  created *before* the Deny rule (priority 200). Azure applies each rule
  immediately on save — adding the Deny-all rule first would briefly block
  Bastion's own RDP access until the Allow rule exists. Azure's portal
  explicitly warns about this when creating a Deny rule that would affect
  VirtualNetwork access.

### Outbound rules — deliberately left unchanged

Considered narrowing `AllowInternetOutBound` the same way, but decided
against it for now: outbound restriction would block Windows Update,
activation, and Microsoft Entra ID sync/join traffic — the same conflict
already solved once at the subnet level (`snet-vm`'s "private subnet" toggle).

Properly restricting outbound traffic would require allow-listing specific
Microsoft service endpoints (e.g. via NSG **Service Tags** like
`AzureActiveDirectory`, `WindowsUpdate`) rather than blocking broadly — this is
a real AZ-104 topic but is being deferred to **Phase 2** as a deliberate,
well-scoped follow-up rather than done hastily now.
