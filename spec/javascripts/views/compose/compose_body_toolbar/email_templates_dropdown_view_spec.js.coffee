describe "EmailTemplatesDropdownView", ->
  beforeEach ->
    specStartTuringEmailApp()

    emailTemplates = new TuringEmailApp.Collections.EmailTemplatesCollection()
    emailTemplates.add(FactoryGirl.createLists("EmailTemplate", FactoryGirl.SMALL_LIST_SIZE))

    @emailTemplatesDropdownView = new TuringEmailApp.Views.EmailTemplatesDropdownView(
      collection: emailTemplates
      el: TuringEmailApp.views.composeView.$el.find(".send-later-button, .send-button")
      composeView: TuringEmailApp.views.composeView
    )

    @server = sinon.fakeServer.create()

  afterEach ->
    specStopTuringEmailApp()
    @server.restore()

  it "has the right template", ->
    expect(@emailTemplatesDropdownView.template).toEqual JST["backbone/templates/compose/compose_body_toolbar/email_templates_dropdown"]

  describe "#render", ->
    beforeEach ->
      @emailTemplatesDropdownView.render()

    it "renders the email template dropdown", ->
      expect(TuringEmailApp.views.composeView.$el).toContain(".email-templates-dropdown-div")

    it "renders the email template links", ->
      for emailTemplate in @emailTemplatesDropdownView.collection.models
        expect(@emailTemplatesDropdownView.$el.parent()).toContainText(emailTemplate.get("name"))

    it "renders the email template create link", ->
      expect(@emailTemplatesDropdownView.$el.parent()).toContain(".create-email-template")

    it "renders the email template delete link", ->
      expect(@emailTemplatesDropdownView.$el.parent()).toContain(".delete-email-template")

    it "renders the email template update link", ->
      expect(@emailTemplatesDropdownView.$el.parent()).toContain(".update-email-template")

    describe "#createEmailTemplate", ->
      beforeEach ->
        @saveStub = sinon.stub(TuringEmailApp.Models.EmailTemplate.__super__,  "save", ->)

      afterEach ->
        @saveStub.restore()

      it "saves the model", ->
        @emailTemplatesDropdownView.newEmailTemplate.set("name", "test name")
        @emailTemplatesDropdownView.createEmailTemplate()
        expect(@saveStub).toHaveBeenCalled()

    describe "#setupCreateEmailTemplate", ->
      beforeEach ->
        @dialogStub = sinon.stub($.prototype, "dialog", ->)

      afterEach ->
        @dialogStub.restore()

      it "sets up the dialog", ->
        @emailTemplatesDropdownView.setupCreateEmailTemplate()
        expect(@dialogStub).toHaveBeenCalled()

    describe "#showSuccessOfCreateEmailTemplate", ->
      beforeEach ->
        @dialogStub = sinon.stub($.prototype, "dialog", ->)
        @fetchStub = sinon.stub(TuringEmailApp.Collections.EmailTemplatesCollection.__super__,  "fetch", ->)

      afterEach ->
        @dialogStub.restore()
        @fetchStub.restore()

      it "show the alert", ->
        spy = sinon.spy(TuringEmailApp, "showAlert")
        @emailTemplatesDropdownView.showSuccessOfCreateEmailTemplate()
        expect(spy).toHaveBeenCalled()
        spy.restore()

      it "fetches the collection", ->
        @emailTemplatesDropdownView.showSuccessOfCreateEmailTemplate()
        expect(@fetchStub).toHaveBeenCalled()

      it "closes the dialog", ->
        @emailTemplatesDropdownView.showSuccessOfCreateEmailTemplate()
        expect(@dialogStub).toHaveBeenCalledWith("close")

    describe "#deleteEmailTemplate", ->
      beforeEach ->
        @destroyStub = sinon.stub(TuringEmailApp.Models.EmailTemplate.__super__,  "destroy", ->)
        @fetchStub = sinon.stub(TuringEmailApp.Collections.EmailTemplatesCollection.__super__,  "fetch", ->)

      afterEach ->
        @destroyStub.restore()
        @fetchStub.restore()

      it "destroys the model", ->
        @emailTemplatesDropdownView.deleteEmailTemplate()
        expect(@destroyStub).toHaveBeenCalled()

      it "show the alert", ->
        spy = sinon.spy(TuringEmailApp, "showAlert")
        @emailTemplatesDropdownView.deleteEmailTemplate()
        expect(spy).toHaveBeenCalled()
        spy.restore()

      it "fetches the collection", ->
        @emailTemplatesDropdownView.deleteEmailTemplate()
        expect(@fetchStub).toHaveBeenCalled()

    describe "#setupDeleteEmailTemplate", ->
      beforeEach ->
        @dialogStub = sinon.stub($.prototype, "dialog", ->)

      afterEach ->
        @dialogStub.restore()

      it "sets up the dialog", ->
        @emailTemplatesDropdownView.setupDeleteEmailTemplate()
        expect(@dialogStub).toHaveBeenCalled()

    describe "#updateEmailTemplate", ->
      beforeEach ->
        @saveStub = sinon.stub(TuringEmailApp.Models.EmailTemplate.__super__,  "save", ->)

      afterEach ->
        @saveStub.restore()

      it "saves the model", ->
        @emailTemplatesDropdownView.updateEmailTemplate()
        expect(@saveStub).toHaveBeenCalled()

    describe "#showSuccessOfUpdateEmailTemplate", ->
      beforeEach ->
        @dialogStub = sinon.stub($.prototype, "dialog", ->)
        @fetchStub = sinon.stub(TuringEmailApp.Collections.EmailTemplatesCollection.__super__,  "fetch", ->)

      afterEach ->
        @dialogStub.restore()
        @fetchStub.restore()

      it "show the alert", ->
        spy = sinon.spy(TuringEmailApp, "showAlert")
        @emailTemplatesDropdownView.showSuccessOfUpdateEmailTemplate()
        expect(spy).toHaveBeenCalled()
        spy.restore()

      it "fetches the collection", ->
        @emailTemplatesDropdownView.showSuccessOfUpdateEmailTemplate()
        expect(@fetchStub).toHaveBeenCalled()

      it "closes the dialog", ->
        @emailTemplatesDropdownView.showSuccessOfUpdateEmailTemplate()
        expect(@dialogStub).toHaveBeenCalledWith("close")

    describe "#setupUpdateEmailTemplate", ->
      beforeEach ->
        @dialogStub = sinon.stub($.prototype, "dialog", ->)

      afterEach ->
        @dialogStub.restore()

      it "sets up the dialog", ->
        @emailTemplatesDropdownView.setupUpdateEmailTemplate()
        expect(@dialogStub).toHaveBeenCalled()
