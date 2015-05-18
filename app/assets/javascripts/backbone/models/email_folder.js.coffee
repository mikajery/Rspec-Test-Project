class TuringEmailApp.Models.EmailFolder extends Backbone.Model
  idAttribute: "label_id"

  validation:
    label_id:
      required: true
  
    label_list_visibility:
      required: true
  
    label_type:
      required: true
  
    message_list_visibility:
      required: true
  
    name:
      required: true
  
    num_threads:
      required: true
      min: 0
  
    num_unread_threads:
      required: true
      min: 0

  badgeString: ->
    badgeCount = 0
    if @get("label_id") is "SENT" or  @get("label_id") is "TRASH"
      return ""
    else if @get("label_id") is "DRAFT"
      badgeCount = @get("num_threads")
    else
      badgeCount = @get("num_unread_threads")
      
    return if badgeCount == 0 then "" else "" + badgeCount
