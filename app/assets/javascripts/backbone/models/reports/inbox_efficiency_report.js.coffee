TuringEmailApp.Models.Reports ||= {}

class TuringEmailApp.Models.Reports.InboxEfficiencyReport extends Backbone.Model
  validation:
    average_response_time_in_minutes:
      required: true
    
    percent_archived:
      required: true
    
  fetch: (options) ->
    attributes =
      average_response_time_in_minutes: 7.5
      percent_archived: 71.2
      
    @set attributes
    options?.success?(this, {}, options)
