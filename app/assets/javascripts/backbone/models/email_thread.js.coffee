class TuringEmailApp.Models.EmailThread extends Backbone.Model
  idAttribute: "uid"


  @SetThreadPropertiesFromJSON: (threadJSON, demoMode) ->
    threadJSON.loaded = true
    threadJSON.demoMode = demoMode

    for email in threadJSON.emails
      if email.from_address != TuringEmailApp.models.user.get("email")
        lastEmail = email
        break

    lastEmail = threadJSON.emails[0] if not lastEmail?

    threadJSON.snippet = lastEmail.snippet

    threadJSON.from_name = lastEmail.from_name
    threadJSON.from_address = lastEmail.from_address
    threadJSON.date = new Date(lastEmail.date)
    threadJSON.subject = lastEmail.subject

    folderIDs = []

    threadJSON.seen = true
    for email in threadJSON.emails
      email.date = new Date(email.date)

      threadJSON.seen = false if !email.seen
      folderIDs = folderIDs.concat(email.folder_ids) if email.folder_ids?

    threadJSON.emails.sort (a, b) -> a.date - b.date

    threadJSON.folder_ids = _.uniq(folderIDs)


  @setThreadParsedProperties: (threadParsed, messages, messageInfo) ->
    threadParsed.snippet = messageInfo.snippet

    emailParsed = {}
    TuringEmailApp.Models.Email.parseHeaders(emailParsed, messageInfo.payload.headers)

    _.extend(threadParsed, _.pick(emailParsed, ["from_name", "from_address", "date", "subject"]))

    folderIDs = []

    threadParsed.seen = true
    for message in messages
      if message.labelIds?
        folderIDs = folderIDs.concat(message.labelIds)
        threadParsed.seen = false if message.labelIds.indexOf("UNREAD") != -1

    threadParsed.folder_ids = _.uniq(folderIDs)

    return threadParsed


  @createGmailLabelRequest: (labelName, labelListVisibility="labelShow", messageListVisibility="show") ->
    gapi.client.gmail.users.labels.create({userId: "me"},
                                          {name: labelName, labelListVisibility: labelListVisibility, messageListVisibility: messageListVisibility})


  @removeGmailLabelRequest: (emailThreadUID, labelID) ->
    gapi.client.gmail.users.threads.modify({userId: "me", id: emailThreadUID}, {removeLabelIds: [labelID]})

  @removeFromFolder: (app, emailThreadUIDs, emailFolderID, success, error, demoMode=true) ->
    if demoMode
      postData =
        email_thread_uids: emailThreadUIDs
        email_folder_id: emailFolderID

      $.post("/api/v1/email_threads/remove_from_folder", postData).done(-> success?()).fail(-> error?())
    else
      if emailFolderID == "SENT"
        error?()
        return

      for emailThreadUID in emailThreadUIDs
        googleRequest(
          app
          => @removeGmailLabelRequest(emailThreadUID, emailFolderID)
          success
          error
        )


  @trashRequest: (emailThreadUID) ->
    gapi.client.gmail.users.threads.trash(userId: "me", id: emailThreadUID)


  @trash: (app, emailThreadUIDs, demoMode=true) ->
    if demoMode
      postData = email_thread_uids: emailThreadUIDs
      $.post("/api/v1/email_threads/trash", postData)
    else
      for emailThreadUID in emailThreadUIDs
        googleRequest(
          app
          => @trashRequest(emailThreadUID)
        )


  @snooze: (app, emailThreadUIDs, minutes) ->
    postData =
      email_thread_uids: emailThreadUIDs
      minutes: minutes

    $.post("/api/v1/email_threads/snooze", postData)


  @deleteDraftRequest: (draftID) ->
    gapi.client.gmail.users.drafts.delete(userId: "me", id: draftID)


  @deleteDraft: (app, draftIDs) ->
    for draftID in draftIDs
      googleRequest(
        app
        => @deleteDraftRequest(draftID)
      )


  @applyGmailLabelRequest: (emailThreadUID, labelID) ->
    gapi.client.gmail.users.threads.modify({userId: "me", id: emailThreadUID}, {addLabelIds: [labelID]})


  @applyGmailLabel: (app, emailThreadUIDs, labelID, labelName, success, error, demoMode) ->
    if demoMode
      postData = email_thread_uids: emailThreadUIDs
      postData.gmail_label_id = labelID if labelID?
      postData.gmail_label_name = labelName if labelName?

      return $.post("/api/v1/email_threads/apply_gmail_label", postData).done(
        (data) -> success?(data)).fail(
        (data) -> error?(data)
      )
    else
      run = (response) =>
        if response?
          labelID = response.result.id

        for emailThreadUID in emailThreadUIDs
          googleRequest(
            app
            => @applyGmailLabelRequest(emailThreadUID, labelID)
            success
            error
          )

      if labelID?
        run()
      else
        googleRequest(
          app
          => @createGmailLabelRequest(labelName)
          (response) -> run(response)
          error
        )


  @modifyGmailLabelsRequest: (emailThreadUID, addLabelIDs, removeLabelIDs) ->
    removeLabelIDs = _.filter(removeLabelIDs, (labelID) -> labelID != "SENT")

    gapi.client.gmail.users.threads.modify({userId: "me", id: emailThreadUID},
                                           {addLabelIds: addLabelIDs, removeLabelIds: removeLabelIDs})


  @moveToFolder: (app, emailThreadUIDs, folderID, folderName, currentFolderIDs, success, error, demoMode) ->
    if demoMode
      postData = email_thread_uids: emailThreadUIDs
      postData.email_folder_id = folderID if folderID?
      postData.email_folder_name = folderName if folderName?

      return $.post("/api/v1/email_threads/move_to_folder", postData).done(
        (data) -> success?(data)
      ).fail(
        (data) -> error?(data)
      )
    else
      run = (response) =>
        if response?
          folderID = response.result.id

        for emailThreadUID in emailThreadUIDs
          googleRequest(
            app
            => @modifyGmailLabelsRequest(emailThreadUID, [folderID], currentFolderIDs)
            success
            error
          )

      if folderID?
        run()
      else
        googleRequest(
          app
          => @createGmailLabelRequest(folderName)
          (response) -> run(response)
          error
        )


  validation:
    uid:
      required: true

    emails:
      required: true
      isArray: true


  initialize: (attributes, options) ->
    @app  = options.app
    @page = 1

    @set("demoMode", if options.demoMode? then options.demoMode else (if attributes?.demoMode? then attributes.demoMode else true))

    if attributes?.uid?
      @emailThreadUID = attributes.uid

    if options?.emailThreadUID?
      @emailThreadUID = options.emailThreadUID

    @listenTo(@, "seenChanged", @seenChanged)


  ###############
  ### Network ###
  ###############

  url: ->
    "/api/v1/email_threads/show/#{@emailThreadUID}?page=#{@page}"


  load: (options, force=false) ->
    if @get("loaded") and not force
      options.success?()
    else
      if @loading
        setTimeout(
          => @load(options, force)
          250
        )

        return

      @loading = true
      @emailThreadUID = @get("uid")

      options ?= {}
      success = options.success
      options.success = (model, response) =>
        draftInfo = @get("draftInfo")
        if draftInfo
          message = _.find(@get("emails"), (emailJSON) -> emailJSON.uid == draftInfo.message.id)
          message.draft_id = draftInfo.id if message?

        @set("loaded", true)
        @loading = false

        TuringEmailApp.
          Models.
          EmailThread.
          SetThreadPropertiesFromJSON(response, @get("demo_mode"))

        success?()

      error = options.error
      options.error = =>
        @loading = false
        error?()

      @fetch(options)


  sync: (method, model, options) ->
    if method != "read" || @get("demoMode")
      super(method, model, options)
    else
      googleRequest(
        @app
        => @threadsGetRequest()
        (response) => @processThreadsGetRequest(response, options)
        options.error
      )

      @trigger("request", model, null, options)


  threadsGetRequest: ->
    return gapi.client.gmail.users.threads.get(userId: "me", id: @emailThreadUID)


  processThreadsGetRequest: (response, options) ->
    threadJSON = @parseThreadInfo(response.result)
    options.success?(threadJSON)


  parseThreadInfo: (threadInfo) ->
    lastMessageInfo = _.last(threadInfo.messages)
    threadParsed = uid: threadInfo.id
    TuringEmailApp.Models.EmailThread.setThreadParsedProperties(threadParsed, threadInfo.messages, lastMessageInfo)

    threadParsed.emails = _.map(threadInfo.messages, (message) ->
      emailParsed = {}

      emailParsed.uid = message.id
      emailParsed.snippet = message.snippet
      emailParsed.folder_ids = message.labelIds
      emailParsed.seen = not message.labelIds? || message.labelIds.indexOf("UNREAD") == -1

      TuringEmailApp.Models.Email.parseHeaders(emailParsed, message.payload.headers)

      if message.payload.body.size > 0
        emailParsed.body_text_encoded = message.payload.body.data
        emailParsed.body_text = base64_decode_urlsafe(emailParsed.body_text_encoded)

      emailParsed.email_attachments = []
      TuringEmailApp.Models.Email.parseBody(emailParsed, message.payload.parts)

      return emailParsed
    )

    return threadParsed


  ##############
  ### Events ###
  ##############

  threadsModifyUnreadRequest: (seenValue) ->
    if seenValue
      body = removeLabelIds: ["UNREAD"]
    else
      body = addLabelIds: ["UNREAD"]

    gapi.client.gmail.users.threads.modify(
      {userId: "me", id: @get("uid")},
      body
    )


  seenChanged: (model, seenValue) ->
    if @get("demoMode")
      postData = {}
      emailUIDs = []

      for email in @get("emails")
        email.seen = seenValue
        emailUIDs.push email.uid

      return if emailUIDs.length is 0

      postData.email_uids = emailUIDs
      postData.seen = seenValue

      url = "/api/v1/emails/set_seen"
      $.post url, postData
    else
      googleRequest(
        @app
        => @threadsModifyUnreadRequest(seenValue)
      )


  ###############
  ### Actions ###
  ###############

  removeFromFolder: (emailFolderID) ->
    TuringEmailApp.Models.EmailThread.removeFromFolder(@app, [@get("uid")], emailFolderID, undefined, undefined, @get("demoMode"))


  trash: ->
    TuringEmailApp.Models.EmailThread.trash(@app, [@get("uid")], @get("demoMode"))


  snooze: (minutes) ->
    TuringEmailApp.Models.EmailThread.snooze(@app, [@get("uid")], minutes)


  deleteDraft: ->
    TuringEmailApp.Models.EmailThread.deleteDraft(@app, [@get("draft_id")])


  applyGmailLabel: (labelID, labelName) ->
    TuringEmailApp.Models.EmailThread.applyGmailLabel(@app, [@get("uid")], labelID, labelName,
      (data) => @trigger("change:folder", this, data)
      undefined,
      @get("demoMode")
    )


  moveToFolder: (folderID, folderName) ->
    TuringEmailApp.Models.EmailThread.moveToFolder(@app, [@get("uid")], folderID, folderName, @get("folder_ids"),
      (data) => @trigger("change:folder", this, data)
      undefined,
      @get("demoMode")
    )

  setSeen: (seenValue, options) ->
    if @get("seen") != seenValue
      @set("seen", seenValue)
      @trigger("seenChanged", @, seenValue) unless options?.silent?


  ##################
  ### Formatters/Retrievers ###
  ##################

  numEmails: ->
    @get("emails_count")


  numEmailsText: ->
    num_messages = @numEmails()
    return if num_messages is 1 then "" else "(" + num_messages + ")"


  fromPreview: ->
    fromAddress = @get("from_address")
    fromName = @get("from_name")

    if fromAddress is TuringEmailApp.models.user.get("email")
      return "me"
    else
      return (if fromName? and fromName.trim() != "" then fromName else fromAddress)


  subjectPreview: ->
    subject = @get("subject")
    return if subject is "" then "(no subject)" else subject


  datePreview: ->
    return TuringEmailApp.Models.Email.localDateString(@get("date"))


  hasAttachment: ->
    for email in @get("emails")
      return true if email.email_attachments.length > 0
    return false


  primaryEmailFolder: ->
    return @get("emails")?[0]?["folder_ids"]?[0]
