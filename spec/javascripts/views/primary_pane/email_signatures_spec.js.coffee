describe "EmailSignaturesView", ->
  beforeEach ->
    specStartTuringEmailApp()
    emailSignatures = new TuringEmailApp.Collections.EmailSignaturesCollection(FactoryGirl.createLists("EmailSignature", FactoryGirl.SMALL_LIST_SIZE))

    @emailSignaturesView = new TuringEmailApp.Views.PrimaryPane.EmailSignaturesView(
      el: @emailSignaturesDiv
      app: TuringEmailApp
      emailSignatures: emailSignatures
      emailSignatureUID: TuringEmailApp.models.userConfiguration.get("email_signature_uid")
    )
    @emailSignaturesView.render()

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@emailSignaturesView.template).toEqual JST["backbone/templates/primary_pane/email_signatures"]

  it "has the right events", ->
    expect(@emailSignaturesView.events["click .tm_signatures .update-email-signature"]).toEqual "updateEmailSignature"
    expect(@emailSignaturesView.events["click .tm_signatures .delete-email-signature"]).toEqual "deleteEmailSignature"
    expect(@emailSignaturesView.events["click .create-email-signature"]).toEqual "createEmailSignature"

  describe "#render", ->
    beforeEach ->
      @setupSignatureEditorStub = sinon.stub(@emailSignaturesView, "setupSignatureEditor")
      @setupCreateEmailSignatureStub = sinon.stub(@emailSignaturesView, "setupCreateEmailSignature")

      @emailSignaturesView.render()

    afterEach ->
      @setupSignatureEditorStub.restore()
      @setupCreateEmailSignatureStub.restore()

    it "calls setupSignatureEditor", ->
      expect(@setupSignatureEditorStub).toHaveBeenCalled()

    it "calls setupCreateEmailSignature", ->
      expect(@setupCreateEmailSignatureStub).toHaveBeenCalled()

  xdescribe "after render", ->
    describe "#setupSignatureEditor", ->
      it "calls redactor", ->
        @redactorStub = sinon.stub($.fn, "redactor", ->)
        @emailSignaturesView.setupSignatureEditor()
        params =
          focus: true
          minHeight: 200
          maxHeight: 400
          linebreaks: true
          plugins: ['fontfamily', 'fontcolor', 'fontsize']
        expect(@redactorStub).toHaveBeenCalledWith(params)
        @redactorStub.restore()

    describe "#setupCreateEmailSignature", ->
      it "calls the dialog", ->
        @dialogStub = sinon.stub($.fn, "dialog", ->)
        @emailSignaturesView.setupCreateEmailSignature()
        expect(@dialogStub).toHaveBeenCalled()
        @dialogStub.restore()

      it "sets the dialog", ->
        @emailSignaturesView.setupCreateEmailSignature()
        settings = $(".create-email-signatures-dialog-form").dialog( "option" )

        expect( settings.autoOpen ).toEqual(false)
        expect( settings.width ).toEqual(400)
        expect( settings.modal ).toEqual(true)
        expect( settings.resizable ).toEqual(false)
        expect( settings.dialogClass ).toEqual('create-email-signatures-dialog')
        expect( settings.buttons[0].text ).toEqual("Cancel")
        expect( settings.buttons[0]["class"] ).toEqual('tm_button')
        expect( settings.buttons[1].text ).toEqual("Create")
        expect( settings.buttons[1]["class"] ).toEqual('tm_button tm_button-blue')

    describe "after the email signature dialog is set up", ->
      beforeEach ->
        @emailSignaturesView.setupCreateEmailSignature()

      describe "when Cancel button is clicked", ->
        beforeEach ->
          @dialogStub = sinon.stub($.fn, "dialog", ->)
          @emailSignaturesView.$el.find(".create-email-signatures-dialog .tm_button")[0].click()

        afterEach ->
          @dialogStub.restore()

        it "closes the dialog", ->
          expect(@dialogStub).toHaveBeenCalledWith("close")

      describe "when Create button is clicked", ->
        beforeEach ->
          @server = sinon.fakeServer.create()

        afterEach ->
          @server.restore()

        it "creates new email signature", ->
          $(".create-email-signatures-dialog .tm_button-blue").click()
          request = @server.requests[@server.requests.length - 1]
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual "/api/v1/email_signatures"

        describe "when the server responds successfully", ->
          beforeEach ->
            @server.respondWith "POST", "/api/v1/email_signatures", JSON.stringify({})

          it "shows the alert", ->
            showAlertStub = sinon.stub(TuringEmailApp, "showAlert")
            $(".create-email-signatures-dialog .tm_button-blue").click()
            @server.respond()
            expect(showAlertStub).toHaveBeenCalledWith("You have successfully created an email signature!", "alert-success", 5000)
            showAlertStub.restore()

          it "closes the dialog", ->
            dialogStub = sinon.stub($.fn, "dialog", ->)
            $(".create-email-signatures-dialog .tm_button-blue").click()
            @server.respond()
            expect(dialogStub).toHaveBeenCalledWith("close")
            dialogStub.restore()

  describe "#createEmailSignature", ->
    it "calls opens the dialog", ->
      @dialogStub = sinon.stub($.fn, "dialog", ->)
      @emailSignaturesView.createEmailSignature()
      expect(@dialogStub).toHaveBeenCalledWith("open")
      @dialogStub.restore()

  describe "#updateEmailSignature", ->
    beforeEach ->
      @server = sinon.fakeServer.create()

    afterEach ->
      @server.restore()

    it "updates the email signature", ->
      emailSignature = @emailSignaturesView.emailSignatures.at(0)
      $(@emailSignaturesView.$el.find(".tm_signatures .update-email-signature")[0]).click()
      request = @server.requests[@server.requests.length - 1]
      expect(request.method).toEqual "PATCH"
      expect(request.url).toEqual "/api/v1/email_signatures/"+emailSignature.id

    describe "when the server responds successfully", ->
      beforeEach ->
        @emailSignature = @emailSignaturesView.emailSignatures.at(0)
        @server.respondWith "PATCH", "/api/v1/email_signatures/"+@emailSignature.id, JSON.stringify({})

      it "shows the alert", ->
        showAlertStub = sinon.stub(TuringEmailApp, "showAlert")
        $(@emailSignaturesView.$el.find(".tm_signatures .update-email-signature")[0]).click()
        @server.respond()
        expect(showAlertStub).toHaveBeenCalledWith("You have successfully updated an email signature!", "alert-success", 5000)
        showAlertStub.restore()

      it "fetches the email signatures", ->
        fetchStub = sinon.stub(@emailSignaturesView.emailSignatures, "fetch")
        $(@emailSignaturesView.$el.find(".tm_signatures .update-email-signature")[0]).click()
        @server.respond()
        expect(fetchStub).toHaveBeenCalledWith(reset: true)
        fetchStub.restore()

  describe "#deleteEmailSignature", ->
    beforeEach ->
      @server = sinon.fakeServer.create()

    afterEach ->
      @server.restore()

    it "updates the email signature", ->
      $(@emailSignaturesView.$el.find(".tm_signatures .delete-email-signature")[0]).click()
      request = @server.requests[@server.requests.length - 1]
      expect(request.method).toEqual "GET"
      expect(request.url).toEqual "/api/v1/email_signatures"

    it "shows the alert", ->
      showAlertStub = sinon.stub(TuringEmailApp, "showAlert")
      $(@emailSignaturesView.$el.find(".tm_signatures .delete-email-signature")[0]).click()
      @server.respond()
      expect(showAlertStub).toHaveBeenCalledWith("You have successfully deleted an email signature!", "alert-success", 5000)
      showAlertStub.restore()

    it "fetches the email signatures", ->
      fetchStub = sinon.stub(@emailSignaturesView.emailSignatures, "fetch")
      $(@emailSignaturesView.$el.find(".tm_signatures .delete-email-signature")[0]).click()
      @server.respond()
      expect(fetchStub).toHaveBeenCalledWith(reset: true)
      fetchStub.restore()

    describe "when the email signature uid is emailSignatureUID", ->
      beforeEach ->
        emailSignature = @emailSignaturesView.emailSignatures.at(0)
        @emailSignaturesView.emailSignatureUID = emailSignature.get("uid")

      it "triggers currentEmailSignatureDeleted", ->
        triggerStub = sinon.stub(@emailSignaturesView, "trigger", ->)
        $(@emailSignaturesView.$el.find(".tm_signatures .delete-email-signature")[0]).click()

        expect(triggerStub).toHaveBeenCalled()
        triggerStub.restore()

  describe "#getSignatureBodyHtml", ->
    beforeEach ->
      seededChance = new Chance(1)
      @randomText = seededChance.string({length: 20})
      @emailSignaturesView.$(".tm_signature-compose .redactor-editor").html(@randomText)

    it "gets the signature body html", ->
      expect(@emailSignaturesView.getSignatureBodyHtml()).toEqual @randomText

  describe "#getSignatureBodyText", ->
    beforeEach ->
      seededChance = new Chance(1)
      @randomText = seededChance.string({length: 20})
      @emailSignaturesView.$(".tm_signature-compose .redactor-editor").text(@randomText)

    it "gets the signature body text", ->
      expect(@emailSignaturesView.getSignatureBodyText()).toEqual @randomText
