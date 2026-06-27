## Connecting to the VM via Bastion — without the Azure Portal UI

Goal: connect to `vm-workstation1` through Bastion from the local machine
(macOS) without manually clicking through the Azure Portal each time.

### Attempt 1 — `az network bastion tunnel` + native RDP client (macOS)

```bash
az network bastion tunnel \
  --name "vn-secure-internal-platform-Bastion" \
  --resource-group "rg-secure-internal-platform" \
  --target-resource-id "/subscriptions/<sub-id>/resourceGroups/rg-secure-internal-platform/providers/Microsoft.Compute/virtualMachines/vm-workstation1" \
  --resource-port 3389 \
  --port 5022 \
  --enable-mfa
```

The tunnel opened successfully (`Tunnel is ready, connect on port 5022`), but
connecting to it via Microsoft Remote Desktop (native macOS client, configured
manually with PC name `172.0.0.1:5022`) failed with **"Unable to connect" /
error 0x204**.

**Root cause:** `az network bastion tunnel` only opens a raw local
port-forward to the VM — it does not carry the Microsoft Entra ID
authentication flow through the tunnel. Without that flow, the native RDP
client has no way to complete Entra-based sign-in, so the connection is
rejected before a session can be established.

### Attempt 2 — `az network bastion rdp --enable-mfa` (the "correct" CLI command)

```bash
az network bastion rdp \
  --name "vn-secure-internal-platform-Bastion" \
  --resource-group "rg-secure-internal-platform" \
  --target-resource-id "<vm-resource-id>" \
  --enable-mfa
```

This is the command actually designed to handle Entra ID authentication and
automatically launch the native client afterward — but on macOS it failed
immediately with:

```
ImportError: cannot import name 'WinDLL' from 'ctypes'
```

**Root cause:** this is a **platform limitation, not a configuration error.**
The Azure CLI's implementation of `bastion rdp --enable-mfa` relies on
`WinDLL`, a Windows-only component used to drive the native RDP client
automatically after Entra sign-in. Microsoft's own documentation confirms
Entra-based native client connections are only supported from Windows clients
(Entra-registered, Entra-joined, or Entra hybrid-joined). **This path is not
usable from macOS at all**, regardless of how it's configured.

### What actually worked — Azure Portal, Bastion, Entra ID auth

Connecting via the Portal (`VM → Connect → Bastion`, Authentication Type:
`Microsoft Entra ID (Preview)`) succeeded once signed in with the **correct
account**.

First attempt failed with *"You can't sign in here with a personal account.
Use a work or school account instead"* — caused by entering a personal
Microsoft account (`@outlook.com`) instead of the Entra ID account that
actually has the `Virtual Machine Administrator Login` RBAC role assigned on
this VM (visible under **Access control (IAM)**). Signing in with the correct
Entra ID UPN (the same account used to log into the Azure Portal) succeeded.

> 📌 **Lesson learned:** on macOS, the Portal-based Bastion connection
> (browser, Entra ID auth) is the reliable path for this setup. The
> CLI-based native client flow for Entra ID authentication is Windows-only —
> attempting it on macOS wastes time on a problem that has no fix on this
> platform, not a misconfiguration to debug further.

### RBAC prerequisite (confirmed via Access control / IAM)

Sign-in only works once an Entra identity has one of these roles assigned,
scoped to the VM:
- `Virtual Machine Administrator Login` (full admin access)
- `Virtual Machine User Login` (standard user access)

Without this assignment, Entra ID sign-in fails regardless of which
connection method (Portal, CLI, native client) is used — this is a separate
requirement from Bastion itself working correctly.
