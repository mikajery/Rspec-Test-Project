class TuringEmailApp.Views.ComposeView extends TuringEmailApp.Views.RactiveView
  @dateFormat: "m/d/Y g:i a"


  template: JST["backbone/templates/compose/modal_compose"]


  events: -> _.extend {}, super(),
    "submit .compose-form": "onSubmit"
    "click .compose-form .send-later-button": "sendEmailDelayed"
    "click .compose-form .save-button": "saveDraft"
    "click .display-cc": "displayCC"
    "click .display-bcc": "displayBCC"
    "click .send-and-archive": "sendAndArchive"
    "click .compose-modal-size-toggle": "sizeToggle"
    "change .compose-form .send-later-datetimepicker": "updateSendButtonTextOnClick"

  initialize: (options) ->
    super(options)

    @app = options.app
    @email = new TuringEmailApp.Models.Email()
    @uploadAttachmentPostJSON = options.uploadAttachmentPostJSON
    @is_modal = @.constructor.name == 'ModalComposeView'


  data: ->
    setRecipients = (val) ->
      if val
        if _.isArray(val)
          return val
        else if _.isString(val)
          return val.split(/[;, ]+/)
      return

    _.extend {}, super(),
      "static":
        "userAddress": @app.models.user.get("email")
        "profilePicture": if @app.models.user.get("profile_picture")? then @app.models.user.get("profile_picture") else "/images/profile.png"
      "dynamic":
        "email": @email
      "computed":
        "email._tos":
          "get": "${_}.join(\", \")"
          "set": setRecipients
        "email._ccs":
          "get": "${_}.join(\", \")"
          "set": setRecipients
        "email._bccs":
          "get": "${_}.join(\", \")"
          "set": setRecipients
        "email._bounce_back_time":
          "get": "${_}.dateFormat(TuringEmailApp.Views.ComposeView.dateFormat)"
          "set": (val) -> if val is "" or not val? then "" else new Date(val)

  render: ->
    super()

    @postRenderSetup()

    @


  #######################
  ### Setup Functions ###
  #######################

  postRenderSetup: ->
    @setupComposeView()
    @setupDropZone()
    @setupEmailAddressAutocompleteOnAddressFields()
    @setupEmailAddressDeobfuscation()
    @setupEmailTemplatesDropdown()
    @setupAttachmentUpload()

    @setupDatetimepicker()

    @$(".switch").bootstrapSwitch()

    @setupReminders()

  # Begin setupDatetimepicker #

  setupDatetimepicker: ->
    options = {
      format: TuringEmailApp.Views.ComposeView.dateFormat
      formatTime: "g:i a"
      theme: if @is_modal then "dark" else ""
      minDate: 0
    }

    @$(".datetimepicker").each (i, elm) =>
      $elm = $(elm)
      delete options.parentID
      if $elm.hasClass("bounce-back-datetimepicker")
        $elm.on "click", (evt) -> evt.stopPropagation()
        options.parentID = @$(".dropdown-reminder")
        options.onSelectDate = (currentTime, input) =>
          @datetimepickerValueSelected()
        options.onSelectTime = (currentTime, input) =>
          @datetimepickerValueSelected()

      $elm.datetimepicker(options)

  datetimepickerValueSelected: ->
    @selectAlwaysRemind() if @neverRemindIsSelected()

  selectAlwaysRemind: ->
    $($(".dropdown-reminder li .iradio").get(1)).find("ins").click()

  neverRemindIsSelected: ->
    @$(".dropdown-reminder li:first .iradio").hasClass("checked")

  # End setupDatetimepicker #

  setupComposeView: ->
    @$(".compose-email-body").redactor
      focus: true
      minHeight: 200
      maxHeight: 400
      linebreaks: true
      buttons: ['formatting', 'bold', 'italic', 'deleted', 'unorderedlist', 'orderedlist', 'outdent', 'indent', 'image', 'file', 'link', 'alignment', 'horizontalrule', 'html']
      plugins: ['fontfamily', 'fontcolor', 'fontsize']
      pasteCallback: (html) ->
        html.split("<br><br><br>").join "<br><br>"

    @composeBody = @$(".tm_compose-body .redactor-editor")

  setupDropZone: ->
    if @composeBody?
      @$(".tm_compose-body").find("compose-email-dropzone").remove()

      @dropZone = $('<div class="compose-email-dropzone" contenteditable="false"><span>Drop files here</span></div>')
      @dropZone.prependTo(@$(".tm_compose-body"))

      window.dropZoneTimeouts = window.dropZoneTimeouts || {}
      $(document).bind "dragover", (e) =>
        timeout = window.dropZoneTimeouts[@cid]
        if !timeout
          @dropZone.addClass 'in'
        else
          clearTimeout timeout

        window.dropZoneTimeouts[@cid] = setTimeout (=>
          window.dropZoneTimeouts[@cid] = null;
          @dropZone.removeClass 'in'
        ), 100

      $(document).bind 'drop dragover', (e) ->
        e.preventDefault()

  displayCC: (evt) ->
    $(evt.target).hide()
    @$(".cc-input-wrapper").show()

  displayBCC: (evt) ->
    $(evt.target).hide()
    @$(".bcc-input-wrapper").show()

  onSubmit: (evt) ->
    console.log "SEND clicked! Sending..."
    @sendEmail()

  sendAndArchive: ->
    console.log "send-and-archive clicked"
    @sendEmail()
    @trigger("archiveClicked", this)

  setupEmailAddressAutocompleteOnAddressFields: ->
    @setupEmailAddressAutocomplete ".compose-form .to-input"
    @setupEmailAddressAutocomplete ".compose-form .cc-input"
    @setupEmailAddressAutocomplete ".compose-form .bcc-input"

  # TODO write more thorough tests
  setupEmailAddressAutocomplete: (selector) ->
    @$el.find(selector).autocomplete(
      source: (request, response) ->
        $.ajax
          url: "http://localhost:4000/api/v1/people/search/" + request.term
          success: (data) ->
            contacts = []
            namesAndAddresses = []
            for remoteContact in data
              contact = {}
              contact["value"] = remoteContact["email_address"]
              contact["label"] = if remoteContact["name"]? then remoteContact["name"] else " "
              contact["desc"] = remoteContact["email_address"]
              contacts.push contact
            response contacts
      focus: (evt, ui) ->
        $(selector).val ui.item.value
        false
      select: (evt, ui) ->
        $(selector).val ui.item.value
        false
    ).autocomplete("instance")._renderItem = (ul, item) ->
      if item.label is " "
        $("<li>").append("<span>" + item.desc + "</span><small>" + item.desc + "</small>").appendTo ul
      else
        $("<li>").append("<span>" + item.label + "</span><small>" + item.desc + "</small>").appendTo ul

    @$el.find(selector).attr "autocomplete", "on"

  setupEmailAddressDeobfuscation: ->
    @$(".compose-form .to-input, .compose-form .cc-input, .compose-form .bcc-input").keyup ->
      inputText = $(@).val()
      indexOfObfuscatedEmail = inputText.search(/(.+) ?\[at\] ?(.+) ?[dot] ?(.+)/)

      if indexOfObfuscatedEmail != -1
        $(@).val(inputText.replace(" [at] ", "@").replace(" [dot] ", "."))

  # setupLinkPreviews: ->
  #   @$(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").bind "keydown", "space return shift+return", =>
  #     emailHtml = @$(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").html()
  #     indexOfUrl = emailHtml.search(/((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;w]+@)?[A-Za-z0-9.-]+|(?www.|[-;w]+@)[A-Za-z0-9.-]+)((?w-_]*)?\??(?w_]*)#?(?w]*))?)/)

  #     linkPreviewIndex = emailHtml.search("compose-link-preview")

  #     if indexOfUrl isnt -1 and linkPreviewIndex is -1
  #       link = emailHtml.substring(indexOfUrl)?.split(" ")?[0]

  #       websitePreview = new TuringEmailApp.Models.WebsitePreview(
  #         websiteURL: link
  #       )

  #       @websitePreviewView = new TuringEmailApp.Views.WebsitePreviewView(
  #         model: websitePreview
  #         el: @$(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable")
  #       )
  #       websitePreview.fetch()

  setupEmailTemplatesDropdown: ->
    @emailTemplatesDropdownView = new TuringEmailApp.Views.EmailTemplatesDropdownView(
      collection: @app.collections.emailTemplates
      el: $("<li>").insertAfter(@$(".redactor-toolbar").children().last())
      composeView: @
    )
    @emailTemplatesDropdownView.render()

  # TODO write tests
  setupAttachmentUpload: ->
    @attachmentS3Keys = {}

    @$(".tm_upload-attachments").empty()
    @addAttachmentUpload()

  humanFileSize: (size) ->
    i = Math.floor(Math.log(size) / Math.log(1024))
    return (size / Math.pow(1024, i)).toFixed(2) * 1 + ' ' + ['B', 'kB', 'MB', 'GB', 'TB'][i]

  # TODO write tests
  addAttachmentUpload: ->
    uploadAttachments = @$(".tm_upload-attachments")
    fileContainer = $('<li class="tm_upload-attachment tm_upload-nofile">').prependTo(uploadAttachments)
    fileInput = $('<input type="file">').appendTo(fileContainer).hide()
    progressBar = $('<span class="tm_progress-bar">')
    fileName = $('<small class="tm_upload-filename">').text "Attach a file..."
    fileSize = $('<small class="tm_upload-filesize">')
    fileInput.after $('<span class="tm_progress">').append(progressBar)
    fileInput.after fileSize
    fileInput.after fileName

    fileInput.show()

    submitButton = @$(".send-button")

    fileInput.fileupload
      fileInput: fileInput
      dropZone: @dropZone
      url: @uploadAttachmentPostJSON.url
      type: "POST"
      autoUpload: true
      formData: @uploadAttachmentPostJSON.fields
      paramName: "file"
      dataType: "XML"
      replaceFileInput: false

      progressall: (evt, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        progressBar.css "width", progress + "%"

      send: (e, data) ->
        fileContainer.removeClass "tm_upload-nofile"
        fileName.text data.files[0].name
        submitButton.prop "disabled", true
        fileInput.hide()

      done: (evt, data) =>
        fileContainer.addClass "tm_upload-complete"
        submitButton.prop "disabled", false
        fileSize.text @humanFileSize(data.total)

        fileContainer.click =>
          delete @attachmentS3Keys[fileInput]
          fileContainer.remove()

        key = $(data.jqXHR.responseXML).find("Key").text()
        @attachmentS3Keys[fileInput] = key

        @addAttachmentUpload()

      fail: (evt, data) ->
        submitButton.prop "disabled", false
        fileSize.text "Upload failed"
        fileInput.show()

  sizeToggle: (evt) ->
    @$(".compose-modal-dialog").toggleClass("compose-modal-dialog-large compose-modal-dialog-small")
    $(evt.currentTarget).toggleClass("tm_modal-button-compress tm_modal-button-expand")

  setupReminders: ->
    @$(".iradio ins").off("click")

    @$(".i-checks").iCheck
      radioClass: "iradio" + (if @is_modal then " iradio-dark" else "")

    @$(".iradio:first ins").click =>
      @$(".bounce-back-datetimepicker").val("") if @$(".bounce-back-datetimepicker").val() != ""

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
    @updateSendButtonText @sendLaterDatetime()

  hide: ->
    @$(".compose-modal").modal "hide"

  bodyHtml: ->
    return @composeBody.html()

  bodyHtmlIs: (bodyHtml) ->
    @composeBody.html(bodyHtml)

  prependBodyHTML: (bodyHtml) ->
    @composeBody.prepend(bodyHtml)

  bodyText: ->
    return @composeBody.text()

  bodyTextIs: (bodyText) ->
    @composeBody.text(bodyText)

  sendLaterDatetime: ->
    @$(".compose-form .send-later-datetimepicker").val()

  sendLaterDatetimeIs: (datetime) ->
    @$(".compose-form .send-later-datetimepicker").val(datetime)

  resetView: ->
    console.log("ComposeView RESET!!")

    @removeEmailSentAlert()

    @currentEmailDraft = null
    @emailInReplyToUID = null
    @emailThreadParent = null
    @currentEmailDelayed = null

    @email.clear()
    @sendLaterDatetimeIs("")

    @bodyHtmlIs("")
    @$(".compose-form .send-later-switch").bootstrapSwitch("setState", false, true)

    @$(".compose-modal .display-cc").show()
    @$(".compose-modal .cc-input-wrapper").hide()
    @$(".compose-modal .display-bcc").show()
    @$(".compose-modal .bcc-input-wrapper").hide()

    @setupAttachmentUpload()

  showEmailSentAlert: (emailSentJSON) ->
    console.log "ComposeView showEmailSentAlert"

    @removeEmailSentAlert() if @currentAlertToken?

    @currentAlertToken = @app.showAlert('Your message has been sent. <span class="tm_alert-link undo-email-send">Undo</span>', "alert-success")
    $(".undo-email-send").click =>
      clearTimeout(TuringEmailApp.sendEmailTimeout)

      @removeEmailSentAlert()
      @loadEmail(emailSentJSON)
      @show()

  removeEmailSentAlert: ->
    console.log "ComposeView REMOVE emailSentAlert"

    if @currentAlertToken?
      @app.removeAlert(@currentAlertToken)
      @currentAlertToken = null

  updateSendButtonText: (sendLaterDatetime) ->
    sendButton = @$(".compose-form .email-send-button")
    sendButtonText = @$(".compose-form .send-button-text")

    if !sendLaterDatetime
      sendButtonText.text("Send")
      sendButton.addClass("send-button")
      sendButton.removeClass("send-later-button")
    else
      sendButtonText.text("Send Later")
      sendButton.addClass("send-later-button")
      sendButton.removeClass("send-button")

  updateSendButtonTextOnClick: (evt) ->
    @updateSendButtonText $(evt.target).val()

  ############################
  ### Load Email Functions ###
  ############################

  loadEmpty: ->
    @resetView()

  loadEmailSignature: ->
    if @app.models.userConfiguration.get("email_signature_uid")?
      @currentEmailSignature = new TuringEmailApp.Models.EmailSignature(
        uid: @app.models.userConfiguration.get("email_signature_uid")
      )
      @currentEmailSignature.fetch(
        success: (model, response, options) =>
          @prependBodyHTML model.get("html")
      )

  loadEmail: (emailJSON, emailThreadParent) ->
    console.log("ComposeView loadEmail!!")
    @resetView()

    @loadEmailHeaders(emailJSON)
    @loadEmailBody(emailJSON)

    @emailThreadParent = emailThreadParent

  loadEmailDraft: (emailDraftJSON, emailThreadParent) ->
    console.log("ComposeView loadEmailDraft!!")
    @resetView()

    @loadEmailHeaders(emailDraftJSON)
    @loadEmailBody(emailDraftJSON)

    @currentEmailDraft = new TuringEmailApp.Models.EmailDraft(emailDraftJSON)
    @emailThreadParent = emailThreadParent

  loadEmailDelayed: (emailDelayed) ->
    console.log "ComposeView loadEmailDelayed!!"
    @resetView()

    emailDelayedJSON = emailDelayed.toJSON()
    @loadEmailHeaders(emailDelayedJSON)
    @loadEmailBody(emailDelayedJSON)
    @loadEmailFooters(emailDelayedJSON)

    @currentEmailDelayed = emailDelayed

  loadEmailAsReply: (emailJSON, emailThreadParent) ->
    console.log("ComposeView loadEmailAsReply!!")
    @resetView()

    @ractive.set
      "email._tos": (emailJSON.reply_to_address || emailJSON.from_address)
      "email.subject": @subjectWithPrefixFromEmail(emailJSON, "Re: ")

    @loadEmailBody(emailJSON, true)

    @emailInReplyToUID = emailJSON.uid
    @emailThreadParent = emailThreadParent

  loadEmailAsReplyToAll: (emailJSON, emailThreadParent) ->
    console.log("ComposeView loadEmailAsReplyToAll!!")
    @resetView()

    console.log emailJSON

    @ractive.set
      "email._tos": emailJSON["tos"]
      "email._ccs": emailJSON["ccs"]
      "email.subject": @subjectWithPrefixFromEmail(emailJSON, "Re: ")
    @loadEmailBody(emailJSON, true)

    @emailInReplyToUID = emailJSON.uid
    @emailThreadParent = emailThreadParent

  loadEmailAsForward: (emailJSON, emailThreadParent) ->
    console.log("ComposeView loadEmailAsForward!!")
    @resetView()

    @ractive.set
      "email.subject": @subjectWithPrefixFromEmail(emailJSON, "Fwd: ")
    @loadEmailBody(emailJSON, true)

    @emailThreadParent = emailThreadParent

  loadEmailHeaders: (emailJSON) ->
    console.log("ComposeView loadEmailHeaders!!")
    @ractive.set
      "email._tos": emailJSON["tos"]
      "email._ccs": emailJSON["ccs"]
      "email._bccs": emailJSON["bccs"]
      "email.subject": @subjectWithPrefixFromEmail(emailJSON)

  loadEmailBody: (emailJSON, isReply=false) ->
    console.log("ComposeView loadEmailBody!!")

    if isReply
      body = @formatEmailReplyBody(emailJSON)
    else
      [body, html] = @parseEmail(emailJSON)
      body = $.parseHTML(body) if not html && body != ""

    @bodyHtmlIs(body)

    return body

  loadEmailFooters: (emailJSON) ->
    console.log("ComposeView loadEmailFooters!!")

    if emailJSON.send_at?
      @sendLaterDatetimeIs(moment(emailJSON.send_at).format("MM/DD/YYYY h:mm a"))

  parseEmail: (emailJSON) ->
    htmlFailed = true

    if emailJSON.html_part?
      try
        emailHTML = $($.parseHTML(emailJSON.html_part))

        if emailHTML.length is 0 || not emailHTML[0].nodeName.match(/body/i)?
          body = $("<div />")
          body.html(emailHTML)
        else
          body = emailHTML

        htmlFailed = false
      catch error
        console.log error
        htmlFailed = true

    if htmlFailed
      bodyText = ""

      text = ""
      if emailJSON.text_part?
        text = emailJSON.text_part
      else if emailJSON.body_text?
        text = emailJSON.body_text

      if text != ""
        for line in text.split("\n")
          bodyText += "> " + line + "\n"

      body = bodyText

    return [body, !htmlFailed]

  ##############################
  ### Format Email Functions ###
  ##############################

  formatEmailReplyBody: (emailJSON) ->
    tDate = new TDate()
    tDate.initializeWithISO8601(emailJSON.date)

    headerText = "\r\n\r\n"
    headerText += tDate.longFormDateString() + ", " + emailJSON.from_address + " wrote:"
    headerText += "\r\n\r\n"

    headerText = headerText.replace(/\r\n/g, "<br />")

    [body, html] = @parseEmail(emailJSON)

    if html
      $(body[0]).prepend(headerText)
    else
      body = body.replace(/\r\n/g, "<br />")
      body = $($.parseHTML(headerText + body))

    return body

  subjectWithPrefixFromEmail: (emailJSON, subjectPrefix="") ->
    console.log("ComposeView subjectWithPrefixFromEmail")
    return subjectPrefix if not emailJSON.subject

    subjectWithoutForwardPrefix = emailJSON.subject.replace("Fwd: ", "")
    subjectWithoutForwardAndReplyPrefixes = subjectWithoutForwardPrefix.replace("Re: ", "")
    return subjectPrefix + subjectWithoutForwardAndReplyPrefixes

  ###################
  ### Email State ###
  ###################

  updateDraft: ->
    console.log "ComposeView updateDraft!"
    @currentEmailDraft = new TuringEmailApp.Models.EmailDraft() if not @currentEmailDraft?
    @updateEmail(@currentEmailDraft)

  updateEmail: (email) ->
    console.log "ComposeView updateEmail!"

    @ractive.updateModel()

    email.set(@email.toJSON())

    email.set
      "email_in_reply_to_uid": @emailInReplyToUID
      "attachment_s3_keys": _.values(@attachmentS3Keys)
      "bounce_back_enabled": (email.get("bounce_back_type") != "never")
      "text_part": @bodyText()

  emailHasRecipients: (email) ->
    return email.get("tos").length > 1 || (email.get("tos")[0]? and email.get("tos")[0].trim() != "") ||
           email.get("ccs").length > 1 || (email.get("ccs")[0]? and email.get("ccs")[0].trim() != "") ||
           email.get("bccs").length > 1 || (email.get("bccs")[0]? and email.get("bccs")[0].trim() != "")

  checkBounceBack: (email) ->
    return true if !email.get("bounce_back_enabled")
    return @checkDate(email.get("bounce_back_time"), "bounce back time")

  checkDate: (dateString, description) ->
    dateTime = new Date(dateString)

    if dateTime.toString() == "Invalid Date"
      @app.showAlert("The " + description + " is invalid.", "alert-error", 5000)
      return false
    else if dateTime < new Date()
      @app.showAlert("The " + description + " is before the current time.", "alert-error", 5000)
      return false

    return true

  ###################
  ### Email Draft ###
  ###################

  saveDraft: (force = false) ->
    console.log "SAVE clicked - saving the draft!"
    @app.showAlert("Email draft saving.", "alert-success", 5000)

    # if already in the middle of saving, no reason to save again
    # it could be an error to save again if the draft_id isn't set because it would create duplicate drafts
    if @savingDraft
      console.log "SKIPPING SAVE - already saving!!"
      return

    @updateDraft()

    if !force &&
       !@emailHasRecipients(@currentEmailDraft) &&
       @currentEmailDraft.get("subject").trim() == "" &&
       @currentEmailDraft.get("html_part")?.trim() == "" && @currentEmailDraft?.get("text_part").trim() == "" &&
       not @currentEmailDraft.get("draft_id")?

      console.log "SKIPPING SAVE - BLANK draft!!"
    else
      @savingDraft = true

      @currentEmailDraft.save(null,
        success: (model, response, options) =>
          console.log "SAVED! setting draft_id to " + response.draft_id

          model.set("draft_id", response.draft_id)
          @trigger "change:draft", this, model, @emailThreadParent

          @savingDraft = false

          @app.showAlert("Email draft saved.", "alert-success", 5000)

        error: (model, response, options) =>
          console.log "SAVE FAILED!!!"
          @savingDraft = false
      )

  ##################
  ### Send Email ###
  ##################

  sendEmailWithCallback: (callback, callbackWithDraft, draftToSend=null) ->
    if @currentEmailDraft? || draftToSend?
      console.log "sending DRAFT"

      if not draftToSend?
        console.log "NO draftToSend - not callback so update the draft and save it"
        # need to update and save the draft state because reset below clears it
        @updateDraft()
        draftToSend = @currentEmailDraft

        if !@emailHasRecipients(draftToSend)
          @app.showAlert("Email has no recipients!", "alert-error", 5000)
          return

        if !@checkBounceBack(draftToSend)
          return

        @resetView()
        @hide()

      if @savingDraft
        console.log "SAVING DRAFT!!!!!!! do TIMEOUT callback!"
        # if still saving the draft from save-button click need to retry because otherwise multiple drafts
        # might be created or the wrong version of the draft might be sent.
        setTimeout (=>
          @sendEmailWithCallback(callback, callbackWithDraft, draftToSend)
        ), 500
      else
        console.log "NOT in middle of draft save - saving it then sending"
        callbackWithDraft(draftToSend)
    else
      # easy case - no draft just send the email!
      console.log "NO draft! Sending"
      emailToSend = new TuringEmailApp.Models.Email()
      @updateEmail(emailToSend)

      if !@emailHasRecipients(emailToSend)
        @app.showAlert("Email has no recipients!", "alert-error", 5000)
        return

      if !@checkBounceBack(emailToSend)
        return

      @resetView()
      @hide()

      callback(emailToSend)

  sendEmail: ->
    console.log "ComposeView sendEmail!"
    console.log @attachmentS3Keys

    currentEmailDelayed = @currentEmailDelayed

    @sendEmailWithCallback(
      (emailToSend) =>
        @sendUndoableEmail(emailToSend, currentEmailDelayed)

      (draftToSend) =>
        draftToSend.save(null, {
          success: (model, response, options) =>
            console.log "SAVED! setting draft_id to " + response.draft_id
            draftToSend.set("draft_id", response.draft_id)
            @trigger "change:draft", this, model, @emailThreadParent

            @sendUndoableEmail(draftToSend, currentEmailDelayed)
        })
    )

  sendEmailDelayed: ->
    console.log "sendEmailDelayed!!!"

    dateTimePickerVal = @$(".compose-form .send-later-datetimepicker").val()
    if !@checkDate(dateTimePickerVal, "send later time")
      return

    sendAtDateTime = new Date(dateTimePickerVal)
    currentEmailDelayed = @currentEmailDelayed

    @sendEmailWithCallback(
      (emailToSend) =>
        deferred = $.Deferred()

        if currentEmailDelayed?
          currentEmailDelayed.destroy().then ->
            deferred.resolve()
        else
          deferred.resolve()

        deferred.done =>
          emailToSend.sendLater(sendAtDateTime).done (data) =>
            scheduleEmail = new TuringEmailApp.Models.DelayedEmail(data)
            @trigger "addScheduleEmail", scheduleEmail
            @app.showAlert("Email scheduled to be sent.", "alert-success", 5000)

      (draftToSend) =>
        draftToSend.sendLater(sendAtDateTime).done(
          => @trigger "change:draft", this, model, @emailThreadParent
        )
    )

  sendUndoableEmail: (emailToSend, currentEmailDelayed) ->
    console.log "ComposeView sendUndoableEmail! - Setting up Undo button"
    @showEmailSentAlert(emailToSend.toJSON())

    TuringEmailApp.sendEmailTimeout = setTimeout (=>
      console.log "ComposeView sendUndoableEmail CALLBACK! doing send"
      @removeEmailSentAlert()

      deferred = $.Deferred()
      if currentEmailDelayed?
        currentEmailDelayed.destroy().then ->
          deferred.resolve()
      else
        deferred.resolve()

      deferred.done =>
        if emailToSend instanceof TuringEmailApp.Models.EmailDraft
          console.log "sendDraft!"
          emailToSend.sendDraft(
            @app
            =>
              @trigger "change:draft", this, emailToSend, @emailThreadParent
            =>
              @sendUndoableEmailError(emailToSend.toJSON())
          )
        else
          console.log "send email!"
          emailToSend.sendEmail().done(=>
            @trigger "change:draft", this, emailToSend, @emailThreadParent
          ).fail(=>
            @sendUndoableEmailError(emailToSend.toJSON())
          )
    ), 5000

  sendUndoableEmailError: (emailToSendJSON) ->
    console.log "sendUndoableEmailError!!!"

    @loadEmail(emailToSendJSON, @emailThreadParent)
    @show()

    @app.showAlert("There was an error in sending your email", "alert-error", 5000)
