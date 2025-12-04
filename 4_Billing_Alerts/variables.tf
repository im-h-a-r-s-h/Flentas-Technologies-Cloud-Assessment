
variable "prefix" {
  type    = string
  default = "Harsh_Gupta_"
  description = "Resource name prefix"
}

variable "threshold_usd" {
  type    = number
  default = 2.0
  description = "USD threshold for CloudWatch billing alarm"
}

variable "monthly_budget_limit" {
  type    = number
  default = 20.0
  description = "Monthly budget limit in USD for AWS Budgets"
}

variable "email_address" {
  type    = string
  default = "harsh.gupta@example.com"
  description = "Email address for SNS notifications"
}
