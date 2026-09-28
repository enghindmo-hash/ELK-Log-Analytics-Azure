import json
import sys
from elasticsearch import Elasticsearch

def connect_elk():
    try:
        es = Elasticsearch(
            "http://localhost:9200",
        )
        if es.ping():
            print("✅ Connected to Elasticsearch Successfully!")
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
    print("🧠 Post-Processing Engine: Querying & Injecting Recommendations")
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
        print(f"⚠️ Error fetching from index: {e}. Please ensure dynamic index maps exist.")
        return
    
    if not hits:
        print("🟢 No raw unanalyzed logs found in Elasticsearch. System secure.")
        return

    print(f"🔍 Found {len(hits)} raw events waiting for Cyber investigation...")

    for doc in hits:
        doc_id = doc['_id']
        source = doc['_source']
        
        status = source.get("status_code", source.get("code", 0))
        message = source.get("message", "")
        ip = source.get("source_ip", "10.0.0.25")
        user = source.get("username", "attacker")
        service = source.get("service", "mysql")
        
        updated_fields = {}
        
        if status == 403 or "Unauthorized" in message:
            updated_fields["log_type"] = "SECURITY"
            updated_fields["severity"] = "CRITICAL"
            updated_fields["recommendation"] = f"Review and consider isolating the source IP {ip} through Azure NSG rules. Investigate account security for user '{user}'."
            print(f"🔴 Action: Injected Security Alert Recommendation to Event ID: {doc_id}")
            
        elif status == 500 or "failed" in message:
            updated_fields["log_type"] = "INFRASTRUCTURE"
            updated_fields["severity"] = "ERROR"
            updated_fields["recommendation"] = f"Investigate the database service '{service}' and consider restarting the container via Docker Compose if required."
            print(f"🟠 Action: Injected Infrastructure Repair Recommendation to Event ID: {doc_id}")
            
        elif status == 200:
            updated_fields["log_type"] = "HEALTH_CHECK"
            updated_fields["severity"] = "INFO"
            updated_fields["recommendation"] = "Routine performance verification completed. System operation within parameters."
            print(f"🟢 Action: Verified stable infrastructure health status.")

        if updated_fields:
            es.update(
                index=doc['_index'],
                id=doc_id,
                body={"doc": updated_fields}
            )

    print("====================================================")
    print("🎉 Enrichment Completed Successfully! Recommendations live in Kibana.")
    print("====================================================")

if __name__ == "__main__":
    enrich_and_analyze_logs()
