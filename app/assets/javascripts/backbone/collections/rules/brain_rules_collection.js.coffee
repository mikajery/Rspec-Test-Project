TuringEmailApp.Collections.Rules ||= {}

class TuringEmailApp.Collections.Rules.BrainRulesCollection extends TuringEmailApp.Collections.BaseCollection
  model: TuringEmailApp.Models.Rules.BrainRule
  url: "/api/v1/genie_rules"
