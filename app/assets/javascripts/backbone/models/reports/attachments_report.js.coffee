TuringEmailApp.Models.Reports ||= {}

class TuringEmailApp.Models.Reports.AttachmentsReport extends Backbone.Model
  url: "/api/v1/email_reports/attachments_report"

  validation:
    average_file_size:
      required: true
  
    content_type_stats:
      required: true
