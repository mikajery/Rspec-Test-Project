TuringEmailApp.Models.Reports ||= {}

class TuringEmailApp.Models.Reports.SummaryAnalyticsReport extends Backbone.Model
  validation:
    number_of_conversations:
      required: true

    number_of_emails_received:
      required: true

    number_of_emails_sent:
      required: true

  fetch: (options) ->
    attributes =
      number_of_conversations: 824
      number_of_emails_received: 1039
      number_of_emails_sent: 203

    @set attributes
    options?.success?(this, {}, options)
