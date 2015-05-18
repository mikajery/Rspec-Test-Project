describe "EmailThreadView", ->
  beforeEach ->
    specStartTuringEmailApp()

    emailThreadAttributes = FactoryGirl.create("EmailThread")
    emailThreadAttributes.emails.push(FactoryGirl.create("Email", draft_id: "draft"))
    @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes,
      app: TuringEmailApp
      emailThreadUID: emailThreadAttributes.uid
      demoMode: false
    )
    @emailThread.get("emails")[1].html_part = "html part" #setup of test data.

    @loadEmailThreadStub = sinon.stub(@emailThread, "load", ->)

    @emailThreadView = new TuringEmailApp.Views.PrimaryPane.EmailThreads.EmailThreadView(
      app: TuringEmailApp
      model: @emailThread
      uploadAttachmentPostJSON: fixture.load("upload_attachment_post.fixture.json", true)
      emailTemplatesJSON: FactoryGirl.createLists("EmailTemplate", FactoryGirl.SMALL_LIST_SIZE)
    )
    $("body").append(@emailThreadView.$el)

  afterEach ->
    @emailThreadView.$el.remove()

    @loadEmailThreadStub.restore()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@emailThreadView.template).toEqual JST["backbone/templates/primary_pane/email_threads/email_thread"]

  describe "after fetch", ->
    beforeEach ->
      email.html_part_encoded = null for email in @emailThread.get("emails")
      @emailThreadView.render()
      @loadEmailThreadStub.args[0][0].success()

    describe "#render", ->
      it "should have the root element be a div", ->
        expect(@emailThreadView.el.nodeName).toEqual "DIV"

      describe "when the email is not a draft", ->

        it "should render the attributes of all the email threads", ->
          # Set up lists
          fromNames = []
          textParts = []
          htmlParts = []

          @emailThreadView.$el.find(".tm_email").each ->

            #Collect Attributes from the rendered DOM.
            emailInformation = $(@).find(".tm_email-info")
            fromNames.push $(emailInformation.find(".email-from")).text().trim()

            htmlBody = $($(@).find(".tm_email-body .tm_email-body-html")).text().trim()
            if htmlBody.length != 0
              if htmlBody.length is 0 then htmlParts.push(undefined) else htmlParts.push(htmlBody)
              textParts.push(undefined)
            else
              emailBody = $($(@).find(".tm_email-body")).text().trim()
              if emailBody.length is 0 then textParts.push(undefined) else textParts.push(emailBody)
              htmlParts.push(undefined)

          # Run expectations
          emails = @emailThread.get("emails")
          for email, index in emails
            if email.draft_id is null
              # expect(fromNames[index]).toContain email.from_name
              isCollapsed = (emails.length > 1 && index < emails.length - 1) && email.seen;
              if isCollapsed
                expect(textParts[index]).toBeUndefined()
                # expect(htmlParts[index]).toBeUndefined()
              else
                expect(textParts[index]).toEqual email.text_part
                # expect(htmlParts[index]).toEqual email.html_part

        it "should render the emails in the correct order", ->
          emails = @emailThread.get("emails")
          for email, index in emails
            continue if index is 0
            date1 = new Date(emails[index - 1].date)
            date2 = new Date(email.date)
            expect(date1 <= date2).toBeTruthy()

        describe "when there are no html or text parts of the email yet there is a body part", ->
          it "should render the body part", ->
            for email, index in @emailThread.get("emails")
              if email.draft_id is null
                @seededChance = new Chance(1)
                randomBodyText = @seededChance.string({length: 150})

                @emailThread.get("emails")[index].html_part_encoded = base64_encode_urlsafe(null)
                @emailThread.get("emails")[index].html_part = null

                @emailThread.get("emails")[index].body_text_encoded = base64_encode_urlsafe(randomBodyText)
                @emailThread.get("emails")[index].body_text = randomBodyText

                @emailThreadView.render()
                @loadEmailThreadStub.args[0][0].success()

                expect(@emailThreadView.$el.find(".tm_email-body-pre")).toContainHtml(randomBodyText)

      describe "when the email is a draft", ->

        it "should render the email drafts", ->
          @spy = sinon.spy(@emailThreadView, "renderDrafts")

          @emailThreadView.render()
          @loadEmailThreadStub.args[0][0].success()

          expect(@spy).toHaveBeenCalled()
          @spy.restore()

    describe "#addPreviewDataToTheModelJSON", ->
      beforeEach ->
        @modelJSON = @emailThread.toJSON()
        @emailThreadView.addPreviewDataToTheModelJSON @modelJSON

      it "adds the fromPreview data to the model JSON", ->
        expect(@modelJSON["fromPreview"] + " (" + @emailThread.get("emails").length + ")").toEqual(@emailThread.get("emails")[0].from_name +
                                                  " (" + @emailThread.get("emails").length + ")")

      it "adds the subjectPreview data to the model JSON", ->
        expect(@modelJSON["subjectPreview"]).toEqual @emailThread.get("emails")[0].subject

      it "adds the datePreview data to the model JSON", ->
        expect(@modelJSON["datePreview"]).toEqual TuringEmailApp.Models.Email.localDateString(@emailThread.get("emails")[0].date)

      it "adds the fromPreview data to each of the emails", ->
        for email in @modelJSON.emails
          expect(email["fromPreview"]).toEqual email.from_name

      it "adds the datePreview data to each of the emails", ->
        for email in @modelJSON.emails
          expect(email["datePreview"]).toEqual TuringEmailApp.Models.Email.localDateString(email.date)

    describe "#renderDrafts", ->

      it "should created embedded compose views", ->
        @emailThreadView.embeddedComposeViews = {}
        @emailThreadView.renderDrafts()
        embeddedComposeViewsLength = _.values(@emailThreadView.embeddedComposeViews).length
        expect(embeddedComposeViewsLength).toEqual 1

      it "should render the embedded compose view into the email thread view", ->
        @emailThreadView.renderDrafts()
        embeddedComposeView = _.values(@emailThreadView.embeddedComposeViews)[0]
        expect(@emailThreadView.$el).toContainHtml embeddedComposeView.$el

    describe "#setupEmailExpandAndCollapse", ->
      it "should have .email-collapse-expand handle clicks", ->
        expect(@emailThreadView.$el.find('.email-collapse-expand')).toHandle("click")

      describe "when a .email-collapse-expand is clicked", ->
        beforeEach ->
          @triggerStub = sinon.stub(@emailThreadView, "trigger")
          @emailDiv = @emailThreadView.$el.find('.tm_email').first()
          @emailInfoDiv = @emailDiv.find(".email-collapse-expand")

          @isCollapsed = @emailDiv.hasClass("tm_email-collapsed")
          @emailInfoDiv.click()

        afterEach ->
          @triggerStub.restore()
          @emailInfoDiv.click() # undo the expand/collapse

        it "shows the email body", ->
          expect(@emailDiv.hasClass("tm_email-collapsed") == !@isCollapsed).toBeTruthy()

        it "triggers expand:email", ->
          expect(@triggerStub).toHaveBeenCalledWith("expand:email", @emailThreadView,
                                                    @emailThreadView.model.get("emails")[0])

      describe "when a .email-collapse-expand is clicked twice", ->
        beforeEach ->
          @emailDiv = @emailThreadView.$el.find('.tm_email').first()
          @emailInfoDiv = @emailDiv.find(".email-collapse-expand")

          @isCollapsed = @emailDiv.hasClass("collapsed-email")
          @emailInfoDiv.click()
          @emailInfoDiv.click()

        it "should hide the email body", ->
          expect(@emailDiv.hasClass("collapsed-email") == @isCollapsed).toBeTruthy()

    describe "#setupAttachmentLinks", ->
      it "handles tm_email-attachment click", ->
        expect(@emailThreadView.$el.find('.tm_email-attachment')).toHandle("click")

      describe "when a .tm_email-attachmentis clicked", ->
        beforeEach ->
          @currentTarget = @emailThreadView.$el.find('.tm_email-attachment')
          @s3Key = @currentTarget.attr("href")
          @downloadStub = sinon.stub(TuringEmailApp.Models.EmailAttachment, "Download")
          @currentTarget.click()

        afterEach ->
          @downloadStub.restore()

        it "downloads", ->
          expect(@downloadStub).toHaveBeenCalledWith(@emailThreadView.app, @s3Key)

    describe "#setupButtons", ->
      describe "when email_reply_button is clicked", ->
        it "triggers replyClicked", ->
          spy = sinon.backbone.spy(@emailThreadView, "replyClicked")
          @emailThreadView.$el.find(".email_reply_button").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when reply-to-all is clicked", ->
        it "triggers replyToAllClicked", ->
          spy = sinon.backbone.spy(@emailThreadView, "replyToAllClicked")
          @emailThreadView.$el.find(".reply-to-all").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when email_forward_button is clicked", ->
        it "triggers forwardClicked", ->
          spy = sinon.backbone.spy(@emailThreadView, "forwardClicked")
          @emailThreadView.$el.find(".email_forward_button").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when isSplitPaneMode() is off", ->

        describe "when email-back-button is clicked", ->
          it "triggers goBackClicked", ->
            spy = sinon.backbone.spy(@emailThreadView, "goBackClicked")
            @emailThreadView.$el.find(".email-back-button").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()

    describe "#setupQuickReplyButton", ->
      beforeEach ->
        @emailThreadView.setupQuickReplyButton()

      it "renders a quick reply view on next to each response button group", ->
        @emailThreadView.$el.find(".email-response-btn-group").each ->
          expect($(@).parent()).toContain($(".quick-reply-dropdown-div"))
