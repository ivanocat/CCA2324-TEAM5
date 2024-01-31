variable "rules" {
  type = list(any)
  default = [
    {
      name                                     = "AWS-AWSManagedRulesCommonRuleSet"
      priority                                 = 0
      managed_rule_group_statement_name        = "AWSManagedRulesCommonRuleSet"
      managed_rule_group_statement_vendor_name = "AWS"
      metric_name                              = "AWS-AWSManagedRulesCommonRuleSet"
    },
    {
      name                                     = "AWS-AWSManagedRulesLinuxRuleSet"
      priority                                 = 1
      managed_rule_group_statement_name        = "AWSManagedRulesLinuxRuleSet"
      managed_rule_group_statement_vendor_name = "AWS"
      metric_name                              = "AWS-AWSManagedRulesLinuxRuleSet"
    },
    {
      name                                     = "AWS-AWSManagedRulesSQLiRuleSet"
      priority                                 = 2
      managed_rule_group_statement_name        = "AWSManagedRulesSQLiRuleSet"
      managed_rule_group_statement_vendor_name = "AWS"
      metric_name                              = "AWS-AWSManagedRulesSQLiRuleSet"
    }
  ]
}

resource "aws_wafv2_web_acl" "waf" {
  name        = "${var.prefix}-waf"
  description = "Managed rules for PFP"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.prefix}-waf-managed-rules"
    sampled_requests_enabled   = false
  }

  dynamic "rule" {
    for_each = toset(var.rules)

    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.managed_rule_group_statement_name
          vendor_name = rule.value.managed_rule_group_statement_vendor_name
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.metric_name
        sampled_requests_enabled   = false
      }
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "Team 5"
    Project     = "CCA2324-PFP"
  }
}

resource "aws_wafv2_web_acl_association" "waf-association" {
  resource_arn = aws_alb.application_load_balancer.arn
  web_acl_arn  = aws_wafv2_web_acl.waf.arn

  depends_on = [aws_alb.application_load_balancer]
}