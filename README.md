🎯 Purpose of the App
Orpheus is a smart DevOps monitoring companion that detects anomalies in your cloud app’s performance or resource usage and suggests intelligent scaling or remediation actions using AI or predefined logic.

🧠 Why It Exists
In real-world DevOps teams:

Infrastructure breaks silently until someone sees it on a dashboard.

Logs pile up — but few have time to read and interpret them.

Scaling decisions are reactive, not proactive.

Root cause analysis is manual and slow.

Orpheus helps solve this.
It monitors logs or metrics from your app, uses lightweight AI or logic to understand issues, and suggests what to do next — like scaling, restarting, alerting, etc.

💡 Real-World Use Cases
Use Case	What AutoScaleIQ Does
High CPU usage on EC2	Suggests scaling out or moving to larger instance
Memory leak in logs	Detects pattern, recommends restart or alerts Dev
Application downtime detected	Suggests rollout rollback or redeploy
Spikes in 5xx errors in logs	Points to possible backend or DB issues
Failed deployment via GitHub Actions	Logs error and recommends fix or retry

📦 How It Works (Simple Flow)
App is deployed on AWS via Terraform.

Logs and metrics are collected via CloudWatch.

An AI or logic-based analyzer (Python script or tiny LLM) checks logs periodically.

If patterns match known issues or thresholds, it:

Suggests an action (scale up, restart, alert).

Optionally, triggers a Lambda or GitHub Action for automation.

You see recommendations in logs, email, or dashboard.

🧱 Tech Stack used
Layer	Tools
Provisioning	Terraform (to create EC2, CloudWatch, IAM, etc.)
App Hosting	Dockerized app on EC2 or App Runner
Monitoring	CloudWatch Logs and Metrics
CI/CD	GitHub Actions
AI/Logic	Python script with rule-based logic or basic LLM
Automation	Optional: AWS Lambda for remediation

🔥 Why It’s Powerful
Shows DevOps workflows

Demonstrates AI-assisted tooling

Includes full IaC, GitOps, CI/CD, and monitoring

Easy to present in demos 

