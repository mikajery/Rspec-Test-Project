TuringEmailApp.Models.InstalledApps ||= {}

class TuringEmailApp.Models.InstalledApps.InstalledPanelApp extends TuringEmailApp.Models.InstalledApps.InstalledApp
  @GetEmailThreadAppJSON: (emailThread) ->
    emailThreadAppJSON = emailThread.toJSON()

    for emailJSON in emailThreadAppJSON.emails
      TuringEmailApp.Models.InstalledApps.InstalledPanelApp.CleanEmailAppJSON(emailJSON)

    return emailThreadAppJSON

  @CleanEmailAppJSON: (emailJSON) ->
    delete emailJSON["body_text_encoded"]
    delete emailJSON["html_part_encoded"]
    delete emailJSON["text_part_encoded"]

    return emailJSON

  run: (iframe, object) ->
    doPost = (params) =>
      $.post(@get("app").callback_url, params, null, "html").done(
        (data, status) ->
          iframe.contents().find("html").html(data)
      )

    if object instanceof TuringEmailApp.Models.EmailThread
      object.load(
        success: ->
          params = email_thread: TuringEmailApp.Models.InstalledApps.InstalledPanelApp.GetEmailThreadAppJSON(object)
          doPost(params)
      )
    else
      params = email: TuringEmailApp.Models.InstalledApps.InstalledPanelApp.CleanEmailAppJSON(object)
      doPost(params)
