class TuringEmailApp.Models.CleanerReport extends Backbone.Model
  url: "/api/v1/email_accounts/cleaner_report"

  @Apply: ->
    $.post "/api/v1/email_accounts/apply_cleaner"
