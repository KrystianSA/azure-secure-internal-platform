## Storage Account & Private Endpoint

**Resource name:** `sasecureinternalplatform`
**Region:** Poland Central
**Primary service:** Azure Blob Storage

### Specs

| Setting | Value | Reasoning |
|---|---|---|
| Performance | Standard | No need for Premium (low-latency/high-IOPS) for test/demo files |
| Replication | LRS (Locally-redundant) | Lab data, no need for geo-replication |
| Preferred storage type | Blob Storage / Data Lake Storage | Reflects actual intended use; doesn't restrict the account technically, only tailors portal guidance |
| Hierarchical namespace, SFTP, NFS v3 | Disabled | No big-data/directory-semantics workload; unnecessary complexity for a handful of test files |
| Cross-tenant replication | Disabled | Single-tenant project, not a multi-tenant SaaS scenario |
| Access tier | Hot | Files are actively accessed during testing, not archived |
| Azure Files / SMB | Not used | This project uses Blob Storage exclusively, not file shares |

### Networking — core security mechanism

| Setting | Value | Reasoning |
|---|---|---|
| Public network access | **Disabled** | No public IP/endpoint exposure at all — this is the foundation of the "zero exposure" goal |
| Private Endpoint | `pe-secure-internal-platform` (sub-resource: `blob`), in `snet-pe` | Gives the storage account a private IP inside the VNet |
| Private DNS Zone | `(New) privatelink.blob.core.windows.net`, linked to the VNet | Without this, the storage account's DNS name would still resolve to its public IP from inside the VNet — the DNS zone is what makes name resolution return the private IP *only* for clients inside this VNet (DNS split-horizon) |
| Network routing | Microsoft network routing | Keeps traffic on Microsoft's private backbone as long as possible, consistent with the "stay inside Microsoft's network" goal |

> 📌 **Defense in depth, not a substitute:** the Private Endpoint controls *where*
> traffic can come from (network isolation). It does not by itself control *who*
> is authorized once inside the network — that's handled separately through
> Entra ID + RBAC (see Security section below). Both layers were deliberately
> combined rather than relying on just one.

### Security — identity-only authentication

| Setting | Value | Reasoning |
|---|---|---|
| Require secure transfer (HTTPS) | **Enabled** | Initially disabled by mistake, then corrected — this isn't an optional REST API setting, it governs *all* traffic to the account, including normal blob access. Disabling it would allow unencrypted HTTP |
| Allow blob anonymous access | Disabled | No anonymous access to containers under any circumstance |
| Allow storage account key access | **Disabled** | Deliberately removes the access-key authentication path entirely — forces all access through Microsoft Entra ID, no shared-key "back door" |
| Default to Microsoft Entra authorization in the Azure portal | Enabled | Keeps the Portal's own access consistent with the Entra-only authentication model |
| Minimum TLS version | 1.2 | Current minimum acceptable standard |
| Permitted scope for copy operations | Same Microsoft Entra tenant | "Same VNet" was considered but rejected — it would only matter if restricting copies specifically to VNet-based endpoints, which isn't the current scenario |
| Microsoft Defender for Storage | Disabled | Paid threat-detection layer; not justified for a lab account with no real sensitive data |

### Data protection

Point-in-time restore, blob/container/file-share soft delete, versioning, change
feed, and version-level immutability were all **deliberately left disabled**.

These protect against *accidental* data loss/modification — valuable when data
has real business value (and required in real organizations subject to GDPR
retention rules), but unnecessary for disposable test content. Can be revisited
later (e.g. to practice these specific AZ-104 storage topics) without
architectural impact.

### Encryption

Microsoft-managed keys (MMK), infrastructure encryption disabled — same
reasoning as VM "encryption at host": data at rest is already encrypted by
default; the extra layer protects against very specific threat models not
relevant to a non-production lab.

### Tags

`project=secure-internal-platform`, `environment=lab` — applied to both the
Storage Account and the Private Endpoint (not re-applied to the Virtual
Network, which already carries its own tags from creation).
