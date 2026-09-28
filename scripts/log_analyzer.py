import json
import urllib3
from elasticsearch import Elasticsearch

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def connect_elk():
    try:
        es = Elasticsearch(
            "https://localhost:9200",
            basic_auth=("elastic", "SFELK@26Secure"),
            verify_certs=False
        )
        if es.ping():
            print("✅ Connected to Elasticsearch via HTTPS Successfully!")
            return es
    except Exception as e:
        print(f"❌ Connection Failed: {e}")
        return None

def enrich_and_analyze_logs():
    es = connect_elk()
    if not es:
        print("❌ Cannot proceed without Elasticsearch connection.")
        return

    index_name = "elk-logs-*"
    print("====================================================")
    print("🧠 Post-Processing Engine: Ingesting & Injecting Recommendations")
    print("====================================================")
    
    query = {
        "query": {
            "bool": {
                "must_not": {
                    "exists": {
                        "field": "recommendation"
                    }
                }
            }
        },
        "size": 50
    }
    
    try:
        response = es.search(index=index_name, body=query)
        hits = response['hits']['hits']
    except Exception as e:
        print(f"⚠️ Error: {e}")
        return
    
    if not hits:
        print("🟢 No raw unanalyzed logs found in Elasticsearch. System secure.")
        return

    print(f"🔍 Found {len(hits)} raw logs waiting for cyber investigation...")

    for doc in hits:
        doc_id = doc['_id']
        source = doc['_source']
        
        status = source.get("status_code", source.get("code", source.get("status", 0)))
        message = source.get("message", source.get("message.keyword", ""))
        ip = source.get("source_ip", "10.0.0.25")
        user = source.get("username", "attacker")
        service = source.get("service", "mysql")
        
        updated_fields = {}
        
        if str(status) == "403" or "Unauthorized" in str(message):
            updated_fields["log_type"] = "SECURITY"
            updated_fields["severity"] = "CRITICAL"
            updated_fields["recommendation"] = f"Review and consider isolating the source IP {ip} through Azure NSG rules. Investigate account locked for user '{user}'."
            print(f"🔴 Action: Injected Security Recommendation to Event ID: {doc_id}")
            
        elif str(status) == "500" or "failed" in str(message):
            updated_fields["log_type"] = "INFRASTRUCTURE"
            updated_fields["severity"] = "ERROR"
            updated_fields["recommendation"] = f"Investigate core dependency '{service}'. Consider automated container restart via Docker Compose."
            print(f"🟠 Action: Injected Infrastructure Repair Recommendation to Event ID: {doc_id}")
            
        elif str(status) == "200" or "success" in str(message).lower():
            updated_fields["log_type"] = "HEALTH_CHECK"
            updated_fields["severity"] = "INFO"
            updated_fields["recommendation"] = "Routine system operation verified. Telemetry parameters healthy."
            print(f"🟢 Action: Verified stable infrastructure health status.")

        if updated_fields:
            es.update(index=doc['_index'], id=doc_id, body={"doc": updated_fields})

    print("====================================================")
    print("🎉 Enrichment Completed Successfully! Fields injected into Elasticsearch.")
    print("====================================================")

if __name__ == "__main__":
    enrich_and_analyze_logs()
