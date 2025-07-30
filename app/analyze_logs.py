import random

def analyze(log_type="cpu"):
    if log_type == "cpu":
        spike = random.choice([True, False])
        if spike:
            return "Anomaly detected: CPU spike"
        else:
            return "All clear: CPU normal"
    return "Log type not supported"