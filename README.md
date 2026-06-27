# Azure Secure Internal Platform

![Architecture](Architecture/Secure-Internal-Platform-Architecture-V2.png)

## Overview

This project demonstrates how to design and build a **closed, internal-only platform in Microsoft Azure** — a small-scale simulation of a corporate network where access to resources is restricted exclusively to devices and identities that belong to that environment.

The platform combines **network isolation** (Private Endpoints, NSGs, no public exposure) with **identity-based access control** (Microsoft Entra ID, RBAC), and is built in stages — starting with manual provisioning in the Azure Portal, then evolving into a fully automated Infrastructure-as-Code workflow.

This project is also being used as **hands-on practice for the Microsoft AZ-104 (Azure Administrator Associate) certification**, deliberately covering its core domains: identity & governance, storage, compute, networking, and monitoring.

## Status

🚧 In progress — Phase 1 (manual foundation in Azure Portal)

## Table of contents

- [Architecture](Architecture/Secure-Internal-Platform-Architecture-V2.png)
- [Configuration](docs/configuration.md)
- [Validation](docs/validation.md)

## Goal

Design and implement a secure, identity-aware internal platform using:

- Network isolation — no public exposure of internal resources
- Private access to PaaS services (Private Endpoint + Private DNS)
- Identity-based access control via Microsoft Entra ID
- Controlled administrative access (Azure Bastion, no public IPs on VMs)
- Role-based access control (RBAC) at both the VM and storage level
- Infrastructure as Code, configuration management, and CI/CD automation

## Roadmap

| Phase | Focus | Status |
|---|---|---|
| **Phase 1** | Manual foundation in the Azure Portal — VNet, Storage + Private Endpoint, Entra-joined Windows VM, Azure Bastion, RBAC validation, basic monitoring | 🚧 In progress |
| **Phase 2** | Import existing resources into Terraform, then extend the platform purely through code (Log Analytics, alerts, Azure Policy, VNet peering experiment) | ⏳ Planned |
| **Phase 3** | In-guest configuration with Ansible — hardening, software baseline, audit logging | ⏳ Planned |
| **Phase 4** | CI/CD pipeline with GitHub Actions — automated `terraform plan`/`apply` via OIDC federation | ⏳ Planned |
