describe "EmbeddedComposeView", ->
  beforeEach ->
    specStartTuringEmailApp()

    emailThreadAttributes = FactoryGirl.create("EmailThread")
    @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes,
      app: TuringEmailApp
      emailThreadUID: emailThreadAttributes.uid
      demoMode: false
    )

    @embeddedComposeView = new TuringEmailApp.Views.EmbeddedComposeView(
      app: TuringEmailApp
      uploadAttachmentPostJSON: fixture.load("upload_attachment_post.fixture.json", true)
    )

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@embeddedComposeView.template).toEqual JST["backbone/templates/compose/_compose_form"]

  describe "after render", ->
    beforeEach ->

      @draftEmail = @emailThread.get("emails")[0]
      @draftEmail.draft_id = 1

      @embeddedComposeView.email = @draftEmail
      @embeddedComposeView.emailThread = @emailThread
      @embeddedComposeView.render()

    describe "#render", ->

      it "calls setupComposeView", ->
        spy = sinon.spy(@embeddedComposeView, "setupComposeView")
        @embeddedComposeView.render()
        expect(spy).toHaveBeenCalled()
        spy.restore()

      it "sets the current email draft", ->
        currentEmailDraft = new TuringEmailApp.Models.EmailDraft(@draftEmail)
        expect(@embeddedComposeView.currentEmailDraft.attributes).toEqual currentEmailDraft.attributes

    describe "#hide", ->

      it "hides the embedded compose view", ->
        hideSpy = sinon.spy($.prototype, "hide")

        @embeddedComposeView.hide()

        expect(hideSpy).toHaveBeenCalled()
        hideSpy.restore()
