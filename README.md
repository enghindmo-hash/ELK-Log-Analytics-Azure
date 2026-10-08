# SentinelFour | Internal Log Analytics and Search Platform Based on ELK Stack

**SDA Cloud Computing Bootcamp Capstone Project**  
**Team:** SentinelFour  
**Platform:** Microsoft Azure · Ubuntu Linux · Terraform · Docker Compose · Elasticsearch · Logstash · Kibana

## Overview

SentinelFour is a centralized log analytics and search platform hosted on a Linux virtual machine in Microsoft Azure. It collects structured application, infrastructure, and security-related test events through Logstash, indexes them in Elasticsearch, and provides interactive exploration and visualizations in Kibana.

The project demonstrates a practical internal troubleshooting and operational monitoring workflow. **It is not intended to be a full enterprise Security Information and Event Management (SIEM) system.** Demonstration events are simulated; the project does not claim live enterprise threat detection.

## Objectives

- Provision a repeatable Azure environment using Terraform.
- Deploy and operate Elasticsearch, Logstash, and Kibana with Docker Compose.
- Ingest structured log events and store searchable historical data.
- Visualize log trends, failures, and security-related events through Kibana.
- Support field-based searches and filters for investigation and troubleshooting.
- Apply practical access controls, credential protection, and host security measures.
- Document deployment, validation, troubleshooting, and reproducibility.

## Architecture

```text
              Microsoft Azure — Resource Group
  ┌───────────────────────────────────────────────────┐
  │ Virtual Network → Subnet → Network Security Group │
  │                        │                          │
  │               Ubuntu Linux VM                     │
  │                        │                          │
  │                 Docker Compose                    │
  │                        │                          │
  │  Simulated JSON logs → Logstash (TCP 5000)        │
  │                           │                       │
  │                           ▼                       │
  │                   Elasticsearch                   │
  │                  (HTTPS, TCP 9200)                │
  │                           │                       │
  │                           ▼                       │
  │                        Kibana                     │
  │                      (TCP 5601)                   │
  │                                                   │
  │     Authorized workstation ── SSH tunnel ────────┘
  └───────────────────────────────────────────────────┘
```

**Component responsibilities**

| Component | Role |
|---|---|
| Terraform | Provisions Azure infrastructure as code |
| Azure Linux VM | Hosts the containerized stack |
| Docker Compose | Defines and manages the ELK services, networks, and persistent storage |
| Logstash | Receives JSON events, parses timestamps when present, and forwards events |
| Elasticsearch | Indexes and searches the ingested log records |
| Kibana | Provides Discover, KQL search, and dashboards |
| Bash | Supports host setup and operational automation; see the automation status below |

## Technology Stack

| Layer | Technology |
|---|---|
| Cloud | Microsoft Azure |
| Infrastructure as Code | Terraform with AzureRM provider |
| Host | Ubuntu Server 22.04 LTS |
| Containers | Docker Engine and Docker Compose |
| Log storage and search | Elasticsearch 9.5.4 |
| Log ingestion | Logstash 9.5.4 |
| Visualization | Kibana 9.5.4 |
| Automation | Bash |
| Version control | Git and GitHub |

## Azure Infrastructure

The Terraform configuration provisions the core hosting and networking resources:

- Azure Resource Group
- Virtual Network (VNet) and subnet
- Network Security Group (NSG) and subnet association
- Public IP address and network interface
- Ubuntu Linux virtual machine with SSH public-key authentication

The environment uses a **single-node deployment**, appropriate for a bootcamp capstone and functional demonstration. It does not provide high availability or distributed-cluster fault tolerance.

