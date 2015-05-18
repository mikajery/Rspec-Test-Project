describe "ComposeView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @composeView = TuringEmailApp.views.composeView

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@composeView.template).toEqual JST["backbone/templates/compose/modal_compose"]

  describe "#render", ->
    beforeEach ->
      @postRenderSetupStub = sinon.stub(@composeView, "postRenderSetup")
      @composeView.render()

    afterEach ->
      @postRenderSetupStub.restore()

    it "calls postRenderSetup", ->
      expect(@postRenderSetupStub).toHaveBeenCalled()

  describe "after render", ->
    beforeEach ->
      @composeView.render()

    describe "Setup Functions", ->
      describe "#setupComposeView", ->
        it "sends an email when the .compose-form is submitted", ->
          sendEmailStub = sinon.stub(@composeView, "sendEmail", ->)
          @composeView.$el.find(".compose-form").submit()
          expect(sendEmailStub).toHaveBeenCalled()
          sendEmailStub.restore()

        describe "when the compose modal is hidden", ->
          beforeEach ->
            @composeView.show()

          it "saves the draft", ->
            @spy = sinon.spy(@composeView, "updateDraft")
            @composeView.$el.find(".save-button").click()

            expect(@spy).toHaveBeenCalled()
            @spy.restore()

      describe "#setupSendAndArchive", ->
        beforeEach ->
          @composeView.ractive.set
            "email._tos"    : "This is the to input."
            "email._ccs"    : ""
            "email._bccs"   : ""

        describe "when the send and archive button is clicked", ->

          it "should send the email", ->
            @clock = sinon.useFakeTimers()
            spy = sinon.spy(@composeView, "sendEmail")
            @composeView.$el.find(".send-and-archive").click()

            expect(spy).toHaveBeenCalled()
            spy.restore()

          it "triggers archiveClicked", ->
            spy = sinon.backbone.spy(@composeView, "archiveClicked")
            @composeView.$el.find(".send-and-archive").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()

      describe "#setupEmailAddressAutocompleteOnAddressFields", ->
        beforeEach ->
          @setupEmailAddressAutocompleteStub = sinon.stub(@composeView, "setupEmailAddressAutocomplete")
          @composeView.setupEmailAddressAutocompleteOnAddressFields()

        afterEach ->
          @setupEmailAddressAutocompleteStub.restore()

        it "sets up the email address auto complete on the to field", ->
          expect(@setupEmailAddressAutocompleteStub).toHaveBeenCalled(".compose-form .to-input")

        it "sets up the email address auto complete on the cc field", ->
          expect(@setupEmailAddressAutocompleteStub).toHaveBeenCalled(".compose-form .cc-input")

        it "sets up the email address auto complete on the bcc field", ->
          expect(@setupEmailAddressAutocompleteStub).toHaveBeenCalled(".compose-form .bcc-input")

      describe "#setupEmailAddressAutocomplete", ->
        beforeEach ->
          @autocompleteSpy = sinon.spy($.prototype, "autocomplete")
          @composeView.setupEmailAddressAutocomplete ".compose-form .to-input"

        afterEach ->
          @autocompleteSpy.restore()

        it "calls autocomplete on the selector field", ->
          expect(@autocompleteSpy).toHaveBeenCalled()

      describe "#setupEmailAddressDeobfuscation", ->

        it "hooks the keyup action on the to, cc and bcc fields", ->
          expect(@composeView.$el.find(".compose-form .to-input, .compose-form .cc-input, .compose-form .bcc-input")).toHandle("keyup")

        describe "when a nonobfuscated email is typed into one of the to, cc, or bcc fields", ->

          it "leaves the email address as is", ->
            seededChance = new Chance(1)
            randomEmailAddress = seededChance.email()
            @composeView.$el.find(".compose-form .to-input").val(randomEmailAddress)
            @composeView.$el.find(".compose-form .to-input").keyup()
            expect(@composeView.$el.find(".compose-form .to-input").val()).toEqual randomEmailAddress

        describe "when an obfuscated email is typed into one of the to, cc, or bcc fields", ->

          it "changes the email address", ->
            @composeView.$el.find(".compose-form .to-input").val("testemail [at] gmail [dot] com")
            @composeView.$el.find(".compose-form .to-input").keyup()
            expect(@composeView.$el.find(".compose-form .to-input").val()).toEqual "testemail@gmail.com"

      describe "#setupSizeToggle", ->

        describe "when the compose modal size toggle is clicked", ->

          it "should toggle the compress and expand classes", ->
            expect(@composeView.$el.find(".compose-modal-size-toggle")).toHaveClass("tm_modal-button-compress")
            expect(@composeView.$el.find(".compose-modal-size-toggle")).not.toHaveClass("tm_modal-button-expand")

            @composeView.$el.find(".compose-modal-size-toggle").click()

            expect(@composeView.$el.find(".compose-modal-size-toggle")).not.toHaveClass("tm_modal-button-compress")
            expect(@composeView.$el.find(".compose-modal-size-toggle")).toHaveClass("tm_modal-button-expand")

            @composeView.$el.find(".compose-modal-size-toggle").click()

            expect(@composeView.$el.find(".compose-modal-size-toggle")).toHaveClass("tm_modal-button-compress")
            expect(@composeView.$el.find(".compose-modal-size-toggle")).not.toHaveClass("fa-expand")

          it "should toggle the size of the modal", ->
            expect(@composeView.$el.find(".compose-modal-dialog")).toHaveClass("compose-modal-dialog-large")
            expect(@composeView.$el.find(".compose-modal-dialog")).not.toHaveClass("compose-modal-dialog-small")

            @composeView.$el.find(".compose-modal-size-toggle").click()

            expect(@composeView.$el.find(".compose-modal-dialog")).not.toHaveClass("compose-modal-dialog-large")
            expect(@composeView.$el.find(".compose-modal-dialog")).toHaveClass("compose-modal-dialog-small")

            @composeView.$el.find(".compose-modal-size-toggle").click()

            expect(@composeView.$el.find(".compose-modal-dialog")).toHaveClass("compose-modal-dialog-large")
            expect(@composeView.$el.find(".compose-modal-dialog")).not.toHaveClass("compose-modal-dialog-small")

    describe "Display Functions", ->
      describe "#show", ->
        it "shows the compose modal", ->
          @composeView.show()
          expect($("body")).toContain(".modal-backdrop.fade.in")

      describe "#hide", ->
        it "hides the compose modal", ->
          @composeView.hide()
          expect(@composeView.$el.find(".compose-modal").hasClass("in")).toBeFalsy()

      describe "#resetView", ->
        beforeEach ->
          @composeView.ractive.set
            "email._tos"    : "This is the to input."
            "email._ccs"    : "This is the cc input."
            "email._bccs"   : "This is the bcc input."
            "email.subject" : "This is the subject input."
          @composeView.$el.find(".tm_compose-body .redactor-editor").html("This is the compose email body.")
          @composeView.$el.find(".compose-form .send-later-datetimepicker").val("Date")

          @composeView.resetView()

        it "should clear the compose view input fields", ->
          expect(@composeView.$el.find(".compose-form .to-input").val()).toEqual ""
          expect(@composeView.$el.find(".compose-form .cc-input").val()).toEqual ""
          expect(@composeView.$el.find(".compose-form .bcc-input").val()).toEqual ""
          expect(@composeView.$el.find(".compose-form .subject-input").val()).toEqual ""
          expect(@composeView.$el.find(".tm_compose-body .redactor-editor").html()).toEqual ""
          expect(@composeView.$el.find(".compose-form .send-later-datetimepicker").val()).toEqual ""

        it "removes the email sent error alert", ->
          expect(@composeView.$el).not.toContainHtml('<div id="email_sent_error_alert" class="alert alert-danger" role="alert">There was an error in sending your email!</div>')

          spy = sinon.spy(@composeView, "removeEmailSentAlert")
          @composeView.loadEmpty()
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "clears the current email draft and the email in reply to uid variables", ->
          expect(@composeView.currentEmailDraft).toEqual null
          expect(@composeView.emailInReplyToUID).toEqual null

      describe "#showEmailSentAlert", ->
        beforeEach ->
          @emailJSON = {}
          seededChance = new Chance(1)
          @emailJSON["tos"] = seededChance.email()

        describe "when the current alert token is defined", ->
          beforeEach ->
            @composeView.currentAlertToken = true

          it "should remove the alert", ->
            spy = sinon.spy(@composeView, "removeEmailSentAlert")
            @composeView.showEmailSentAlert(@emailJSON)
            expect(spy).toHaveBeenCalled()
            spy.restore()

        it "should show the alert", ->
          spy = sinon.spy(TuringEmailApp, "showAlert")
          @composeView.showEmailSentAlert(@emailJSON)
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "should set the current alert token", ->
          @composeView.currentAlertToken = null
          @composeView.showEmailSentAlert(@emailJSON)
          expect(@composeView.currentAlertToken).toBeDefined()

        describe "when the undo email send button is clicked", ->
          beforeEach ->
            @composeView.currentAlertToken = null
            @composeView.showEmailSentAlert(@emailJSON)

          it "should remove the alert", ->
            spy = sinon.spy(@composeView, "removeEmailSentAlert")
            $(".undo-email-send").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()

          it "should load the email", ->
            spy = sinon.spy(@composeView, "loadEmail")
            $(".undo-email-send").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()

          it "show the compose modal", ->
            spy = sinon.spy(@composeView, "show")
            $(".undo-email-send").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()

      describe "#removeEmailSentAlert", ->
        describe "when the current alert token is defined", ->
          beforeEach ->
            @composeView.currentAlertToken = true

          it "should remove the alert", ->
            spy = sinon.spy(TuringEmailApp, "removeAlert")
            @composeView.removeEmailSentAlert()
            expect(spy).toHaveBeenCalled()
            spy.restore()

          it "should set the current alert token to be null", ->
            @composeView.removeEmailSentAlert()
            expect(@composeView.currentAlertToken is null).toBeTruthy()

    describe "Load Email Functions", ->
      describe "#loadEmpty", ->
        it "resets the view", ->
          spy = sinon.spy(@composeView, "resetView")
          @composeView.loadEmpty()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "#loadEmail", ->
        it "resets the view", ->
          spy = sinon.spy(@composeView, "resetView")
          @composeView.loadEmail JSON.stringify({})
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "loads the email headers", ->
          spy = sinon.spy(@composeView, "loadEmailHeaders")
          emailJSON = {}
          @composeView.loadEmail emailJSON
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(emailJSON)
          spy.restore()

        it "loads the email body", ->
          spy = sinon.spy(@composeView, "loadEmailBody")
          emailJSON = {}
          @composeView.loadEmail emailJSON
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(emailJSON)
          spy.restore()

      describe "#loadEmailDraft", ->
        it "resets the view", ->
          spy = sinon.spy(@composeView, "resetView")
          @composeView.loadEmailDraft JSON.stringify({})
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "loads the email headers", ->
          spy = sinon.spy(@composeView, "loadEmailHeaders")
          emailJSON = {}
          @composeView.loadEmailDraft emailJSON
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(emailJSON)
          spy.restore()

        it "loads the email body", ->
          spy = sinon.spy(@composeView, "loadEmailBody")
          emailJSON = {}
          @composeView.loadEmailDraft emailJSON
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(emailJSON)
          spy.restore()

        it "creates a new current draft object with the passed in data", ->
          emailJSON = {}
          newEmailDraft = new TuringEmailApp.Models.EmailDraft(emailJSON)
          @composeView.loadEmailDraft emailJSON
          expect(@composeView.currentEmailDraft.attributes).toEqual newEmailDraft.attributes

        it "updates the emailThreadParent", ->
          emailJSON = {}
          emailThreadParent = {}
          @composeView.loadEmailDraft(emailJSON, emailThreadParent)
          expect(@composeView.emailThreadParent).toEqual(emailThreadParent)

      describe "#loadEmailAsReply", ->
        beforeEach ->
          @seededChance = new Chance(1)

        it "resets the view", ->
          spy = sinon.spy(@composeView, "resetView")
          @composeView.loadEmailAsReply JSON.stringify({})
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "loads the email body", ->
          spy = sinon.spy(@composeView, "loadEmailBody")
          emailJSON = {}
          @composeView.loadEmailAsReply emailJSON
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(emailJSON)
          spy.restore()

        describe "when there is a reply to address", ->

          it "updates the to input with the reply to address", ->
            emailJSON = {}
            emailJSON["reply_to_address"] = @seededChance.email()
            @composeView.loadEmailAsReply emailJSON
            expect(@composeView.$el.find(".compose-form .to-input").val()).toEqual emailJSON.reply_to_address

        describe "when there is not a reply to address", ->

          it "updates the to input with the from address", ->
            emailJSON = {}
            emailJSON["from_address"] = @seededChance.email()
            @composeView.loadEmailAsReply emailJSON
            expect(@composeView.$el.find(".compose-form .to-input").val()).toEqual emailJSON.from_address

        it "updates the subject input", ->
          emailJSON = {}
          emailJSON["subject"] = @seededChance.string({length: 20})
          @composeView.loadEmailAsReply emailJSON
          subjectWithPrefixFromEmail = @composeView.subjectWithPrefixFromEmail(emailJSON, "Re: ")
          expect(@composeView.$el.find(".compose-form .subject-input").val()).toEqual subjectWithPrefixFromEmail

        it "updates the email in reply to UID", ->
          emailJSON = {}
          emailJSON.uid = chance.integer({min: 1, max: 10000})
          @composeView.loadEmailAsReply emailJSON
          expect(@composeView.emailInReplyToUID).toEqual emailJSON.uid

      describe "#loadEmailAsReplyToAll", ->
        beforeEach ->
          @seededChance = new Chance(1)

        it "resets the view", ->
          spy = sinon.spy(@composeView, "resetView")
          @composeView.loadEmailAsReplyToAll JSON.stringify({})
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "loads the email body", ->
          spy = sinon.spy(@composeView, "loadEmailBody")
          emailJSON = {}
          @composeView.loadEmailAsReplyToAll emailJSON
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(emailJSON)
          spy.restore()

        it "updates the to input with the tos", ->
          emailJSON = {}
          emailJSON["tos"] = @seededChance.email() + ", " + @seededChance.email() + ", " + @seededChance.email()
          @composeView.loadEmailAsReplyToAll emailJSON
          expect(@composeView.$el.find(".compose-form .to-input").val()).toEqual emailJSON.tos

        it "updates the cc input with the ccs", ->
          emailJSON = {}
          emailJSON["ccs"] = @seededChance.email() + ", " + @seededChance.email() + ", " + @seededChance.email()
          @composeView.loadEmailAsReplyToAll emailJSON
          expect(@composeView.$el.find(".compose-form .cc-input").val()).toEqual emailJSON.ccs

        it "updates the subject input", ->
          emailJSON = {}
          emailJSON["subject"] = @seededChance.string({length: 20})
          @composeView.loadEmailAsReplyToAll emailJSON
          subjectWithPrefixFromEmail = @composeView.subjectWithPrefixFromEmail(emailJSON, "Re: ")
          expect(@composeView.$el.find(".compose-form .subject-input").val()).toEqual subjectWithPrefixFromEmail

        it "updates the email in reply to UID", ->
          emailJSON = {}
          emailJSON.uid = chance.integer({min: 1, max: 10000})
          @composeView.loadEmailAsReplyToAll emailJSON
          expect(@composeView.emailInReplyToUID).toEqual emailJSON.uid

      describe "#loadEmailAsForward", ->
        beforeEach ->
          @seededChance = new Chance(1)

        it "resets the view", ->
          spy = sinon.spy(@composeView, "resetView")
          @composeView.loadEmailAsForward JSON.stringify({})
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "updates the subject input", ->
          emailJSON = {}
          emailJSON["subject"] = @seededChance.string({length: 20})
          @composeView.loadEmailAsForward emailJSON
          subjectWithPrefixFromEmail = @composeView.subjectWithPrefixFromEmail(emailJSON, "Fwd: ")
          expect(@composeView.$el.find(".compose-form .subject-input").val()).toEqual subjectWithPrefixFromEmail

        it "loads the email body", ->
          spy = sinon.spy(@composeView, "loadEmailBody")
          emailJSON = {}
          @composeView.loadEmailAsForward emailJSON
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(emailJSON)
          spy.restore()

      describe "#loadEmailHeaders", ->
        beforeEach ->
          @seededChance = new Chance(1)

        it "updates the to input", ->
          emailJSON = {}
          emailJSON["tos"] = @seededChance.email()
          @composeView.loadEmailHeaders emailJSON
          expect(@composeView.$el.find(".compose-form .to-input").val()).toEqual emailJSON.tos

        it "updates the cc input", ->
          emailJSON = {}
          emailJSON["ccs"] = @seededChance.email()
          @composeView.loadEmailHeaders emailJSON
          expect(@composeView.$el.find(".compose-form .cc-input").val()).toEqual emailJSON.ccs

        it "updates the bcc input", ->
          emailJSON = {}
          emailJSON["bccs"] = @seededChance.email()
          @composeView.loadEmailHeaders emailJSON
          expect(@composeView.$el.find(".compose-form .bcc-input").val()).toEqual emailJSON.bccs

        it "updates the subject input", ->
          emailJSON = {}
          emailJSON["subject"] = @seededChance.string({length: 20})
          @composeView.loadEmailHeaders emailJSON
          subjectWithPrefixFromEmail = @composeView.subjectWithPrefixFromEmail(emailJSON)
          expect(@composeView.$el.find(".compose-form .subject-input").val()).toEqual subjectWithPrefixFromEmail

      describe "#loadEmailBody", ->
        beforeEach ->
          @seededChance = new Chance(1)

          @formatEmailReplyBodySpy = sinon.spy(@composeView, "formatEmailReplyBody")
          @parseEmailSpy = sinon.spy(@composeView, "parseEmail")
          @bodyHtmlIsSpy = sinon.spy(@composeView, "bodyHtmlIs")

        afterEach ->
          @formatEmailReplyBodySpy.restore()
          @parseEmailSpy.restore()
          @bodyHtmlIsSpy.restore()

        describe "isReply=true", ->
          beforeEach ->
            @emailJSON = {}
            @emailJSON["text_part"] = @seededChance.string({length: 250})

            @body = @composeView.loadEmailBody(@emailJSON, true)

          it "loads the email body", ->
            expect(@formatEmailReplyBodySpy).toHaveBeenCalledWith(@emailJSON)
            expect(@bodyHtmlIsSpy).toHaveBeenCalledWith(@body)

        describe "isReply=false", ->
          describe "html=true", ->
            beforeEach ->
              @emailJSON = {}
              @emailJSON["html_part"] = "<div>" + @seededChance.string({length: 250}) + "</div>"

              @body = @composeView.loadEmailBody(@emailJSON, false)

            it "loads the email body", ->
              expect(@formatEmailReplyBodySpy).not.toHaveBeenCalled()
              expect(@parseEmailSpy).toHaveBeenCalled()
              expect(@bodyHtmlIsSpy).toHaveBeenCalledWith(@body)

          describe "html=false", ->
            beforeEach ->
              @emailJSON = {}
              @emailJSON["text_part"] = @seededChance.string({length: 250})

              @body = @composeView.loadEmailBody(@emailJSON, false)

            it "loads the email body", ->
              expect(@formatEmailReplyBodySpy).not.toHaveBeenCalled()
              expect(@parseEmailSpy).toHaveBeenCalled()
              expect(@bodyHtmlIsSpy).toHaveBeenCalledWith(@body)

      describe "#parseEmail", ->
        beforeEach ->
          @seededChance = new Chance(1)

          @emailJSON = {}
          @emailJSON["date"] = "2014-09-18T21:28:48.000Z"
          @emailJSON["from_address"] =  @seededChance.email()

        describe "text", ->
          beforeEach ->
            @emailJSON["html_part"] = "<div>a\nb\nc\nd\n</div>"

            [@replyBody, @html] = @composeView.parseEmail(@emailJSON)

          it "parsed html", ->
            expect(@html).toBeTruthy()

        describe "text", ->
          beforeEach ->
            @emailJSON["text_part"] = "a\nb\nc\nd\n"

            [@replyBody, @html] = @composeView.parseEmail(@emailJSON)

          it "parsed plain text", ->
            expect(@html).toBeFalsy()

          it "adds > to the beginning of each line of the body", ->
            expect(@replyBody).toContain("> a\n> b\n> c\n> d\n> ")

    describe "Format Email Functions", ->
      describe "#formatEmailReplyBody", ->
        beforeEach ->
          @seededChance = new Chance(1)

          @emailJSON = {}
          @emailJSON["date"] = "2014-09-18T21:28:48.000Z"
          @emailJSON["from_address"] =  @seededChance.email()

          tDate = new TDate()
          tDate.initializeWithISO8601(@emailJSON.date)

          @headerText = tDate.longFormDateString() + ", " + @emailJSON.from_address + " wrote:"

        describe "text", ->
          beforeEach ->
            @emailJSON["text_part"] = @seededChance.string({length: 250})

            @replyBody = @composeView.formatEmailReplyBody(@emailJSON)

          it "renders the reply header", ->
            expect(@replyBody.text()).toContain(@headerText)

        describe "html", ->
          beforeEach ->
            @emailJSON["html_part"] = "<div>" + @seededChance.string({length: 250}) + "</div>"
            @headerText = @headerText.replace(/\r\n/g, "<br>")

            @replyBody = @composeView.formatEmailReplyBody(@emailJSON)

          it "renders the reply header", ->
            expect(@replyBody.html()).toContain(@headerText)

      describe "#subjectWithPrefixFromEmail", ->
        beforeEach ->
          @seededChance = new Chance(1)

        it "returns the subject prefix if the email subject is not defined", ->
          emailJSON = {}
          subjectPrefix = "prefix"
          expect(@composeView.subjectWithPrefixFromEmail emailJSON, subjectPrefix).toEqual subjectPrefix

        it "strips Fwd: from the subject before prepending the subject prefix", ->
          emailJSON = {}
          subjectWithoutPrefix = @seededChance.string({length: 15})
          emailJSON["subject"] = "Fwd: " + subjectWithoutPrefix
          expect(@composeView.subjectWithPrefixFromEmail emailJSON).toEqual subjectWithoutPrefix

        it "strips Re: from the subject before prepending the subject prefix", ->
          emailJSON = {}
          subjectWithoutPrefix = @seededChance.string({length: 15})
          emailJSON["subject"] = "Re: " + subjectWithoutPrefix
          expect(@composeView.subjectWithPrefixFromEmail emailJSON).toEqual subjectWithoutPrefix

        it "prepends the subject prefix", ->
          emailJSON = {}
          subjectPrefix = "prefix"
          emailJSON["subject"] = @seededChance.string({length: 15})
          expect(@composeView.subjectWithPrefixFromEmail emailJSON, subjectPrefix).toEqual subjectPrefix + emailJSON["subject"]

    describe "Email State", ->
      describe "#updateDraft", ->
        beforeEach ->
          date = new Date()
          date.setDate(date.getDate() + 1)
          @composeView.$el.find(".compose-modal .bounce-back-datetimepicker").val(date.toString())

        it "updates the email with the current email draft", ->
          @composeView.currentEmailDraft = new TuringEmailApp.Models.EmailDraft()
          spy = sinon.spy(@composeView, "updateEmail")
          @composeView.updateDraft()
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(@composeView.currentEmailDraft)
          spy.restore()

        it "creates a new email draft when the current email draft is not defined", ->
          @composeView.currentEmailDraft = null
          @composeView.updateDraft()
          anEmailDraft = new TuringEmailApp.Models.EmailDraft()
          @composeView.updateEmail(anEmailDraft)
          expect(@composeView.currentEmailDraft.attributes).toEqual anEmailDraft.attributes

      describe "#updateEmail", ->
        beforeEach ->
          @seededChance = new Chance(1)
          @email = new TuringEmailApp.Models.EmailDraft()

          @composeView.$el.find(".compose-form .to-input").val(@seededChance.email())
          @composeView.$el.find(".compose-form .cc-input").val(@seededChance.email())
          @composeView.$el.find(".compose-form .bcc-input").val(@seededChance.email())
          @composeView.$el.find(".compose-form .subject-input").val(@seededChance.string({length: 25}))
          @composeView.$el.find(".compose-form .compose-email-body").html(@seededChance.string({length: 250}))

          @composeView.emailInReplyToUID = chance.integer({min: 1, max: 10000})

          @composeView.updateEmail @email

        it "updates the email model with the email in reply to UID from the compose view", ->
          expect(@email.get("email_in_reply_to_uid")).toEqual @composeView.emailInReplyToUID

        it "updates the email model with the value from the tracking_enabled switch", ->
          expect(@email.get("tracking_enabled")).toEqual(
            @composeView.$el.find(".compose-form .tracking-switch").parent().parent().hasClass("switch-on")
          )

        it "updates the email model with the to input value from the compose form", ->
          expect(@email.get("tos")[0]).toEqual @composeView.$el.find(".compose-form .to-input").val()

        it "updates the email model with the cc input value from the compose form", ->
          expect(@email.get("ccs")[0]).toEqual @composeView.$el.find(".compose-form .cc-input").val()

        it "updates the email model with the bcc input value from the compose form", ->
          expect(@email.get("bccs")[0]).toEqual @composeView.$el.find(".compose-form .bcc-input").val()

        it "updates the email model with the subject input value from the compose form", ->
          expect(@email.get("subject")).toEqual @composeView.$el.find(".compose-form .subject-input").val()

        it "updates the email model with the html input value from the compose form", ->
          expect(@email.get("html_part")).toEqual @composeView.$el.find(".tm_compose-body .redactor-editor").html()

        it "updates the email model with the text input value from the compose form", ->
          expect(@email.get("text_part")).toEqual @composeView.$el.find(".tm_compose-body .redactor-editor").text()

      describe "#emailHasRecipients", ->
        beforeEach ->
          @email = new TuringEmailApp.Models.Email()
          @email.set("tos", [""])
          @email.set("ccs", [""])
          @email.set("bccs", [""])

        describe "no recipients", ->
          it "returns false", ->
            expect(@composeView.emailHasRecipients(@email)).toBeFalsy()

        describe "with a to", ->
          beforeEach ->
            @email.set("tos", ["allan@turing.com"])

          it "returns true", ->
            expect(@composeView.emailHasRecipients(@email)).toBeTruthy()

        describe "with a cc", ->
          beforeEach ->
            @email.set("ccs", ["allan@turing.com"])

          it "returns true", ->
            expect(@composeView.emailHasRecipients(@email)).toBeTruthy()

        describe "with a bcc", ->
          beforeEach ->
            @email.set("bccs", ["allan@turing.com"])

          it "returns true", ->
            expect(@composeView.emailHasRecipients(@email)).toBeTruthy()

    describe "Email Draft", ->
      describe "#saveDraft", ->
        beforeEach ->
          @server = sinon.fakeServer.create()

        it "updates the draft", ->
          spy = sinon.spy(@composeView, "updateDraft")
          @composeView.saveDraft(true)
          expect(spy).toHaveBeenCalled()
          spy.restore()

        describe "when the composeView is already saving the draft", ->

          it "if does not update the draft", ->
            @composeView.savingDraft = true
            spy = sinon.spy(@composeView, "updateDraft")
            @composeView.saveDraft(true)
            expect(spy).not.toHaveBeenCalled()
            spy.restore()

        describe "when the server responds successfully", ->
          beforeEach ->
            @server.respondWith "POST", "/api/v1/email_accounts/drafts", JSON.stringify({})

          it "triggers change:draft", ->
            spy = sinon.backbone.spy(@composeView, "change:draft")
            @composeView.saveDraft(true)
            @server.respond()
            expect(spy).toHaveBeenCalled()
            spy.restore()

          it "stops saving the draft", ->
            @composeView.saveDraft(true)
            @server.respond()
            expect(@composeView.savingDraft).toEqual(false)

        describe "when the server responds unsuccessfully", ->
          it "stops saving the draft", ->
            @composeView.saveDraft(true)
            @server.respond([404, {}, ""])
            expect(@composeView.savingDraft).toEqual(false)

    describe "Send Email", ->
      describe "#sendEmailWithCallback", ->
        beforeEach ->
          @updateEmailSpy = sinon.spy(@composeView, "updateEmail")
          @updateDraftSpy = sinon.spy(@composeView, "updateDraft")
          @resetViewStub = sinon.stub(@composeView, "resetView")
          @hideStub = sinon.stub(@composeView, "hide")
          @sendUndoableEmailStub = sinon.stub(@composeView, "sendUndoableEmail")

          @callback = sinon.stub()
          @callbackWithDraft = sinon.stub()

          @composeView.$el.find(".compose-form .to-input").val("allan@turing.com")

        afterEach ->
          @updateEmailSpy.restore()
          @updateDraftSpy.restore()
          @resetViewStub.restore()
          @hideStub.restore()
          @sendUndoableEmailStub.restore()

        describe "when the current email draft is defined", ->
          beforeEach ->
            @composeView.currentEmailDraft = new TuringEmailApp.Models.EmailDraft()

          describe "when saving the draft", ->
            beforeEach ->
              @composeView.savingDraft = true
              @clock = sinon.useFakeTimers()

              @composeView.sendEmailWithCallback(@callback, @callbackWithDraft)
              @sendEmailWithCallbackStub = sinon.spy(@composeView, "sendEmailWithCallback")

            afterEach ->
              @clock.restore()
              @sendEmailWithCallbackStub.restore()

            it "updates the draft", ->
              expect(@updateDraftSpy).toHaveBeenCalled()

            it "resets the view", ->
              expect(@resetViewStub).toHaveBeenCalled()

            it "hides the compose modal", ->
              expect(@hideStub).toHaveBeenCalled()

            it "sends the email after a timeout", ->
              @clock.tick(500)
              expect(@sendEmailWithCallbackStub).toHaveBeenCalled()

          describe "when not saving the draft", ->
            beforeEach ->
              @composeView.savingDraft = false
              @server = sinon.fakeServer.create()

              @composeView.sendEmailWithCallback(@callback, @callbackWithDraft)

            it "calls the callback", ->
              expect(@callbackWithDraft).toHaveBeenCalled()

        describe "when the current email draft is not defined", ->
          beforeEach ->
            @composeView.currentEmailDraft = null
            @composeView.sendEmailWithCallback(@callback, @callbackWithDraft)

          it "updates the email", ->
            expect(@updateEmailSpy).toHaveBeenCalled()

          it "resets the view", ->
            expect(@resetViewStub).toHaveBeenCalled()

          it "hides the compose modal", ->
            expect(@hideStub).toHaveBeenCalled()

          it "calls the callback", ->
            expect(@callback).toHaveBeenCalled()

      describe "#sendEmail", ->
        beforeEach ->
          @sendEmailWithCallbackStub = sinon.stub(@composeView, "sendEmailWithCallback")

          @composeView.sendEmail()

        afterEach ->
          @sendEmailWithCallbackStub.restore()

        it "calls sendEmailWithCallback", ->
          expect(@sendEmailWithCallbackStub).toHaveBeenCalled()

      describe "#sendEmailDelayed", ->
        beforeEach ->
          @sendEmailWithCallbackStub = sinon.stub(@composeView, "sendEmailWithCallback")

          date = new Date()
          date.setDate(date.getDate() + 1)
          @composeView.$el.find(".compose-modal .send-later-datetimepicker").val(date.toString())

          @composeView.sendEmailDelayed()

        afterEach ->
          @sendEmailWithCallbackStub.restore()

        it "calls sendEmailWithCallback", ->
          expect(@sendEmailWithCallbackStub).toHaveBeenCalled()

      describe "#sendUndoableEmail", ->
        beforeEach ->
          @email = new TuringEmailApp.Models.EmailDraft()

        it "shows the email sent alert", ->
          spy = sinon.spy(@composeView, "showEmailSentAlert")
          @composeView.sendUndoableEmail @email
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(@email.toJSON())
          spy.restore()

        it "removes the email sent alert", ->
          @clock = sinon.useFakeTimers()
          @spy = sinon.spy(@composeView, "removeEmailSentAlert")
          @composeView.sendUndoableEmail @email

          @clock.tick(5000)

          expect(@spy).toHaveBeenCalled()
          @clock.restore()
          @spy.restore()

        describe "when send draft is defined", ->
          beforeEach ->
            @clock = sinon.useFakeTimers()

            @sendDraftStub = sinon.stub(@email, "sendDraft", ->)
            @changeDraftSpy = sinon.backbone.spy(@composeView, "change:draft")

          afterEach ->
            @changeDraftSpy.restore()
            @sendDraftStub.restore()

            @clock.restore()

          it "should send the draft", ->
            @composeView.sendUndoableEmail @email
            @clock.tick(5000)

            expect(@sendDraftStub).toHaveBeenCalled()

          it "triggers change:draft upon being done", ->
            @composeView.sendUndoableEmail @email
            @clock.tick(5000)

            expect(@sendDraftStub).toHaveBeenCalled()

            @sendDraftStub.args[0][1]()
            expect(@changeDraftSpy).toHaveBeenCalled()

        describe "when send draft is not defined", ->
          beforeEach ->
            @server = sinon.fakeServer.create()
            @email = new TuringEmailApp.Models.Email()
            @clock = sinon.useFakeTimers()

          afterEach ->
            @clock.restore()

          it "should send the email", ->
            @spy = sinon.spy(@email, "sendEmail")
            @composeView.sendUndoableEmail @email

            @clock.tick(5000)

            expect(@spy).toHaveBeenCalled()
            @spy.restore()

          it "should should send the email after a delay if the initial sending doesn't work", ->
            @spySendEmail = sinon.spy(@email, "sendEmail")
            @spysendUndoableEmailError = sinon.spy(@composeView, "sendUndoableEmailError")
            @composeView.sendUndoableEmail @email

            @clock.tick(5000)

            expect(@spySendEmail).toHaveBeenCalled()
            @server.respond()
            expect(@spysendUndoableEmailError).toHaveBeenCalled()
            @spySendEmail.restore()
            @spysendUndoableEmailError.restore()

      describe "#sendUndoableEmailError", ->

        it "loads the email", ->
          spy = sinon.spy(@composeView, "show")
          emailJSON = {}
          @composeView.sendUndoableEmailError emailJSON
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "show the compose modal", ->
          spy = sinon.spy(@composeView, "show")
          @composeView.sendUndoableEmailError JSON.stringify({})
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "should show the alert", ->
          spy = sinon.spy(TuringEmailApp, "showAlert")
          @composeView.sendUndoableEmailError JSON.stringify({})
          expect(spy).toHaveBeenCalled()
          spy.restore()
