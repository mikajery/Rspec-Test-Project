TuringEmailApp.Views.PrimaryPane ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailSignaturesView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/primary_pane/email_signatures"]

  events:
    "click .tm_signatures .update-email-signature": "updateEmailSignature"
    "click .tm_signatures .delete-email-signature": "deleteEmailSignature"
    "click .create-email-signature": "createEmailSignature"

  className: "tm_content"

  initialize: (options) ->
    super(options)

    @app = options.app
    @emailSignatures = options.emailSignatures
    @emailSignatureUID = options.emailSignatureUID

    @listenTo(options.emailSignatures, "reset", @render)

  render: ->
    $(".create-email-signatures-dialog-form").remove()

    emailSignaturesJSON = @emailSignatures.toJSON()
    for emailSignatureJSON in emailSignaturesJSON
      emailSignatureJSON["created_at_date"] = emailSignatureJSON?.created_at?.split("T")?[0]

    @$el.html(@template({
      emailSignatures: emailSignaturesJSON,
      emailSignatureUID: @emailSignatureUID
    }))
    @setupSignatureEditor()
    @setupCreateEmailSignature()
    @setupEvents()
    @

  setupEvents: ->
    @$el.find(".tm_signature-preview-radio input").change (evt) =>
      uid = $(evt.target).closest(".tm_signature-preview-item").data("uid")

      @app.models.userConfiguration.set({
        email_signature_uid: if uid? then uid else @app.models.userConfiguration.get("email_signature_uid")
      })

      @app.models.userConfiguration.save(null, {
        patch: true
        success: (model, response) ->
          TuringEmailApp.showAlert("You have successfully saved your settings!", "alert-success", 5000)
        }
      )

  setupSignatureEditor: ->
    @$(".compose-signature").redactor
      focus: true
      minHeight: 200
      maxHeight: 400
      linebreaks: true
      buttons: ['formatting', 'bold', 'italic', 'deleted', 'unorderedlist', 'orderedlist', 'outdent', 'indent', 'image', 'file', 'link', 'alignment', 'horizontalrule', 'html']
      plugins: ['fontfamily', 'fontcolor', 'fontsize']

  updateEmailSignature: (evt) ->
    index = @$(".tm_signatures li").index($(evt.currentTarget).closest('li'))
    emailSignature = @emailSignatures.at(index)
    text = @getSignatureBodyText()
    html = @getSignatureBodyHtml()
    emailSignature.set({
      text: text,
      html: html
    })
    emailSignature.save(null, {
      patch: true
      success: (model, response) =>
        TuringEmailApp.showAlert("You have successfully updated an email signature!", "alert-success", 5000)
        @emailSignatures.fetch(reset: true)
    })

  deleteEmailSignature: (evt) ->
    index = @$(".tm_signatures li").index($(evt.currentTarget).closest('li'))
    emailSignature = @emailSignatures.at(index)
    emailSignature.destroy()
    TuringEmailApp.showAlert("You have successfully deleted an email signature!", "alert-success", 5000)
    @emailSignatures.fetch(reset: true)

    if emailSignature.get("uid") is @emailSignatureUID
      @trigger("currentEmailSignatureDeleted", this)

  setupCreateEmailSignature: ->
    @createEmailSignaturesDialog = @$(".create-email-signatures-dialog-form").dialog(
      autoOpen: false
      width: 400
      modal: true
      resizable: false
      dialogClass: 'create-email-signatures-dialog'
      buttons: [{
        text: "Cancel"
        class: "tm_button"
        click: =>
          @createEmailSignaturesDialog.dialog "close"
      }, {
        text: "Create"
        class: "tm_button tm_button-blue"
        click: =>
          emailSignature = new TuringEmailApp.Models.EmailSignature()
          name = $(".create-email-signatures-dialog-form .email-signature-name").val()
          # Check if name is empty
          if name == ""
            TuringEmailApp.showAlert("Please fill out the name field!",
              "alert-error",
              3000)
            return
          text = @getSignatureBodyText()
          html = @getSignatureBodyHtml()
          emailSignature.set({
            name: name,
            text: text,
            html: html
          })
          emailSignature.save(null, {
            success: (model, response) =>
              TuringEmailApp.showAlert("You have successfully created an email signature!", "alert-success", 5000)
              @createEmailSignaturesDialog.dialog "close"
              @emailSignatures.fetch(reset: true)
          })
      }])

  createEmailSignature: ->
    @createEmailSignaturesDialog.dialog("open")

  getSignatureBodyHtml: ->
    return @$(".tm_signature-compose .redactor-editor").html()

  getSignatureBodyText: ->
    return @$(".tm_signature-compose .redactor-editor").text()
