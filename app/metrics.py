import boto3
import random
import time
import os

cloudwatch = boto3.client('cloudwatch', region_name=os.environ.get("AWS_REGION", "us-east-1"))

NAMESPACE = "OrpheusApp"

def publish_metric(metric_name, value, unit="Count"):
    print(f"Pushing metric → {metric_name}: {value} {unit}")
    cloudwatch.put_metric_data(
        Namespace=NAMESPACE,
        MetricData=[
            {
                'MetricName': metric_name,
                'Value': value,
                'Unit': unit
            },
        ]
    )

def simulate_metrics():
    while True:
        latency = round(random.uniform(50, 300), 2)  # in ms
        req_count = random.randint(100, 500)
        error_rate = random.randint(0, 10)

        publish_metric("AppLatency", latency, "Milliseconds")
        publish_metric("RequestsPerMinute", req_count)
        publish_metric("ErrorRate", error_rate)

        time.sleep(60)  # Push every 1 min

if __name__ == "__main__":
    simulate_metrics()
