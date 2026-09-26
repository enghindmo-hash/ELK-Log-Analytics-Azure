# Internal Log Analytics and Search Platform Based on ELK Stack

A secure, centralized log management and analytics platform deployed on an **Azure VM** using **Docker Compose**. This platform is designed to securely aggregate, parse, and visualize infrastructure and application logs.

## 🚀 Features & Architecture Implemented
- **Centralized Logging:** Powered by Elasticsearch, Logstash, and Kibana (ELK Stack).
- **End-to-End Security:** Strict HTTPS/TLS encryption configured across Elasticsearch nodes.
- **Certificate Management:** Configured built-in Certificate Authority (CA) and SSL certificates for secure component bindings.
- **Secure Authentication:** Kibana is integrated using a secure Service Account Token with encryption keys preserved in environments.
- **Optimized Pipeline:** Single pipeline execution in Logstash listening on Port 5000 with strict deduplication rules.

---

## 🔍 Validation & Troubleshooting Use Cases
The platform's capability to process, filter, and alert against infrastructure events was verified by executing real-time log simulation attacks via Logstash (`Port 5000`):

### 1. Verification of Log Flow
Successfully validated end-to-end data ingestion by sending structural tests into the ingestion pipeline, verifying successful storage within automated dynamic daily indices (`elk-logs-*`).

### 2. Unauthorized Access Detection (Use Case 1)
Simulated security threats involving access violations:
- **Payload:** `{"message": "Unauthorized access attempt detected", "status": "error", "user": "attacker", "code": 403}`
- **Behavior:** Successfully identified in Kibana and flagged as an `error` state under code `403`.

### 3. Critical Infrastructure Failure (Use Case 2)
Simulated service outages across application dependencies:
- **Payload:** `{"message": "Database connection failed", "status": "critical", "service": "mysql", "code": 500}`
- **Behavior:** Logstash processed and routed the alarm instantly to Kibana, marking it with a `critical` status severity.

---

## 📊 Interactive Dashboards
An interactive monitoring dashboard (**Project Logs Dashboard**) was created inside Kibana containing structured visualizations:
- **Status Distribution Chart:** A precise Pie Chart dynamically breaking down total log flows into calculated metrics (`testing` vs `error` vs `critical`).
- **Real-time Ingestion Metrics:** Live tracking filters powered by Kibana Query Language (KQL) allowing administrators to filter active production threats instantly via:
  ```kql
  status : "error" or status : "critical"
  ```

---

## 🔒 Security Compliance
- All sensitive credentials, tokens, deployment `.env` configurations, and SSH private keys are explicitly stripped and protected via `.gitignore` to ensure **Zero Leakage** to public or private version control systems.
