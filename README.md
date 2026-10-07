# Internal Log Analytics and Search Platform Based on ELK Stack

A centralized log management and analytics platform deployed on an **Azure Virtual Machine** using **Docker Compose**. The platform is designed to collect, process, store, search, and visualize infrastructure and application logs through the **ELK Stack**.

## 🚀 Features & Architecture Implemented

- **Centralized Logging:** Powered by Elasticsearch, Logstash, and Kibana (ELK Stack).
- **Cloud Deployment:** The ELK Stack is deployed on an **Azure Virtual Machine** using Docker Compose.
- **Log Processing Pipeline:** Logstash receives and processes incoming log events through a dedicated pipeline on **Port 5000**.
- **Structured Log Analysis:** Logs are processed into structured fields such as `status`, `user`, `service`, and `code` for analysis and filtering.
- **Secure Authentication:** Kibana is integrated with Elasticsearch using a **Service Account Token**.
- **Configuration Protection:** Sensitive credentials and environment-specific configuration are excluded from version control using `.gitignore`.

---

## 🔍 Validation & Troubleshooting Use Cases

The platform was validated using real-time **simulated log events** sent through the Logstash ingestion pipeline on `Port 5000`.

### 1. Verification of Log Flow

Successfully validated end-to-end log ingestion by sending test events through the Logstash pipeline and verifying their availability in Kibana and Elasticsearch.

The processed logs were stored using dynamic daily indices following the:

`elk-logs-*`

pattern.

### 2. Unauthorized Access Detection (Use Case 1)

A simulated unauthorized access event was used to validate the processing of security-related logs.

- **Payload:**
```json
{
  "message": "Unauthorized access attempt detected",
  "status": "error",
  "user": "attacker",
  "code": 403
}
```

- **Result:** Successfully processed and visualized in Kibana with an `error` status and HTTP code `403`.

### 3. Critical Infrastructure Failure (Use Case 2)

A simulated database failure event was used to validate the processing of critical infrastructure events.

- **Payload:**
```json
{
  "message": "Database connection failed",
  "status": "critical",
  "service": "mysql",
  "code": 500
}
```

- **Result:** Successfully processed through the Logstash pipeline and displayed in Kibana with a `critical` status and HTTP code `500`.

---

## 📊 Interactive Dashboard

An interactive monitoring dashboard (**Project Logs Dashboard**) was created in Kibana containing structured visualizations.

- **Status Distribution:** A pie chart showing the distribution of log events by status, including `testing`, `error`, and `critical`.
- **Log Monitoring:** Visual monitoring of processed events and their structured fields.
- **KQL Filtering:** Kibana Query Language (KQL) filters allow users to quickly isolate events based on their status.

**Example:**

```kql
status : "error" or status : "critical"
```

---

## 🔒 Security & Configuration

- Sensitive credentials, service tokens, `.env` configuration files, and SSH private keys are excluded from the repository using `.gitignore`.
- Secrets are not committed to version control.
- Kibana–Elasticsearch authentication is configured using a **Service Account Token**.
- Environment-specific configuration is separated from the tracked project files.

---

## 🛠️ Technologies Used

- **Microsoft Azure**
- **Elasticsearch 9.5.4**
- **Logstash 9.5.4**
- **Kibana 9.5.4**
- **Docker**
- **Docker Compose**
- **Kibana Query Language (KQL)**
- **Git / GitHub**

---

## 🎯 Project Objective

The objective of this project is to build a centralized log analytics platform that enables organizations to collect, process, search, and visualize infrastructure and application logs from a single environment.

The platform provides a foundation for **security monitoring, troubleshooting, and operational visibility** through centralized log analysis.
