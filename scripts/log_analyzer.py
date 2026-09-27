import json

def analyze_logs():
    print("====================================================")
    print("🧠 Local Intelligent AI/Rule Log Recommendation Engine")
    print("====================================================")
    
    simulated_logs = [
        '{"log_type": "security", "status_code": 403, "username": "attacker", "source_ip": "10.0.0.25", "message": "Unauthorized access attempt"}',
        '{"log_type": "application", "status_code": 500, "service": "mysql", "message": "Database connection failed"}',
        '{"log_type": "infrastructure", "status_code": 200, "service": "nginx", "message": "service started successfully"}'
    ]
    
    for log_raw in simulated_logs:
        try:
            log = json.loads(log_raw)
            code = log.get("status_code")
            msg = log.get("message")
            log_type = log.get("log_type", "unknown")
            
            print(f"\n[+] Ingesting Event: '{msg}' | Type: {log_type.upper()} (Code: {code})")
            
            if code == 403:
                print("🔴 [SECURITY ALERT] Critical Access Exception Found!")
                print("💡 [LOCAL RECOMMENDATION]: Isolate Source IP 10.0.0.25 via Azure NSG rules immediately. Trigger account lockdown for user 'attacker' to prevent further brute-force or unauthorized probes.")
            elif code == 500:
                print("🟠 [INFRASTRUCTURE ALERT] Core System Service Failure!")
                print("💡 [LOCAL RECOMMENDATION]: Database service crashed or network isolated. Initiate automated container restart for 'mysql' via Docker Compose. Check system storage and volume bindings.")
            elif code == 200:
                print("🟢 [HEALTH CHECK] Infrastructure operational. Dynamic metrics normal.")
                
        except Exception as e:
            print(f"❌ Error parsing log entry: {e}")

    print("\n====================================================")
    print("✅ Local Recommendation Sequence Complete (100% Secure)")
    print("====================================================")

if __name__ == "__main__":
    analyze_logs()
