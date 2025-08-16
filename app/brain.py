import requests
import os

HF_TOKEN = os.getenv("HF_TOKEN")  # Loaded from env, not hardcoded

API_URL = "https://api-inference.huggingface.co/models/distilgpt2"

def query(prompt: str):
    headers = {"Authorization": f"Bearer {HF_TOKEN}"}
    payload = {"inputs": prompt, "parameters": {"max_new_tokens": 50}}
    response = requests.post(API_URL, headers=headers, json=payload)
    return response.json()

def generate_suggestion(metrics, logs, analysis):
    prompt = f"""System report:
    Metrics: {metrics}
    Logs: {logs}
    Analysis: {analysis}
    Suggest next action in one sentence:"""

    result = query(prompt)
    if isinstance(result, list) and "generated_text" in result[0]:
        return result[0]["generated_text"]
    else:
        return f"Error: {result}"
