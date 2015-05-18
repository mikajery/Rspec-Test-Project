TuringEmailApp.Models.Reports ||= {}

class TuringEmailApp.Models.Reports.GeoReport extends Backbone.Model
  url: "/api/v1/email_reports/ip_stats_report"

  validation:
    ip_stats:
      required: true
