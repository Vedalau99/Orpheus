resource "aws_cloudwatch_log_group" "orpheus_logs" {
  name              = "/ecs/orpheus-app"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
    ignore_changes = [tags] # optional
  }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "Orpheus-HighCPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "This alarm triggers if CPU usage is above 70% for 2 minutes."
  dimensions = {
    ClusterName = "orpheus-cluster"
    ServiceName = "orpheus-service"
  }
}

resource "aws_cloudwatch_dashboard" "orpheus_dashboard" {
  dashboard_name = "Orpheus-Metrics"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0,
        y    = 0,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", "<your-cluster-name>", "ServiceName", "<your-service-name>"]
          ],
          period = 60,
          stat   = "Average",
          region = var.aws_region,
          title  = "CPU Utilization - Orpheus"
        }
      }
    ]
  })
}
