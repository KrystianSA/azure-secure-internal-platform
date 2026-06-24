## Virtual Machine — User Workstation

**Resource name:** `vm-workstation1`
**Region:** Poland Central
**Subnet:** `snet-vm`

### Specs

| Setting | Value | Reasoning |
|---|---|---|
| Image | Windows 11 Pro, version 25H2 (Gen2) | Simulates a real corporate user workstation, not a server |
| Size | `Standard_D2als_v6` (2 vCPU, 4 GiB RAM) | Smallest size suitable for a Windows GUI desktop used intermittently for demos/testing |
| Security type | Trusted launch (Secure Boot + vTPM enabled) | Default, safer VM generation at no extra cost over Standard |
| OS disk | Standard HDD, locally-redundant | Lab workload, no high-IOPS requirement — cheapest disk tier is sufficient |
| Encryption at host | Disabled | Adds encryption for the temp disk and host-to-storage traffic path; standard Azure Disk Storage encryption (always-on, at rest) already covers the OS/data disks. Not needed for a non-production lab |

### Networking

| Setting | Value | Reasoning |
|---|---|---|
| Public IP | **None** | Core requirement of the platform — the VM must not be reachable directly from the internet |
| Public inbound ports | **None** | No ports opened to the internet at all; access happens exclusively through Azure Bastion, over the private network |
| NIC NSG | Basic (new, empty) | Created with no inbound allow rules (since no public ports were selected) — a deliberately restrictive starting point. An explicit rule allowing RDP (3389) only from `AzureBastionSubnet` will be added separately |
| Accelerated networking | On | Free performance improvement, no downside for this VM size |
| Delete NIC when VM is deleted | Enabled | Avoids orphaned resources when the VM is rebuilt in future iterations |

> ⚠️ **Important — not yet functional for remote access:** at this point, Bastion
> cannot yet connect to the VM over RDP. The NSG has no rule permitting inbound
> traffic from the Bastion subnet. This will be added as an explicit, scoped rule
> (source: `10.0.1.0/26`, port 3389) rather than relying on any broad default.

### Identity & access

| Setting | Value | Reasoning |
|---|---|---|
| System assigned managed identity | On | Required prerequisite for Microsoft Entra ID login; also enables future passwordless authentication to other Azure services (e.g. Key Vault, Storage) without secrets in code |
| Login with Microsoft Entra ID | On | Core requirement — sign-in is intended to use Entra ID identities rather than local Windows accounts |
| Local admin username | `adminKrystianSa` | Still required by the VM creation flow even with Entra ID login enabled; not the intended primary sign-in path |

> 📌 **Next required step:** Entra ID login will not work yet. Azure requires an
> explicit RBAC role assignment — `Virtual Machine Administrator Login` or
> `Virtual Machine User Login` — scoped to this VM, for any Entra identity that
> should be able to sign in. This is configured after VM creation, not during it.

### Management & monitoring

| Setting | Value | Reasoning |
|---|---|---|
| Backup / Site Recovery | Disabled | Disaster-recovery features not relevant to a lab VM that may be rebuilt entirely in future iterations |
| Patch orchestration | Automatic by OS (Windows Update) | No need for manual patch management at this stage |
| Boot diagnostics | Enabled (managed storage account) | Nominal cost; valuable first troubleshooting step if the VM fails to boot correctly |
| Recommended alert rules / OS guest diagnostics / Application health monitoring | Disabled | Monitoring strategy for this platform goes through Log Analytics + Diagnostic Settings (planned), not these built-in mechanisms |

### Licensing

**Azure Hybrid Benefit:** enabled (`License type: Windows Client`) — required by the
subscription type in use; Azure enforced this selection rather than it being a
free choice.

### Tags

`project=secure-internal-platform`, `environment=lab` — inherited from the
resource group convention.
