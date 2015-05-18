TuringEmailApp.Models.Reports ||= {}

class TuringEmailApp.Models.Reports.ImpactReport extends Backbone.Model
  url: "/api/v1/email_reports/impact_report"

  validation:
    percent_sent_emails_replied_to:
      required: true
