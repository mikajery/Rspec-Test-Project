describe "QuickReplyView", ->
  beforeEach ->
    specStartTuringEmailApp()

    emailThreadAttributes = FactoryGirl.create("EmailThread")
    emailThreadAttributes.emails.push(FactoryGirl.create("Email", draft_id: "draft"))
    @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes,
      app: TuringEmailApp
      emailThreadUID: emailThreadAttributes.uid
      demoMode: false
    )

    @loadEmailThreadStub = sinon.stub(@emailThread, "load", ->)

    @uploadAttachmentPostJSON = fixture.load("upload_attachment_post.fixture.json", true)
    @emailTemplatesJSON = FactoryGirl.createLists("EmailTemplate", FactoryGirl.SMALL_LIST_SIZE)

    @emailThreadView = new TuringEmailApp.Views.PrimaryPane.EmailThreads.EmailThreadView(
      app: TuringEmailApp
      model: @emailThread
      emailTemplatesJSON: @emailTemplatesJSON
      uploadAttachmentPostJSON: @uploadAttachmentPostJSON
    )
    @emailThreadView.render()
    $("body").append(@emailThreadView.$el)

    @loadEmailThreadStub.args[0][0].success()

    @quickReplyView = new TuringEmailApp.Views.PrimaryPane.EmailThreads.QuickReplyView(
      el: @emailThreadView.$el.find(".email-response-btn-group").first()
      emailThreadView: @emailThreadView
    )

  afterEach ->
    @emailThreadView.$el.remove()

    @loadEmailThreadStub.restore()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@quickReplyView.template).toEqual JST["backbone/templates/primary_pane/email_threads/quick_reply_dropdown"]

  it "correctly sets the email thread view instance variable", ->
    expect(@quickReplyView.emailThreadView).toEqual @emailThreadView

  describe "#render", ->
    beforeEach ->
      @quickReplyView.render()

    it "attaches click handlers to the single click communication links in the dropdown", ->
      expect(@quickReplyView.$el.parent().find(".quick-reply-option")).toHandle("click")

    describe "when a quick reply link is clicked", ->
      beforeEach ->
        TuringEmailApp.views.composeView.render()
        $("body").append(TuringEmailApp.views.composeView.$el)

      it "triggers replyClicked", ->
        spy = sinon.backbone.spy(@quickReplyView.emailThreadView, "replyClicked")
        @quickReplyView.$el.parent().find(".quick-reply-option").first().click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

      # TODO figure out how to test the insertion of: Sent with Turing Quick Response.