> **Infrastructure security note:** Restrict inbound SSH to explicitly authorized public IP addresses before considering the network-hardening work complete. See [SSH Port 22 Hardening](#ssh-port-22-hardening--pending-final-verification).

## Repository Layout

The following paths describe the main project components. Check the repository before publishing to ensure all listed files exist and match their documented behavior.

```text
ELK-Log-Analytics-Azure/
├── README.md
├── terraform/
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   └── outputs.tf
├── docker/
│   └── docker-compose.yml
├── logstash/
│   └── pipeline/
│       └── logstash.conf
└── scripts/                    # Include only if tracked and validated
    └── setup.sh
```

The `.env` file and certificate private keys are runtime secrets, **not** repository deliverables. An environment-variable template and certificate provisioning instructions should be supplied for a reproducible deployment, without publishing credentials.

## Deployment and Startup

### Prerequisites

- Authorized access to an Azure subscription and permission to provision the required resources.
- Terraform and Azure CLI on the provisioning workstation.
- An SSH key pair; the VM must contain the authorized public key.
- Docker Engine and the Docker Compose plugin installed on the Ubuntu VM.
- Correctly generated TLS certificates, a Kibana service-account token, and a local `.env` file containing required variables.

### 1. Provision Azure infrastructure

From the `terraform/` directory, after reviewing variables, credentials, region, and expected costs:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

**Do not** commit Terraform state files, credentials, or private SSH keys. Review `terraform plan` before applying changes, especially when collaborating on the same Azure resources.

### 2. Connect to the VM

From the local workstation, using your own SSH key and the VM's current public IP:

```bash
ssh -i ~/.ssh/<your-private-key> <vm-admin>@<vm-public-ip>
```

### 3. Prepare runtime configuration

On the VM, create the local `.env` file and configure the variables required by the Compose file. At minimum, the current configuration expects:

```dotenv
ELASTIC_PASSWORD=<set-locally>
KIBANA_SERVICE_ACCOUNT_TOKEN=<set-locally>
KIBANA_ENCRYPTION_KEY=<set-locally>
```

These placeholders are **not** real secrets. Do not copy them as actual values. Configure the required CA and service certificates according to the Compose volume mounts. The Kibana service-account token must be valid in the **currently running Elasticsearch instance**.

> **Known configuration check:** A prior startup reported `KIBANA_ENCRYPTION_KEY` as unset. Verify that this variable is present and valid before declaring the final configuration complete. The security and reporting encryption keys may require additional settings if their related features are used.

### 4. Start the stack

Run from the repository root on the VM:

```bash
docker compose --env-file .env -f docker/docker-compose.yml up -d
```

**Important:** The Compose file is in `docker/`, while `.env` is in the repository root. Specify both paths explicitly to prevent Compose from starting services with empty environment variables.

### 5. Verify container status

```bash
docker compose --env-file .env -f docker/docker-compose.yml ps
```

All three services should be running. A container being `Up` does **not** guarantee that its application is healthy or authenticated.

Check logs when necessary:

```bash
docker logs elasticsearch --tail 30
docker logs logstash --tail 30
docker logs kibana --tail 30
```

### 6. Access Kibana securely

The project binds Kibana to the VM loopback interface rather than publishing its port directly to the internet. Open an SSH tunnel **from your local computer**:

```bash
ssh -i ~/.ssh/<your-private-key> -L 5601:127.0.0.1:5601 <vm-admin>@<vm-public-ip>
```

Keep that SSH session open, then visit:

```text
http://127.0.0.1:5601
```

If port `5601` is already in use on your workstation, choose a different **local** port, for example `5602:127.0.0.1:5601`, and browse to `http://127.0.0.1:5602`. This changes only the local forwarding port, not the Azure NSG rule or Kibana's internal port.

## Log Ingestion Pipeline

The current Logstash pipeline listens for JSON events over TCP port **5000**, parses an optional ISO 8601 `timestamp` into `@timestamp`, and forwards the events over HTTPS to Elasticsearch.

**Index pattern:** `elk-logs-*` (daily indices using `elk-logs-YYYY.MM.dd`).

The pipeline's current TCP input is bound to `127.0.0.1` on the VM through Docker Compose. The examples below are therefore intended to be sent **from the VM itself**, not directly from an external host.

### Example: unauthorized access event

```json
{
  "message": "Unauthorized access attempt detected",
  "log_type": "SECURITY",
  "severity": "ERROR",
  "status": "error",
  "user": "attacker",
  "service": "web-auth",
  "code": 403
}
```

### Example: application/database failure

```json
{
  "message": "Database connection failed",
  "log_type": "APPLICATION",
  "severity": "CRITICAL",
  "status": "critical",
  "service": "mysql",
  "code": 500
}
```

These are **illustrative simulated payloads**. Confirm exact field names and values against the data actually ingested in the final demonstration. The `code` field is used for HTTP-style status-code filtering; `severity` represents event severity.

### Send a local test event

On the VM, with `nc` (netcat) installed:

```bash
printf '%s\n' '{"message":"README pipeline validation","log_type":"APPLICATION","severity":"ERROR","service":"demo","code":500}' | nc -q 1 127.0.0.1 5000
```

Then check Kibana **Discover** with data view `elk-logs-*` and an appropriate time range. This confirms ingestion, indexing, and retrieval rather than merely container startup.

## Kibana Dashboard and Search

The final demonstration dashboard is titled **ELK Security & Operations Dashboard** and includes:

- Total Logs
- Security Events
- Application Errors
- Critical Events
- Events by Severity
- Logs Over Time
- Security Recommendations
- Application & Infrastructure Events

Kibana supports interactive time-range selection and field-based filtering. Example KQL queries:

```kql
log_type.keyword:"SECURITY"
```

```kql
log_type.keyword:"APPLICATION" AND severity.keyword:"ERROR"
```

```kql
severity.keyword:"CRITICAL"
```

```kql
code:403
```

> If a visualization appears empty, first verify the **global time range** and the visualization's own filters. The demo's older simulated events may require a broader time window, such as **Last 30 days**.

## Validation and Demonstrated Use Cases

| Test | Expected verification |
|---|---|
| Infrastructure | Terraform provisions the required Azure networking and VM resources |
| Service deployment | Elasticsearch, Logstash, and Kibana start with Docker Compose |
| Log ingestion | A simulated JSON event reaches Logstash and is indexed in Elasticsearch |
| Search | Events can be found in Kibana Discover using the `elk-logs-*` data view |
| Unauthorized access scenario | A simulated `403` event is searchable and visible in Kibana |
| Failure scenario | A simulated `500` event is searchable and visible in Kibana |
| Visualization | Dashboard panels display log counts, trends, and event categories |
| Access control | Kibana is accessed through SSH port forwarding instead of a public `5601` endpoint |

Validation should be supported with screenshots or a demo recording. Simulated events establish pipeline functionality; they are not evidence of a live attack, automated threat detection, or an actual production database outage.

## Security Controls

| Control | Description | Status / verification |
|---|---|---|
| SSH public-key authentication | VM administration through authorized SSH keys; password authentication disabled | Implemented in the known VM configuration |
| Elasticsearch HTTPS | TLS-enabled Elasticsearch HTTP endpoint | Implemented in the known Compose configuration |
| Kibana service authentication | Kibana authenticates to Elasticsearch using a service-account token | Implemented; ensure the current token remains valid |
| Secret separation | Runtime secrets stored outside tracked source files | Verify Git tracking and history before final release |
| Loopback-only service ports | Elasticsearch `9200`, Kibana `5601`, and Logstash input ports mapped to `127.0.0.1` | Implemented in the known Compose configuration |
| SSH tunnel | Access Kibana through authenticated SSH forwarding | Demonstrated |
| Azure NSG SSH restriction | Limit inbound TCP `22` to approved source IPs | **Pending final hardening and team verification** |
| OS updates / hardening | Keep host security updates current | Recheck before submission |
| Log retention | Document index retention policy and disk management | Verify or document as an operational limitation |

**Security note:** `.gitignore` is not a secret scanner and cannot undo secrets already committed. Inspect the tracked files and Git history. Rotate any credentials or tokens previously exposed in logs, screenshots, messages, or commits.

### SSH Port 22 Hardening — Pending Final Verification

The VM requires SSH access for administration and the Kibana tunnel. **Do not close port 22 entirely.** Instead, restrict the Azure NSG inbound rule for **TCP 22** so that only explicitly approved public source IP addresses can connect.

**Final hardening checklist:**

1. Confirm the current public IPv4 address of each authorized teammate and convert each address to a `/32` CIDR entry.
2. Update the Terraform-managed NSG SSH rule to use an explicit `source_address_prefixes` allowlist rather than `*`.
3. Run `terraform plan` and review the proposed NSG changes with the team.
4. Keep an existing working SSH session open while applying the change; ensure Azure administrative recovery access is available.
5. Run `terraform apply` only after the team approves the allowlist.
6. **Test a new SSH connection and a Kibana SSH tunnel for every authorized teammate before closing existing sessions.**
7. Record the verification date and confirm that the README status can be changed to **Implemented and verified**.

Example Terraform rule fragment (adapt to the actual resource and avoid creating a duplicate conflicting rule):

```hcl
source_address_prefixes = [
  "<teammate-1-public-ip>/32",
  "<teammate-2-public-ip>/32"
]
```

Home and mobile public IPs may change. Update the allowlist through Terraform when an authorized teammate's source address changes. Do not manually change the NSG in the Azure Portal without reconciling that change with Terraform state and configuration.

**Distinction:** SSH uses Azure VM **port 22**. Kibana uses VM-local **port 5601**; the SSH tunnel forwards a workstation port (such as `5601` or `5602`) to that local service. These are separate controls.

## Automation and Reproducibility

The project requirements call for Bash-supported installation, Docker setup, environment preparation, stack startup, health checks, and troubleshooting. Before declaring full automation complete, verify that the final repository contains tested scripts implementing those tasks.

A reproducible handover should include:

- Terraform configurations, variables, and provider requirements.
- A tested Bash setup script and clear execution instructions.
- The Docker Compose file and Logstash pipeline.
- A **sanitized** environment template (for example `.env.example`).
- Certificate/CA generation and placement instructions, without private keys.
- Service-token creation instructions, without token values.
- Startup, health-check, log-ingestion, and troubleshooting commands.
- Instructions to restore or recreate Kibana data views and dashboards if they are not exported as saved objects.

**Current documentation limitation:** Successful manual deployment is not, by itself, proof of complete one-command reproducibility. Confirm that the scripts and supporting templates work on a clean environment before claiming that acceptance criterion is fully satisfied.

## Troubleshooting

| Symptom | Likely cause | First check |
|---|---|---|
| `no configuration file provided` | Compose file is not in the current directory | Use `-f docker/docker-compose.yml` |
| `variable is not set` | Compose did not load the root `.env`, or a variable is missing | Use `--env-file .env` and check variable **names only** |
| Containers show `Up`, but Kibana does not load | Kibana may still be starting or cannot authenticate to Elasticsearch | `docker logs kibana --tail 30` |
| `failed to authenticate service account` | Kibana token is missing, stale, or invalid in the running Elasticsearch instance | Check service-token configuration and recreate Kibana with the correct environment |
| `Address already in use` for local `5601` | A previous SSH tunnel is already listening locally | Reuse the existing tunnel or forward local `5602` |
| Dashboard panels are empty | Time window or panel filter excludes the events | Broaden the time range; inspect Discover |
| No new logs | Input, pipeline, mapping, or Elasticsearch connection issue | Inspect Logstash logs and verify local TCP `5000` |

For service-token troubleshooting, `elasticsearch-service-tokens list` displays token **names**, not secret values. Never paste token values, passwords, `.env` contents, or private key material into issues, documentation, or screenshots.

## Operational Notes and Limitations

- The deployment is a **single Azure VM**, not a production high-availability cluster.
- Elasticsearch data is stored in a Docker named volume; deleting the volume can remove indexed data and Kibana saved objects.
- The current demonstration primarily uses **simulated structured events**. A production data-collection agent fleet is outside the demonstrated scope.
- SSH source-IP restriction must be verified before it is described as completed.
- Final log retention, backup/restore, certificate renewal, and automated health-check procedures should be documented or identified as future improvements if not implemented.
- Azure compute and storage may incur charges while provisioned. Stopping and **deallocating** the VM helps stop VM compute charges; other resources may still incur costs.
- After VM startup, check container status and start Compose if the services did not automatically restart.

## Deliverables and Evidence

Recommended submission evidence includes:

- Architecture diagram and Terraform deployment evidence.
- Docker Compose and Logstash configuration.
- Container status and health-check results.
- Screenshots of Kibana Discover and **ELK Security & Operations Dashboard**.
- KQL filters demonstrating different log categories.
- A continuous demo of login, dashboard overview, Discover, and filtering.
- Sanitized automation and deployment documentation.
- Verification that SSH port 22 is restricted to approved sources, once complete.

## Future Improvements

Potential enhancements beyond the initial capstone include automated log retention, improved health checks, dashboard export/import automation, certificate renewal workflows, additional real log sources, and automated backups. Enterprise SIEM features, advanced threat intelligence, and distributed clustering are **not required** for the initial project.

## Team

**SentinelFour** — SDA Cloud Computing Bootcamp Capstone Project.
Bdour Mufreh Alsubaie
Maram Mesjal Alotaibi
Hend Mohammad Alzara
Hadeel Kamel Aldhafeeri

---


**Project focus:** A practical, secure, reproducible foundation for internal log ingestion, search, visualization, and troubleshooting on Microsoft Azure.
