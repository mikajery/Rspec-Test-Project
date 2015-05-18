class TuringEmailApp.Views.TemplateComposeView extends TuringEmailApp.Views.RactiveView
  @dateFormat: "m/d/Y g:i a"


  template: JST["backbone/templates/compose/template_compose"]


  events: -> _.extend {}, super(),
    "submit .compose-form": "onSubmit"
    "click .compose-modal-size-toggle": "sizeToggle"
    "click .delete-template-button": "deleteEmailTemplate"

  initialize: (options) ->
    super()

    @app = options.app
    @tempEmailTemplate = new TuringEmailApp.Models.EmailTemplate()


  data: ->
    _.extend {}, super(),
      "dynamic":
        "emailTemplate": @tempEmailTemplate


  render: ->
    super()

    @postRenderSetup()

    @composeBody = @$(".tm_compose-body .redactor-editor")

    @


  #######################
  ### Setup Functions ###
  #######################

  postRenderSetup: ->
    @setupComposeView()


  setupComposeView: ->
    @$(".compose-template-body").redactor
      focus: true
      minHeight: 200
      maxHeight: 400
      linebreaks: true
      buttons: ['formatting', 'bold', 'italic', 'deleted', 'unorderedlist', 'orderedlist', 'outdent', 'indent', 'image', 'file', 'link', 'alignment', 'horizontalrule', 'html']
      plugins: ['fontfamily', 'fontcolor', 'fontsize']
      pasteCallback: (html) ->
        html.split("<br><br><br>").join "<br><br>"

  onSubmit: (evt) ->
    @saveEmailTemplate()


  sizeToggle: (evt) ->
    @$(".compose-modal-dialog").toggleClass("compose-modal-dialog-large compose-modal-dialog-small")
    $(evt.currentTarget).toggleClass("tm_modal-button-compress tm_modal-button-expand")

  #########################
  ### Display Functions ###
  #########################

  show: ->
    @$(".compose-modal").modal(
      backdrop: 'static'
      keyboard: false
    ).show()
    @syncTimeout = window.setTimeout(=>
      @$(".tm_compose-body .redactor-editor").focus()
    , 1000)

  hide: ->
    @$(".compose-modal").modal "hide"

  bodyHtml: ->
    return @composeBody.html()

  bodyHtmlIs: (bodyHtml) ->
    @composeBody.html bodyHtml

  bodyText: ->
    return @composeBody.text()

  bodyTextIs: (bodyText) ->
    @composeBody.text bodyText

  resetView: ->
    @removeAlert()
    @bodyHtmlIs ""

    @currentEmailTemplate = null
    @categoryUID = null
    @tempEmailTemplate.clear()


  #######################
  ### Alert Functions ###
  #######################

  showSuccessAlert: (message) ->
    @removeAlert() if @currentAlertToken?

    @currentAlertToken = @app.showAlert message, "alert-success", 3000

    @hide()

  removeAlert: ->
    if @currentAlertToken?
      @app.removeAlert @currentAlertToken
      @currentAlertToken = null


  #####################################
  ### Load Email Template Functions ###
  #####################################

  loadEmpty: (categoryUID) ->
    @resetView()

    @categoryUID = categoryUID

  loadEmailTemplate: (emailTemplate, categoryUID) ->
    @resetView()

    @currentEmailTemplate = emailTemplate
    @categoryUID = categoryUID

    @tempEmailTemplate.set
      "name": emailTemplate.get "name"
      "text": emailTemplate.get "text"
      "html": emailTemplate.get "html"

    emailTemplateJSON = emailTemplate.toJSON()
    @loadEmailTemplateBody(emailTemplateJSON)


  loadEmailTemplateBody: (emailTemplateJSON) ->
    console.log("TemplateComposeView loadEmailTemplateBody!!")

    [body, html] = @parseEmailTemplate(emailTemplateJSON)
    body = $.parseHTML(body) if not html && body != ""

    @bodyHtmlIs(body)

    return body

  parseEmailTemplate: (emailTemplateJSON) ->
    htmlFailed = true
    if emailTemplateJSON.html?
      try
        emailTemplateHTML = $($.parseHTML(emailTemplateJSON.html))

        if emailTemplateHTML.length is 0 || not emailTemplateHTML[0].nodeName.match(/body/i)?
          body = $("<div />")
          body.html(emailTemplateHTML)
        else
          body = emailTemplateHTML

        htmlFailed = false
      catch error
        console.log error
        htmlFailed = true

    if htmlFailed
      bodyText = ""

      text = ""
      if emailTemplateJSON.text?
        text = emailTemplateJSON.text

      if text != ""
        for line in text.split("\n")
          bodyText += "> " + line + "\n"

      body = bodyText

    return [body, !htmlFailed]


  ###########################
  ### Save Email Template ###
  ###########################

  saveEmailTemplate: ->
    @ractive.updateModel()

    # Check if name is empty
    if @tempEmailTemplate.get("name") == ""
      TuringEmailApp.showAlert("Please enter a category name", null, 5000)
      return

    if @currentEmailTemplate? # Update
      if @tempEmailTemplate.get("name") != @currentEmailTemplate.get("name") and @app.collections.emailTemplates.findWhere({name: @tempEmailTemplate.get("name")})?
        @app.showAlert("Name already exists!",
          "alert-error",
          3000)
        return

      @currentEmailTemplate.set
        "name": @tempEmailTemplate.get "name"
        "text": @bodyText()
        "html": @tempEmailTemplate.get "html"

      @currentEmailTemplate.save null,
        patch: true
        "success": =>
          @showSuccessAlert "Template has been saved."

      @showSuccessAlert "Template has been saved successfully."
    else # Create new email Template
      # Check if name already exists
      if @app.collections.emailTemplates.findWhere({name: @tempEmailTemplate.get("name")})?
        @app.showAlert("Name already exists!",
          "alert-error",
          3000)
        return

      # Create new category
      newEmailTemplate = new TuringEmailApp.Models.EmailTemplate
        name: @tempEmailTemplate.get "name"
        text: @tempEmailTemplate.get "text"
        html: @tempEmailTemplate.get "html"
        category_uid: if @categoryUID? then @categoryUID else ""

      newEmailTemplate.save null,
        "success": =>
          # Add new template to collection
          @app.collections.emailTemplates.add newEmailTemplate
          @showSuccessAlert "Template has been created successfully."

  #############################
  ### Delete Email Template ###
  #############################

  deleteEmailTemplate: ->
    if @currentEmailTemplate?
      @currentEmailTemplate.destroy().then =>
        @app.showAlert("Deleted email template successfully!",
          "alert-success", 3000
        )
        @hide()
    else
      @hide()
