from flask import Flask, jsonify
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

@app.route('/predict')
def predict():
    # Simulate dummy prediction
    score = round(random.uniform(0.1, 0.99), 2)
    print(f"Prediction score: {score}")
    
    # Emit metric
    emit_prediction_metric(score)
    
    return jsonify({
        "status": "success",
        "prediction_score": score
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
