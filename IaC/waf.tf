variable "rules" {
  type = list(any)
  default = [
    {
      name                                     = "AWS-AWSManagedRulesCommonRuleSet"
      priority                                 = 0
      managed_rule_group_statement_name        = "AWSManagedRulesCommonRuleSet"
      managed_rule_group_statement_vendor_name = "AWS"
      metric_name                              = "AWS-AWSManagedRulesCommonRuleSet"
      rule_action_override_allow               = ["EC2MetaDataSSRF_BODY", "SizeRestrictions_BODY"]
    },
    {
      name                                     = "AWS-AWSManagedRulesLinuxRuleSet"
      priority                                 = 1
      managed_rule_group_statement_name        = "AWSManagedRulesLinuxRuleSet"
      managed_rule_group_statement_vendor_name = "AWS"
      metric_name                              = "AWS-AWSManagedRulesLinuxRuleSet"
      rule_action_override_allow               = []
    },
    {
      name                                     = "AWS-AWSManagedRulesSQLiRuleSet"
      priority                                 = 2
      managed_rule_group_statement_name        = "AWSManagedRulesSQLiRuleSet"
      managed_rule_group_statement_vendor_name = "AWS"
      metric_name                              = "AWS-AWSManagedRulesSQLiRuleSet"
      rule_action_override_allow               = []
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

          // Overriding the default value of specific rules
          dynamic "rule_action_override" {
            for_each = toset(rule.value.rule_action_override_allow)

            content {
              name = rule_action_override.value
              action_to_use {
                allow {}
              }
            }
          }
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