TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.EmailThreads ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailThreads.EmailThreadView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/primary_pane/email_threads/email_thread"]

  initialize: (options) ->
    super(options)

    @app = options.app
    @uploadAttachmentPostJSON = options.uploadAttachmentPostJSON
    @emailTemplatesJSON = options.emailTemplatesJSON

    if @model
      @listenTo(@model, "change", @render)
      @listenTo(@model, "destroy", @remove)

    @emails            = new Backbone.Collection
    @emails.model      = TuringEmailApp.Models.BaseModel
    @emails.comparator = (a, b) -> a.get("date") - b.get("date")


  render: ->
    return if @rendering

    $parent = @$el.parent()
    $parent.off "scroll.thread"

    if @model
      @seenChanging = @model._changing && @model.changed.seen?
      @rendering = true

      @$el.html('<div class="tm_mail-email-thread-loading" style="display: block;"><svg class="icon busy-indicator"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/images/symbols.svg#busy-indicator"></use></svg><span>Loading...</span></div>')

      force =
        ((@emails.length < @model.get("emails_count")) &&
         (@emails.length < (@model.page * 25)))

      @model.load(
        success: =>
          @model.setSeen(true) if not @seenChanging
          @emails.set(@model.get("emails"), {"remove": false})

          modelJSON = @model.toJSON()
          modelJSON["emails"] = @emails.toJSON()

          @addPreviewDataToTheModelJSON(modelJSON)

          @$el.html(@template(modelJSON))
          @$el.addClass("email-thread")

          @$firstEmail = @$(".tm_email").first()
          $parent.on  "scroll.thread", =>
            if (($parent.scrollTop() < @$firstEmail.position().top) &&
                (@model.get("emails_count") > @emails.length))
              @currentEmailUID = @$firstEmail.attr("data-uid")
              @model.page += 1
              @render()

          @renderDrafts()

          @setupEmailExpandAndCollapse()
          @setupLinks()
          @setupButtons()
          @setupQuickReplyButton()
          @setupTooltips()
          @setupHoverPreviews()
          @setupAttachmentLinks()
          @moveToLatestUnreadEmail()

          @rendering = false

        error: =>
          @rendering = false
        ,
          force
      )
    else
      @$el.empty()

    @


  addPreviewDataToTheModelJSON: (modelJSON) ->
    modelJSON["fromPreview"] = @model.fromPreview()
    modelJSON["subjectPreview"] = @model.subjectPreview()
    modelJSON["datePreview"] = @model.datePreview()

    for email in modelJSON.emails
      email["datePreview"] = TuringEmailApp.Models.Email.localDateString(email["date"])
      if email.from_name?
        email["fromPreview"] = email.from_name
      else
        email["fromPreview"] = email.from_address


  renderDrafts: ->
    @embeddedComposeViews = {}

    emails = @model.get("emails")
    for email in emails
      if email.draft_id?
        embeddedComposeView = @embeddedComposeViews[email.uid] = new TuringEmailApp.Views.EmbeddedComposeView(
          app: TuringEmailApp
          emailTemplatesJSON: @emailTemplatesJSON
          uploadAttachmentPostJSON: @uploadAttachmentPostJSON
        )
        embeddedComposeView.emailThread = @model
        embeddedComposeView.render()
        @$(".embedded_compose_view_" + email.uid).append(embeddedComposeView.$el)
        embeddedComposeView.loadEmailDraft(_.last(emails), @model)


  setupEmailExpandAndCollapse: ->
    @$(".email-collapse-expand").click (evt) =>
      emailHeader = $(evt.currentTarget).parent()
      email = emailHeader.parent()
      emailBody = email.find(".tm_email-body")

      email.toggleClass("tm_email-collapsed")

      emailObj = @emails.get(email.attr("data-uid")).toJSON()

      # Append body if empty
      if !$.trim(emailBody.html())
        body = if emailObj.html_part then "<div class=\"tm_email-body-html\">#{ emailObj.html_part }</div>"
        else if emailObj.text_part then "<div class=\"tm_email-body-pre\">#{emailObj.text_part}</div>"
        else if emailObj.body_text then "<pre class=\"tm_email-body-pre\">#{emailObj.body_text}</div>"

        emailBody.html body

      # trigger expand email event
      @trigger("expand:email", this, emailObj)

      emailHeader.parent().siblings(".tm_email").each ->
        $(this).addClass "tm_email-collapsed"


  #TODO add tests.
  setupLinks: ->
    @$(".tm_email-body a").click (evt) ->
      evt.preventDefault()

      targetUrl = $(evt.target).attr("href")
      window.open(targetUrl, '_blank')


  setupButtons: ->
    if !TuringEmailApp.isSplitPaneMode()
      @$(".email-back-button").click =>
        @trigger("goBackClicked", this)

    @$(".email_reply_button").click =>
      console.log "replyClicked"
      @trigger("replyClicked", this)

    @$(".reply-to-all").click =>
      console.log "replyToAllClicked"
      @trigger("replyToAllClicked", this)

    @$(".email_forward_button").click =>
      console.log "forwardClicked"
      @trigger("forwardClicked", this)


  setupQuickReplyButton: ->
    @$(".email-response-btn-group").each ->
      quickReplyView = new TuringEmailApp.Views.PrimaryPane.EmailThreads.QuickReplyView(
        el: $(@)
        emailThreadView: TuringEmailApp.views.mainView.currentEmailThreadView
      )
      quickReplyView.render()


  setupHoverPreviews: ->
    return


  # TODO write tests
  setupAttachmentLinks: ->
    @$(".tm_email-attachment").click (evt) =>
      s3Key = $(evt.currentTarget).attr("href")

      TuringEmailApp.Models.EmailAttachment.Download(@app, s3Key)


  setupTooltips: ->
    @$(".email-from").tooltip()


  moveToLatestUnreadEmail: ->
    if @currentEmailUID
      $currentEmail = @$(".tm_email[data-uid=\"#{@currentEmailUID}\"]").first()
    else
      $currentEmail = @$(".tm_email:not(.tm_email-collapsed)").first()

    $parent = @$el.parent()

    $parent.scrollTop $parent.scrollTop() + $currentEmail.position().top
