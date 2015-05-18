TuringEmailApp.Models.Reports ||= {}

class TuringEmailApp.Models.Reports.FoldersReport extends Backbone.Model
  url: "/api/v1/email_reports/folders_report"
