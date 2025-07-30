from flask import Flask, jsonify
from analyze_logs import analyze
import random
import boto3
import os

app = Flask(__name__)

# Initialize CloudWatch client
cloudwatch = boto3.client('cloudwatch', region_name=os.getenv('AWS_REGION', 'us-east-1'))

def emit_prediction_metric(score):
    """Send prediction score to CloudWatch"""
    try:
        cloudwatch.put_metric_data(
            Namespace='OrpheusApp',
            MetricData=[
                {
                    'MetricName': 'PredictionScore',
                    'Dimensions': [
                        {'Name': 'ServiceName', 'Value': 'OrpheusPredictor'}
                    ],
                    'Unit': 'None',
                    'Value': score
                }
            ]
        )
        print(f"Sent metric to CloudWatch: {score}")
    except Exception as e:
        print(f"Error sending metric to CloudWatch: {e}")

@app.route('/')
def home():
    return jsonify({"message": "Welcome to Orpheus Monitoring App"})
@app.route('/predict', methods=['GET'])
def predict():
    log_type = request.args.get('log_type', 'cpu')
    result = analyze(log_type)
    return jsonify({"result": result})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
