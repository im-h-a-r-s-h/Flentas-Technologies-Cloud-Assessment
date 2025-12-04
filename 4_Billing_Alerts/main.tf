
provider "aws" {
  region = "us-east-1"
}

# Note: Billing data is available in us-east-1 only for most accounts.
# Estimated Charges metric is in AWS/Billing namespace

variable "email_address" {
  type    = string
  default = ""
  description = "Email address to receive billing alerts"
}

variable "threshold_usd" {
  type    = number
  default = 2.0
  description = "USD threshold for billing alarm"
}

variable "monthly_budget_limit" {
  type    = number
  default = 20.0
  description = "Monthly budget limit in USD"
}

variable "prefix" {
  type    = string
  default = "Harsh_Gupta_"
}

# SNS Topic for billing alerts
resource "aws_sns_topic" "billing_alerts" {
  name = "${var.prefix}billing-alerts"
  tags = { Name = "${var.prefix}billing-alerts" }
}

# SNS Topic Subscription (Email)
resource "aws_sns_topic_subscription" "billing_alerts_email" {
  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = var.email_address
  
  lifecycle {
    ignore_changes = [endpoint_auto_confirms]
  }
}

# CloudWatch Metric Alarm - Estimated Charges (USD)
# This monitors total estimated charges across all services
resource "aws_cloudwatch_metric_alarm" "billing_usd" {
  alarm_name          = "${var.prefix}billing-alarm-usd"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  statistic           = "Maximum"
  period              = "21600" # 6 hours = 4 times daily
  threshold           = var.threshold_usd
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    Currency = "USD"
  }
  
  alarm_description = "Alert when estimated monthly charges exceed USD ${var.threshold_usd}"
  alarm_actions     = [aws_sns_topic.billing_alerts.arn]
  
  tags = { Name = "${var.prefix}billing-alarm-usd" }
}

# AWS Budgets - Monthly Budget
resource "aws_budgets_budget" "monthly" {
  name              = "${var.prefix}monthly-budget"
  budget_type       = "MONTHLY"
  limit_amount      = var.monthly_budget_limit
  limit_unit        = "USD"
  time_period_start = "2025-01-01_00:00"
  time_period_end   = "2087-12-31_23:59"
  
  cost_filters = {
    Service = ["Amazon Elastic Compute Cloud - Compute"]
  }
  
  notifications {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "FORECASTED"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_frequency     = "DAILY"
  }
  
  notifications {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_frequency     = "DAILY"
  }
  
  cost_filters = {
    Service = ["EC2"]
  }
}

# AWS Budgets - Free Tier Usage Alert
resource "aws_budgets_budget" "free_tier" {
  name              = "${var.prefix}free-tier-usage"
  budget_type       = "FREE_TIER"
  limit_amount      = "0"  # Alert on any usage beyond free tier
  limit_unit        = "USD"
  time_period_start = "2025-01-01_00:00"
  time_period_end   = "2087-12-31_23:59"
  
  notifications {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    threshold                  = 0
    threshold_type             = "ABSOLUTE_VALUE"
    notification_frequency     = "DAILY"
  }
}

# CloudWatch Dashboard for Billing Monitoring
resource "aws_cloudwatch_dashboard" "billing" {
  dashboard_name = "${var.prefix}billing-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Billing", "EstimatedCharges", { stat = "Maximum" }]
          ]
          period = 21600
          stat   = "Maximum"
          region = "us-east-1"
          title  = "Estimated Monthly Charges (USD)"
          yAxis = {
            left = {
              min = 0
              max = var.monthly_budget_limit * 1.5
            }
          }
        }
      }
    ]
  })
}

# Output for reference
output "sns_topic_arn" {
  value       = aws_sns_topic.billing_alerts.arn
  description = "SNS Topic ARN for billing alerts"
}

output "monthly_budget_limit" {
  value       = var.monthly_budget_limit
  description = "Monthly budget limit"
}

output "billing_alarm_name" {
  value       = aws_cloudwatch_metric_alarm.billing_usd.alarm_name
  description = "Name of the billing alarm"
}

output "dashboard_url" {
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=${aws_cloudwatch_dashboard.billing.dashboard_name}"
  description = "URL to CloudWatch Billing Dashboard"
}
