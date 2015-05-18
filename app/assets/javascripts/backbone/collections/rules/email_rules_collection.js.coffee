TuringEmailApp.Collections.Rules ||= {}

class TuringEmailApp.Collections.Rules.EmailRulesCollection extends TuringEmailApp.Collections.BaseCollection
  model: TuringEmailApp.Models.Rules.EmailRule
  url: "/api/v1/email_rules"
