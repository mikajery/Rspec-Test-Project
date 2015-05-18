TuringEmailApp.Models.Reports ||= {}

class TuringEmailApp.Models.Reports.RecommendedRulesReport extends Backbone.Model
  url: "/api/v1/email_rules/recommended_rules"

  validation:
    rules_recommended:
      required: true
