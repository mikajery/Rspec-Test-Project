class TuringEmailApp.Views.EmailTemplatesDropdownView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/compose/compose_body_toolbar/email_templates_dropdown"]
  events: -> _.extend {}, super(),
    "click .load-email-template": "loadEmailTemplate"
    "click .create-email-template": "showCreateEmailTemplatesDialog"
    "click .delete-email-template": "showDeleteEmailTemplatesDialog"
    "click .update-email-template": "showUpdateEmailTemplatesDialog"


  data: -> _.extend {}, super(),
    "dynamic":
      "emailTemplates": @collection
      "newEmailTemplate": @newEmailTemplate


  initialize: (options) ->
    super(options)
    @composeView = options.composeView
    @newEmailTemplate = new TuringEmailApp.Models.EmailTemplate()


  render: ->
    super()

    @setupCreateEmailTemplate()
    @setupDeleteEmailTemplate()
    @setupUpdateEmailTemplate()

    @


  setupDialog: (selector, options) ->
    dialogOptions =
      "autoOpen": false
      "width": 400
      "modal": true
      "resizable": false

    @$(selector).dialog(_.extend(dialogOptions, options))


  createEmailTemplate: ->
    # Check if name is empty
    if @newEmailTemplate.get("name") == ""
      TuringEmailApp.showAlert("Please fill out the name field!",
        "alert-error",
        3000)
      return

    @newEmailTemplate.set
      "text": @composeView.bodyText()
      "html": @composeView.bodyHtml()

    @newEmailTemplate.save null,
      "success": =>
        @newEmailTemplate.clear()
        @showSuccessOfCreateEmailTemplate()


  showSuccessOfCreateEmailTemplate: ->
    TuringEmailApp.showAlert("You have successfully created an email template!",
                             "alert-success",
                             3000)

    @createEmailTemplatesDialog.dialog "close"

    @collection.fetch()


  setupCreateEmailTemplate: ->
    @createEmailTemplatesDialog =
      @setupDialog ".create-email-templates-dialog-form",
        "dialogClass": "create-email-templates-dialog"
        "buttons": [{
          "text": "Cancel"
          "class": "tm_button"
          "click": => @createEmailTemplatesDialog.dialog "close"
        }, {
          "text": "Create"
          "class": "tm_button tm_button-blue"
          "click": => @createEmailTemplate()
        }]


  showCreateEmailTemplatesDialog: ->
    @createEmailTemplatesDialog.dialog("open")


  deleteEmailTemplate: ->
    index =
      $(".delete-email-templates-dialog-form select option").
      index($(".delete-email-templates-dialog-form select option:selected"))
    emailTemplate = @collection.at(index)

    emailTemplate.destroy()

    TuringEmailApp.showAlert("You have successfully deleted an email template!",
                             "alert-success",
                             3000)

    @deleteEmailTemplatesDialog.dialog "close"

    @collection.fetch()


  setupDeleteEmailTemplate: ->
    @deleteEmailTemplatesDialog =
      @setupDialog ".delete-email-templates-dialog-form",
        "dialogClass": "delete-email-templates-dialog"
        "buttons": [{
          "text": "Cancel"
          "class": "tm_button"
          "click": => @deleteEmailTemplatesDialog.dialog "close"
        }, {
          "text": "Delete"
          "class": "tm_button tm_button-red"
          "click": => @deleteEmailTemplate()
        }]


  showDeleteEmailTemplatesDialog: ->
    @deleteEmailTemplatesDialog.dialog("open")
    console.log("delete email template")


  loadEmailTemplate: (evt) ->
    index = @$(".load-email-template").index(evt.currentTarget)
    emailTemplate = @collection.at(index)

    @composeView.
      $(".tm_compose-body .redactor-editor").
      prepend(emailTemplate.get("html"))


  updateEmailTemplate: ->
    index =
      $(".update-email-templates-dialog-form select option").
      index($(".update-email-templates-dialog-form select option:selected"))
    emailTemplate = @collection.at(index)

    text = @composeView.bodyText()
    html = @composeView.bodyHtml()

    emailTemplate.set({
      text: text,
      html: html
    })

    emailTemplate.save(null, {
      patch: true
      success: (model, response) =>
        @showSuccessOfUpdateEmailTemplate()
      }
    )


  showSuccessOfUpdateEmailTemplate: ->
    TuringEmailApp.showAlert("You have successfully updated an email template!",
                             "alert-success",
                             3000)

    @updateEmailTemplatesDialog.dialog "close"

    @collection.fetch()


  setupUpdateEmailTemplate: ->
    @updateEmailTemplatesDialog =
      @setupDialog ".update-email-templates-dialog-form",
        "dialogClass": "update-email-templates-dialog"
        "buttons": [{
          "text": "Cancel"
          "class": "tm_button"
          "click": => @updateEmailTemplatesDialog.dialog "close"
        }, {
          "text": "Update"
          "class": "tm_button tm_button-blue"
          "click": => @updateEmailTemplate()
        }]


  showUpdateEmailTemplatesDialog: ->
    @updateEmailTemplatesDialog.dialog("open")
