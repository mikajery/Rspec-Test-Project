TuringEmailApp.Models.Reports ||= {}

class TuringEmailApp.Models.Reports.ListsReport extends Backbone.Model
  url: "/api/v1/email_reports/lists_report"

  validation:
    lists_email_daily_average:
      required: true

    emails_per_list:
      required: true
      
    email_threads_per_list:
      required: true
    
    email_threads_replied_to_per_list:
      required: true
    
    sent_emails_per_list:
      required: true

    sent_emails_replied_to_per_list:
      required: true
