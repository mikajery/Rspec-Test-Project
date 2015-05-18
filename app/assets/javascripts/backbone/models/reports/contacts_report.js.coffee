TuringEmailApp.Models.Reports ||= {}

class TuringEmailApp.Models.Reports.ContactsReport extends Backbone.Model
  url: "/api/v1/email_reports/contacts_report"

  validation:
    top_senders:
      required: true
  
    top_recipients:
      required: true
  
    bottom_senders:
      required: true
  
    bottom_recipients:
      required: true
