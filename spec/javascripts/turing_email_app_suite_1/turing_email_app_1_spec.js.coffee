describe "TuringEmailApp suite 1", ->
  beforeEach ->
    window.gapi = client: load: => return then: =>

    @server = sinon.fakeServer.create()
    @mainDiv = $("<div />", id: "main").appendTo($("body"))

    @syncEmailStub = sinon.stub(TuringEmailApp, "syncEmail")

    @uploadAttachmentPostJSON = fixture.load("upload_attachment_post.fixture.json", true)
    @emailTemplatesJSON = FactoryGirl.createLists("EmailTemplate", FactoryGirl.SMALL_LIST_SIZE)
    @emailFoldersJSON = FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE)

  afterEach ->
    $("#main").remove()
    $(".xdsoft_datetimepicker").remove()
    $(".redactor-toolbar-tooltip").remove()
    $(".ui-widget").remove()
    @server.restore()
    @mainDiv.remove()
    @syncEmailStub.restore()

  it "has the app objects defined", ->
    expect(TuringEmailApp.Models).toBeDefined()
    expect(TuringEmailApp.Views).toBeDefined()
    expect(TuringEmailApp.Collections).toBeDefined()
    expect(TuringEmailApp.Routers).toBeDefined()

  describe "#backboneWrapError", ->
    beforeEach ->
      @addMatchers toBeFunctionEqual: (expected) ->
        actual_str = @actual.toString().split("\n")
        expect_str = expected.toString().split("\n")
        i = 0
        while i < actual_str.length
          false  unless actual_str[i].trim() is expect_str[i].trim()
          i++
        true

      @options =
        error: "my error"
      @model = "model"

    it "saved the error of the options to the function", ->
      expected = (resp) ->
        error model, resp, options  if error
        model.trigger "error", model, resp, options
        return

      window.backboneWrapError(@model, @options)

      expect(@options.error).toBeFunctionEqual(expected)

    it "returns undefined", ->
      expect( window.backboneWrapError(@model, @options) ).toBeUndefined

  describe "#onerror", ->
    beforeEach ->
      @message = "error message"
      @url = "error url"
      @lineNumber = "error line number"
      @column = "error column"
      @errorObj = "error object"

      @logSpy = sinon.spy(TuringEmailApp.tattletale, "log")
      @sendSpy = sinon.spy(TuringEmailApp.tattletale, "send")

    afterEach ->
      @logSpy.restore()
      @sendSpy.restore()

    it "logs the message", ->
      window.onerror(@message, @url, @lineNumber, @column, @errorObj)
      expect(@logSpy).toHaveBeenCalledWith(JSON.stringify(@message))

    it "logs the url", ->
      window.onerror(@message, @url, @lineNumber, @column, @errorObj)
      expect(@logSpy).toHaveBeenCalledWith(JSON.stringify(@url.toString()))

    it "logs the line number", ->
      window.onerror(@message, @url, @lineNumber, @column, @errorObj)
      expect(@logSpy).toHaveBeenCalledWith(JSON.stringify("Line number: " + @lineNumber.toString()))

    it "logs the error object", ->
      window.onerror(@message, @url, @lineNumber, @column, @errorObj)
      expect(@logSpy).toHaveBeenCalledWith(JSON.stringify(@errorObj.stack))

    it "sends the tattletale", ->
      window.onerror(@message, @url, @lineNumber, @column, @errorObj)
      expect(@sendSpy).toHaveBeenCalled

  describe "#threadsListInboxCountRequest", ->
    beforeEach ->
      window.gapi = client: gmail: users: messages: list: ->

      @ret = {}
      @messagesListStub = sinon.stub(gapi.client.gmail.users.messages, "list", => return @ret)

      @params =
        userId: "me"
        labelIds: "INBOX"
        fields: "resultSizeEstimate"

    afterEach ->
      @messagesListStub.restore()

    it "prepares and returns the Gmail API request", ->
      @returned = TuringEmailApp.threadsListInboxCountRequest()

      expect(@messagesListStub).toHaveBeenCalledWith(@params)
      expect(@returned).toEqual(@ret)

  describe "#start", ->
    it "defines the model, view, collection, and router containers", ->
      TuringEmailApp.start(FactoryGirl.create("User"), FactoryGirl.create("UserConfiguration"), @emailTemplatesJSON, @uploadAttachmentPostJSON, @emailFoldersJSON)

      expect(TuringEmailApp.models).toBeDefined()
      expect(TuringEmailApp.views).toBeDefined()
      expect(TuringEmailApp.collections).toBeDefined()
      expect(TuringEmailApp.routers).toBeDefined()

    setupFunctions = ["setupKeyboardHandler", "setupMainView",
                      "setupToolbar", "setupUser", "setupGmailAPI", "setupEmailFolders", "loadEmailFolders", "setupComposeView",
                      "setupCreateFolderView", "setupEmailThreads", "setupRouters"]

    for setupFunction in setupFunctions
      it "calls the " + setupFunction + " function", ->
        spy = sinon.spy(TuringEmailApp, setupFunction)
        TuringEmailApp.start(FactoryGirl.create("User"), FactoryGirl.create("UserConfiguration"), @emailTemplatesJSON, @uploadAttachmentPostJSON, @emailFoldersJSON)
        expect(spy).toHaveBeenCalled()
        spy.restore()

    it "starts the backbone history", ->
      TuringEmailApp.start(FactoryGirl.create("User"), FactoryGirl.create("UserConfiguration"), @emailTemplatesJSON, @uploadAttachmentPostJSON, @emailFoldersJSON)
      expect(Backbone.History.started).toBeTruthy()

  describe "setup functions", ->
    describe "#setupListeners", ->
      beforeEach ->
        @listenToSpy = sinon.spy(TuringEmailApp, "listenTo")
        TuringEmailApp.setupListeners("the source")

      afterEach ->
        @listenToSpy.restore()

      it "listens to the source", ->
        expect(@listenToSpy).toHaveBeenCalled

    describe "#setupSyncTimeout", ->
      beforeEach ->
        @timeOutValue = 300
        @setTimeoutStub = sinon.stub(window, "setTimeout").returns(@timeOutValue)

      afterEach ->
        @setTimeoutStub.restore()

      it "sets up the syncTimeout", ->
        TuringEmailApp.setupSyncTimeout()

        expect( TuringEmailApp.syncTimeout ).toEqual( @timeOutValue )

      describe "when the syncTimeout already setup", ->
        beforeEach ->
          TuringEmailApp.syncTimeout = 500

        it "sets up the syncTimeout newly", ->
          TuringEmailApp.setupSyncTimeout()

          expect( TuringEmailApp.syncTimeout ).toEqual( @timeOutValue )

    describe "#setupGmailAPI", ->
      beforeEach ->
        TuringEmailApp.gmailAPIReady = undefined
      it 'sets up the gmailAPIReady', ->
        TuringEmailApp.setupGmailAPI()

        expect( TuringEmailApp.gmailAPIReady ).toBe(false)

    describe "#refreshGmailAPIToken", ->
      beforeEach ->
        @getTokenStub = sinon.stub($, "get", -> done: sinon.stub())

        TuringEmailApp.refreshGmailAPIToken()

      afterEach ->
        @getTokenStub.restore()

      it "gets the token", ->
        expect(@getTokenStub).toHaveBeenCalledWith("/api/v1/gmail_accounts/get_token")

    describe "#setupKeyboardHandler", ->
      beforeEach ->
        TuringEmailApp.setupKeyboardHandler()

      it "creates the keyboard handler", ->
        expect(TuringEmailApp.keyboardHandler).toBeDefined()

    describe "#setupMainView", ->
      beforeEach ->
        TuringEmailApp.setupMainView(@emailTemplatesJSON, @uploadAttachmentPostJSON)

      it "creates the main view", ->
        expect(TuringEmailApp.views.mainView).toBeDefined()

    describe "#setupToolbar", ->
      it "creates the toolbar view", ->
        TuringEmailApp.setupToolbar()

        expect(TuringEmailApp.views.toolbarView).toBeDefined()
        expect(TuringEmailApp.views.toolbarView.app).toEqual(TuringEmailApp)

      it "renders the toolbar view", ->
        # TODO figure out how to test render
        return

      toolbarViewEvents = ["checkAllClicked", "checkAllReadClicked", "checkAllUnreadClicked", "uncheckAllClicked",
                           "readClicked", "unreadClicked", "archiveClicked", "trashClicked", "snoozeClicked",
                           "labelAsClicked", "moveToFolderClicked", "refreshClicked", "pauseClicked", "searchClicked",
                           "createNewLabelClicked", "createNewEmailFolderClicked", "demoModeSwitchClicked"]
      for event in toolbarViewEvents
        it "hooks the toolbar " + event + " event", ->
          spy = sinon.spy(TuringEmailApp, event)

          TuringEmailApp.setupToolbar()
          TuringEmailApp.views.toolbarView.trigger(event)

          expect(spy).toHaveBeenCalled()
          spy.restore()

      it "triggers a change:toolbarView event", ->
        spy = sinon.backbone.spy(TuringEmailApp, "change:toolbarView")
        TuringEmailApp.setupToolbar()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "#setupUser", ->
      beforeEach ->
        @listenToSpy = sinon.spy(TuringEmailApp, "listenTo")
        TuringEmailApp.setupUser(FactoryGirl.create("User"), FactoryGirl.create("UserConfiguration"))

      afterEach ->
        @listenToSpy.restore()

      it "create the user", ->
        expect(TuringEmailApp.models.user instanceof TuringEmailApp.Models.User).toBeTruthy()

      it "create the user settings", ->
        expect(TuringEmailApp.models.userConfiguration instanceof TuringEmailApp.Models.UserConfiguration).toBeTruthy()

      it "listens for change:demo_mode_enabled", ->
        expect(@listenToSpy.args[0][0] instanceof TuringEmailApp.Models.UserConfiguration).toBeTruthy()
        expect(@listenToSpy.args[0][1]).toEqual("change:demo_mode_enabled")

      it "listens for change:keyboard_shortcuts_enabled", ->
        expect(@listenToSpy.args[1][0] instanceof TuringEmailApp.Models.UserConfiguration).toBeTruthy()
        expect(@listenToSpy.args[1][1]).toEqual("change:keyboard_shortcuts_enabled")

      describe "the userConfiguration keyboard_shortcuts_enabled attribute changes", ->
        beforeEach ->
          @keyboardHandlerStartStub = sinon.stub(TuringEmailApp.keyboardHandler, "start")
          @keyboardHandlerStopStub = sinon.stub(TuringEmailApp.keyboardHandler, "stop")

        afterEach ->
          @keyboardHandlerStartStub.restore()
          @keyboardHandlerStopStub.restore()

        describe "to true", ->
          beforeEach ->
            TuringEmailApp.models.userConfiguration.set("keyboard_shortcuts_enabled", false, silent: true)
            TuringEmailApp.models.userConfiguration.set("keyboard_shortcuts_enabled", true)

          it "starts the keyboard shortcuts handler", ->
            expect(@keyboardHandlerStartStub).toHaveBeenCalled()
            expect(@keyboardHandlerStopStub).not.toHaveBeenCalled()

        describe "to false", ->
          beforeEach ->
            TuringEmailApp.models.userConfiguration.set("keyboard_shortcuts_enabled", true, silent: true)
            TuringEmailApp.models.userConfiguration.set("keyboard_shortcuts_enabled", false)

          it "stops the keyboard shortcuts handler", ->
            expect(@keyboardHandlerStartStub).not.toHaveBeenCalled()
            expect(@keyboardHandlerStopStub).toHaveBeenCalled()

    describe "#setupEmailFolders", ->
      it "creates the email folders collection and tree view", ->
        TuringEmailApp.setupEmailFolders()

        expect(TuringEmailApp.collections.emailFolders).toBeDefined()
        expect(TuringEmailApp.views.emailFoldersTreeView).toBeDefined()

        expect(TuringEmailApp.views.emailFoldersTreeView.collection).toEqual(TuringEmailApp.collections.emailFolders)
        expect(TuringEmailApp.views.emailFoldersTreeView.app).toEqual(TuringEmailApp)


      it "hooks the toolbar emailFolderSelected event", ->
        spy = sinon.spy(TuringEmailApp, "emailFolderSelected")

        TuringEmailApp.setupEmailFolders()
        TuringEmailApp.views.emailFoldersTreeView.trigger("emailFolderSelected")

        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "#setupComposeView", ->
      it "creates the compose view", ->
        TuringEmailApp.setupComposeView()

        expect(TuringEmailApp.views.composeView).toBeDefined()
        expect(TuringEmailApp.views.composeView.app).toEqual(TuringEmailApp)

      it "renders the compose view", ->
        # TODO figure out how to test render
        return

      it "hooks the compose view change:draft event", ->
        spy = sinon.spy(TuringEmailApp, "draftChanged")

        TuringEmailApp.setupComposeView()
        TuringEmailApp.views.composeView.trigger("change:draft")

        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "#setupCreateFolderView", ->
      it "creates the create folder view", ->
        TuringEmailApp.setupCreateFolderView()

        expect(TuringEmailApp.views.createFolderView).toBeDefined()
        expect(TuringEmailApp.views.createFolderView.app).toEqual(TuringEmailApp)

      it "hooks the create folder view createFolderFormSubmitted event", ->
        spy = sinon.spy(TuringEmailApp, "createFolderFormSubmitted")

        TuringEmailApp.setupCreateFolderView()
        TuringEmailApp.views.createFolderView.trigger("createFolderFormSubmitted", TuringEmailApp.views.createFolderView, "label", "test label name")

        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith("label", "test label name")
        spy.restore()

    describe "#setupEmailThreads", ->
      it "creates the email threads collection and list view", ->
        TuringEmailApp.setupEmailThreads()

        expect(TuringEmailApp.collections.emailThreads).toBeDefined()
        expect(TuringEmailApp.views.emailThreadsListView).toBeDefined()

        expect(TuringEmailApp.views.emailThreadsListView.collection).toEqual(TuringEmailApp.collections.emailThreads)

      threadsListViewEvents = ["listItemSelected", "listItemDeselected", "listItemChecked", "listItemUnchecked"]
      for event in threadsListViewEvents
        it "hooks the listview " + event + " event", ->
          spy = sinon.spy(TuringEmailApp, event)

          TuringEmailApp.setupEmailThreads()
          TuringEmailApp.views.emailThreadsListView.trigger(event)

          expect(spy).toHaveBeenCalled()
          spy.restore()

    describe "#setupRouters", ->
      it "creates the routers", ->
        TuringEmailApp.setupRouters()

        expect(TuringEmailApp.routers.emailFoldersRouter).toBeDefined()
        expect(TuringEmailApp.routers.emailThreadsRouter).toBeDefined()
        expect(TuringEmailApp.routers.analyticsRouter).toBeDefined()
        expect(TuringEmailApp.routers.reportsRouter).toBeDefined()
        expect(TuringEmailApp.routers.settingsRouter).toBeDefined()
        expect(TuringEmailApp.routers.searchResultsRouter).toBeDefined()
        expect(TuringEmailApp.routers.appsLibraryRouter).toBeDefined()
        expect(TuringEmailApp.routers.scheduleEmailsRouter).toBeDefined()
        expect(TuringEmailApp.routers.emailTrackersRouter).toBeDefined()
        expect(TuringEmailApp.routers.listSubscriptionsRouter).toBeDefined()
        expect(TuringEmailApp.routers.inboxCleanerRouter).toBeDefined()

  describe "after start", ->
    beforeEach ->
      TuringEmailApp.start(FactoryGirl.create("User"), FactoryGirl.create("UserConfiguration"), @emailTemplatesJSON, @uploadAttachmentPostJSON, @emailFoldersJSON)
      TuringEmailApp.showEmails()

      @server.restore()
      @server = sinon.fakeServer.create()

    describe "getters", ->
      describe "#selectedEmailThread", ->
        beforeEach ->
          emailThreadAttributes = FactoryGirl.create("EmailThread")
          @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes.toJSON(),
            app: TuringEmailApp
            emailThreadUID: emailThreadAttributes.uid
            demoMode: false
          )

          TuringEmailApp.views.emailThreadsListView.collection.add(@emailThread)
          TuringEmailApp.views.emailThreadsListView.select(@emailThread)

        it "returns the selected email thread", ->
          #expect(TuringEmailApp.selectedEmailThread()).toEqual(@emailThread)

      describe "#selectedEmailFolder", ->
        beforeEach ->
          emailFoldersData = FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE)
          @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection(emailFoldersData,
            app: TuringEmailApp
            demoMode: false
          )

          TuringEmailApp.views.emailFoldersTreeView.select(@emailFolders.models[0])

        it "returns the selected email folder", ->
          expect(TuringEmailApp.selectedEmailFolder()).toEqual(@emailFolders.models[0])

      describe "#selectedEmailFolderID", ->
        beforeEach ->
          @emailFolders = TuringEmailApp.collections.emailFolders
          @emailFolders.add(FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE))
          TuringEmailApp.views.emailFoldersTreeView.select(@emailFolders.models[0])

        it "returns the selected email folder id", ->
          expect(TuringEmailApp.selectedEmailFolderID()).toEqual(@emailFolders.models[0].get("label_id"))

    describe "setters", ->
      describe "#currentEmailThreadIs", ->
        beforeEach ->
          @loadEmailThreadStub = sinon.spy(TuringEmailApp, "loadEmailThread")

          @showEmailThreadStub = sinon.stub(TuringEmailApp, "showEmailThread", ->)
          @selectStub = sinon.stub(TuringEmailApp.views.emailThreadsListView, "select", ->)
          @deselectStub = sinon.stub(TuringEmailApp.views.emailThreadsListView, "deselect", ->)
          @uncheckAllCheckboxStub = sinon.stub(TuringEmailApp.views.toolbarView, "uncheckAllCheckbox", ->)

          @changeSelectedEmailThreadStub = sinon.backbone.spy(TuringEmailApp, "change:selectedEmailThread")

        afterEach ->
          @loadEmailThreadStub.restore()

          @showEmailThreadStub.restore()
          @selectStub.restore()
          @deselectStub.restore()
          @uncheckAllCheckboxStub.restore()

          @changeSelectedEmailThreadStub.restore()

        describe "the email thread exists", ->
          beforeEach ->
            TuringEmailApp.collections.emailThreads.reset(
              _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
                (emailThread) => emailThread.toJSON()
              )
            )
            @emailThread = TuringEmailApp.collections.emailThreads.at(0)

          describe "the email thread is currently displayed", ->
            beforeEach ->
              TuringEmailApp.currentEmailThreadView = {model: TuringEmailApp.collections.emailThreads.at(0)}

              TuringEmailApp.currentEmailThreadIs(TuringEmailApp.collections.emailThreads.at(0).get("uid"))

            afterEach ->
              TuringEmailApp.currentEmailThreadView = null

            it "does NOT selects the thread", ->
              expect(@selectStub).not.toHaveBeenCalled()

            it "does NOT shows the email thread", ->
              expect(@showEmailThreadStub).not.toHaveBeenCalled()

            it "does NOT unchecks all the checkboes", ->
              expect(@uncheckAllCheckboxStub).not.toHaveBeenCalled()

            it "does NOT trigger the change:selectedEmailThread event", ->
              expect(@changeSelectedEmailThreadStub).not.toHaveBeenCalled()

          describe "the email thread is not currently displayed", ->
            beforeEach ->
              TuringEmailApp.currentEmailThreadIs(@emailThread.get("uid"))

            it "loads the email thread", ->
              expect(@loadEmailThreadStub).toHaveBeenCalled()

            it "selects the thread", ->
              expect(@selectStub).toHaveBeenCalledWith(@emailThread)

            it "shows the email thread", ->
              expect(@showEmailThreadStub).toHaveBeenCalled()

            it "unchecks all the checkboes", ->
              expect(@uncheckAllCheckboxStub).toHaveBeenCalled()

            it "triggers the change:selectedEmailThread event", ->
              expect(@changeSelectedEmailThreadStub).toHaveBeenCalledWith(TuringEmailApp, @emailThread)

        describe "clear the email thread", ->
          beforeEach ->
            TuringEmailApp.currentEmailThreadIs(".")

          it "shows the email thread", ->
            expect(@showEmailThreadStub).toHaveBeenCalled()

          it "deselects the selected thread", ->
            expect(@deselectStub).toHaveBeenCalled()

          it "unchecks all the checkboes", ->
            expect(@uncheckAllCheckboxStub).toHaveBeenCalled()

          it "triggers the change:selectedEmailThread event", ->
            expect(@changeSelectedEmailThreadStub).toHaveBeenCalledWith(TuringEmailApp, null)

      describe "#currentEmailFolderIs", ->
        beforeEach ->
          @reloadEmailThreadsStub = sinon.stub(TuringEmailApp, "reloadEmailThreads", ->)
          @emailFoldersTreeViewSelectSpy = sinon.spy(TuringEmailApp.views.emailFoldersTreeView, "select")

          @changecurrentEmailFolderSpy = sinon.backbone.spy(TuringEmailApp, "change:currentEmailFolder")

          TuringEmailApp.currentEmailFolderIs("INBOX")

          TuringEmailApp.collections.emailThreads.reset(
            _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
              (emailThread) => emailThread.toJSON()
            )
          )

        afterEach ->
          @reloadEmailThreadsStub.restore()
          @emailFoldersTreeViewSelectSpy.restore()

          @changecurrentEmailFolderSpy.restore()

        describe "after fetch", ->
          beforeEach ->
            @reloadEmailThreadsStub.args[0][0].success(TuringEmailApp.collections.emailThreads)

            @emailFolder = TuringEmailApp.collections.emailFolders.get("INBOX")

          it "reloads the email threads", ->
            expect(@reloadEmailThreadsStub).toHaveBeenCalled()

          it "selects the email folder on the tree view", ->
            expect(@emailFoldersTreeViewSelectSpy).toHaveBeenCalledWith(@emailFolder, silent: true)

          it "triggers the change:currentEmailFolder event", ->
            expect(@changecurrentEmailFolderSpy).toHaveBeenCalledWith(TuringEmailApp, @emailFolder)

        describe "before fetch", ->
          beforeEach ->
            @currentEmailThreadIsStub = sinon.stub(TuringEmailApp, "currentEmailThreadIs", ->)

          afterEach ->
            @currentEmailThreadIsStub.restore()

          describe "no draft", ->
            describe "with split pane", ->
              beforeEach ->
                @isSplitPaneModeFunction = TuringEmailApp.isSplitPaneMode
                TuringEmailApp.isSplitPaneMode = -> return true

                @reloadEmailThreadsStub.args[0][0].success(TuringEmailApp.collections.emailThreads)
                @emailThread = TuringEmailApp.collections.emailThreads.at(0)

              afterEach ->
                TuringEmailApp.isSplitPaneMode = @isSplitPaneModeFunction

              it "selects an email thread", ->
                expect(@currentEmailThreadIsStub).toHaveBeenCalledWith(@emailThread.get("uid"))

            describe "with NO split pane", ->
              beforeEach ->
                @isSplitPaneModeFunction = TuringEmailApp.isSplitPaneMode
                TuringEmailApp.isSplitPaneMode = -> return false

                @reloadEmailThreadsStub.args[0][0].success(TuringEmailApp.collections.emailThreads)
                @emailThread = TuringEmailApp.collections.emailThreads.at(0)

              afterEach ->
                TuringEmailApp.isSplitPaneMode = @isSplitPaneModeFunction

              it "does NOT selects an email thread", ->
                expect(@currentEmailThreadIsStub).not.toHaveBeenCalledWith(@emailThread.get("uid"))

          describe "with draft", ->
            beforeEach ->
              TuringEmailApp.collections.emailThreads.at(0).get("emails")[0].draft_id = "1"

            describe "with NO split pane", ->
              beforeEach ->
                @isSplitPaneModeFunction = TuringEmailApp.isSplitPaneMode
                TuringEmailApp.isSplitPaneMode = -> return false

                @reloadEmailThreadsStub.args[0][0].success(TuringEmailApp.collections.emailThreads)
                @emailThread = TuringEmailApp.collections.emailThreads.at(0)

              afterEach ->
                TuringEmailApp.isSplitPaneMode = @isSplitPaneModeFunction

              it "does NOT selects an email thread", ->
                expect(@currentEmailThreadIsStub).not.toHaveBeenCalledWith(@emailThread.get("uid"))

    describe "#syncEmail", ->
      beforeEach ->
        @syncEmailStub.restore()

        @reloadEmailThreadsStub = sinon.stub(TuringEmailApp, "reloadEmailThreads")
        @loadEmailFoldersStub = sinon.stub(TuringEmailApp, "loadEmailFolders")
        @setTimeoutStub = sinon.stub(window, "setTimeout", ->)

        TuringEmailApp.syncEmail()

      afterEach ->
        @reloadEmailThreadsStub.restore()
        @loadEmailFoldersStub.restore()
        @setTimeoutStub.restore()

        @syncEmailStub = sinon.stub(TuringEmailApp, "syncEmail")

      it "reloads the emails threads", ->
        expect(@reloadEmailThreadsStub).toHaveBeenCalled()

      it "reloads the emails folders", ->
        expect(@loadEmailFoldersStub).toHaveBeenCalled()

      it "schedules the next sync", ->
        expect(@setTimeoutStub).toHaveBeenCalled()
        specCompareFunctions((=> @syncEmail()), @setTimeoutStub.args[0][0])
        expect(@setTimeoutStub.args[0][1]).toEqual(60000)

      describe "demoMode=true", ->
        beforeEach ->
          @postStub = sinon.stub($, "post", -> done: sinon.stub())
          TuringEmailApp.models.userConfiguration.set("demo_mode_enabled", true)

          TuringEmailApp.syncEmail()

        afterEach ->
          @postStub.restore()

        it "posts", ->
          expect(@postStub).toHaveBeenCalledWith("api/v1/email_accounts/sync")

      describe "demoMode=false", ->
        beforeEach ->
          @postStub = sinon.stub($, "post", ->)
          TuringEmailApp.models.userConfiguration.set("demo_mode_enabled", false)

          TuringEmailApp.syncEmail()

        afterEach ->
          @postStub.restore()

        it "does NOT post", ->
          expect(@postStub).not.toHaveBeenCalled()

    describe "Alert Functions", ->
      describe "#showAlert", ->
        beforeEach ->
          @alertText = "test"
          @alertClass = "testAlert"
          @alertSelector = "." + @alertClass

          @removeAlertSpy = sinon.spy(TuringEmailApp, "removeAlert")
          @setTimeoutStub = sinon.stub(window, "setTimeout", ->)

          if TuringEmailApp.currentAlert?
            TuringEmailApp.currentAlert.remove()
            TuringEmailApp.currentAlert = undefined

        afterEach ->
          TuringEmailApp.removeAlert(@token)
          @removeAlertSpy.restore()
          @setTimeoutStub.restore()

        describe "when there is no current alert", ->
          beforeEach ->
            expect(TuringEmailApp.currentAlert).not.toBeDefined()
            @token = TuringEmailApp.showAlert(@alertText, @alertClass)

          it "shows the alert", ->
            expect($(@alertSelector).length).toEqual(1)
            expect($(@alertSelector).text().replace(/(\r\n|\n|\r)/gm,"")).toEqual(@alertText + "×")

          it "does not remove an existing alert", ->
            expect(@removeAlertSpy).not.toHaveBeenCalled()

          it "returns the token", ->
            expect(TuringEmailApp.currentAlert.token).toEqual(@token)

          it "adds the dismiss link", ->
            expect($(@alertSelector).find(".tm_alert-dismiss").length).toBeGreaterThan(0)

          it "dismisses the alert when the dismiss alert link is clicked", ->
            $(".tm_alert-dismiss").click()
            expect(@removeAlertSpy).toHaveBeenCalledWith(@token)

          it "does not queue remove", ->
            expect(@setTimeoutStub).not.toHaveBeenCalled()

        describe "when an alert is displayed", ->
          beforeEach ->
            TuringEmailApp.showAlert("a", "b")
            @token = TuringEmailApp.showAlert(@alertText, @alertClass)

          it "removes the alert", ->
            expect(@removeAlertSpy).toHaveBeenCalled()

        describe "when removeAfterSeconds is specified", ->
          beforeEach ->
            @removeAfterSeconds = 500
            TuringEmailApp.showAlert("a", "b", @removeAfterSeconds)
            TuringEmailApp.showAlert(@alertText, @alertClass)

          it "queues alert removal", ->
            expect(@setTimeoutStub).toHaveBeenCalled()
            specCompareFunctions((=> @removeAlert(token)), @setTimeoutStub.args[0][0])
            expect(@setTimeoutStub.args[0][1]).toEqual(@removeAfterSeconds)

      describe "#removeAlert", ->
        beforeEach ->
          @alertText = "test"
          @alertClass = "testAlert"
          @alertSelector = "." + @alertClass

          @token = TuringEmailApp.showAlert(@alertText, @alertClass)

          @alert = $(@alertSelector)

        describe "when the token does not match", ->
          beforeEach ->
            TuringEmailApp.removeAlert(@token + "1")

          it "does NOT remove the alert", ->
            expect(@alert).toBeInDOM()

        # TODO: figure out how to test this when called with fadeOut.
        # describe "when the token matches", ->
        #   beforeEach ->
        #     @fadeOutStub = sinon.spy($, "fadeOut", ->)
        #     TuringEmailApp.removeAlert(@token)

        #   afterEach ->
        #     @fadeOutStub.restore()

        #   it "removes the alert", ->
        #     expect(@alert).not.toBeInDOM()

    describe "Email Folder Functions", ->
      describe "#loadEmailFolders", ->
        beforeEach ->
          @fetchStub = sinon.spy(TuringEmailApp.collections.emailFolders, "fetch")
          @changeEmailFoldersSpy = sinon.backbone.spy(TuringEmailApp, "change:emailFolders")

          TuringEmailApp.loadEmailFolders()

        afterEach ->
          @changeEmailFoldersSpy.restore()
          @fetchStub.restore()

        it "fetches the email folders", ->
          expect(@fetchStub).toHaveBeenCalled()

        it "sets the reset option to true", ->
          expect(@fetchStub.args[0][0].reset).toBeTruthy()

        describe "after the email folders are fetched", ->
          beforeEach ->
            options = @fetchStub.args[0][0]
            options.success(TuringEmailApp.collections.emailFolders, {}, options)

          it "triggers the change:emailFolders event", ->
            expect(@changeEmailFoldersSpy).toHaveBeenCalledWith(TuringEmailApp, TuringEmailApp.collections.emailFolders)

    describe "Email Thread Functions", ->
      describe "#loadEmailThread", ->
        beforeEach ->
          @callback = sinon.spy()

        describe "when the email thread is NOT in the collection", ->
          beforeEach ->
            @fetchStub = sinon.spy(TuringEmailApp.Models.EmailThread.__super__, "fetch")

            emailThreadAttributes = FactoryGirl.create("EmailThread")
            @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes,
              app: TuringEmailApp
              emailThreadUID: emailThreadAttributes.uid
              demoMode: false
            )

          afterEach ->
            @fetchStub.restore()

          it "fetches the email thread and then calls the callback", ->
            expect(@callback).not.toHaveBeenCalled()
            TuringEmailApp.loadEmailThread(@emailThread.get("uid"), @callback)
            @fetchStub.args[0][0].success(@emailThread, {}, null)
            expect(@callback).toHaveBeenCalled()

        describe "when the email thread is in the collection", ->
          beforeEach ->
            TuringEmailApp.collections.emailThreads.reset(
              _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
                (emailThread) => emailThread.toJSON()
              )
            )
            TuringEmailApp.loadEmailThread(TuringEmailApp.collections.emailThreads.at(0).get("uid"), @callback)

          it "calls the callback", ->
            expect(@callback).toHaveBeenCalled()

      describe "#reloadEmailThreads", ->
        beforeEach ->
          @fetchStub = sinon.spy(TuringEmailApp.collections.emailThreads, "fetch")

          @success = sinon.stub()
          @error = sinon.stub()

        afterEach ->
          @fetchStub.restore()

        it "fetches the email threads", ->
          TuringEmailApp.reloadEmailThreads(success: @success, error: @error)
          expect(@fetchStub).toHaveBeenCalled()

        describe "on success", ->
          beforeEach ->
            TuringEmailApp.collections.emailThreads.reset(
              _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
                (emailThread) => emailThread.toJSON()
              )
            )
            @oldEmailThreads = TuringEmailApp.collections.emailThreads.models

            @stopListeningSpy = sinon.spy(TuringEmailApp, "stopListening")
            @listenToSpy = sinon.spy(TuringEmailApp, "listenTo")

            @triggerStub = sinon.stub(@oldEmailThreads[0], "trigger")
            TuringEmailApp.views.emailThreadsListView.select(@oldEmailThreads[0])
            @emailThreadsListViewSelectStub = sinon.stub(TuringEmailApp.views.emailThreadsListView, "select", ->)

            TuringEmailApp.reloadEmailThreads(success: @success, error: @error)
            TuringEmailApp.collections.emailThreads.reset(_.clone(@oldEmailThreads))

            @response = {}
            @options = previousModels: @oldEmailThreads
            @fetchStub.args[0][0].success(TuringEmailApp.collections.emailThreads, @response, @options)

          afterEach ->
            @stopListeningSpy.restore()
            @listenToSpy.restore()
            @emailThreadsListViewSelectStub.restore()
            @triggerStub.restore()

          it "stops listening on the old models", ->
            expect(@stopListeningSpy).toHaveBeenCalledWith(oldEmailThread) for oldEmailThread in @oldEmailThreads

          it "listens for change:seen on the new models", ->
            for emailThread in TuringEmailApp.collections.emailThreads.models
              expect(@listenToSpy).toHaveBeenCalledWith(emailThread, "change:seen", TuringEmailApp.emailThreadSeenChanged)

          it "listens for change:folder on the new models", ->
            for emailThread in TuringEmailApp.collections.emailThreads.models
              expect(@listenToSpy).toHaveBeenCalledWith(emailThread, "change:folder", TuringEmailApp.emailThreadFolderChanged)

          it "selects the previously selected email thread", ->
            emailThreadToSelect = TuringEmailApp.collections.emailThreads.get(@oldEmailThreads[0].get("uid"))
            expect(@emailThreadsListViewSelectStub).toHaveBeenCalledWith(emailThreadToSelect)

          it "calls the success callback", ->
            expect(@success).toHaveBeenCalled()

          it "does NOT call the error callback", ->
            expect(@error).not.toHaveBeenCalled()

        describe "on error", ->
          beforeEach ->
            TuringEmailApp.reloadEmailThreads(success: @success, error: @error)
            @fetchStub.args[0][0].error()

          it "does NOT call the success callback", ->
            expect(@success).not.toHaveBeenCalled()

          it "calls the error callback", ->
            expect(@error).toHaveBeenCalled()

      describe "#loadSearchResults", ->
        beforeEach ->
          @reloadEmailThreadsStub = sinon.spy(TuringEmailApp, "reloadEmailThreads")
          @showEmailsStub = sinon.stub(TuringEmailApp, "showEmails", ->)

          @query = "test"
          TuringEmailApp.loadSearchResults(@query)

        afterEach ->
          @showEmailsStub.restore()
          @reloadEmailThreadsStub.restore()

        it "reloads the email threads", ->
          expect(@reloadEmailThreadsStub).toHaveBeenCalled()

        it "passes on the query", ->
          expect(@reloadEmailThreadsStub.args[0][0].query).toEqual(@query)

        describe "on success", ->
          beforeEach ->
            @reloadEmailThreadsStub.args[0][0].success()

          it "shows the emails", ->
            expect(@showEmailsStub).toHaveBeenCalled()

      describe "#applyActionToSelectedThreads", ->
        beforeEach ->
          @singleAction = sinon.spy()
          @multiAction = sinon.spy()

          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

        afterEach ->
          @listViewDiv.remove()

        describe "when refreshFolders is true", ->

          it "refreshes the email folders.", ->
            @loadEmailFoldersSpy = sinon.spy(TuringEmailApp, "loadEmailFolders")
            TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, true, true, true)
            expect(@loadEmailFoldersSpy).toHaveBeenCalled()
            @loadEmailFoldersSpy.restore()

        describe "clearSelection", ->
          beforeEach ->
            @origisSplitPaneMode = TuringEmailApp.isSplitPaneMode

            @currentEmailThreadIsSpy = sinon.spy(TuringEmailApp, "currentEmailThreadIs")
            @goBackClickedSpy = sinon.spy(TuringEmailApp, "goBackClicked")

          afterEach ->
            @currentEmailThreadIsSpy.restore()
            @goBackClickedSpy.restore()

            TuringEmailApp.isSplitPaneMode = @origisSplitPaneMode

          describe "is true", ->
            describe "with split pane", ->
              beforeEach ->
                TuringEmailApp.isSplitPaneMode = -> return true
                TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, true, true)

              it "clears the current email thread", ->
                expect(@currentEmailThreadIsSpy).toHaveBeenCalledWith()
                expect(@goBackClickedSpy).not.toHaveBeenCalled()

            describe "without split pane", ->
              beforeEach ->
                TuringEmailApp.isSplitPaneMode = -> return false
                TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, true, true)

              it "clears the current email thread", ->
                expect(@currentEmailThreadIsSpy).not.toHaveBeenCalled()
                expect(@goBackClickedSpy).toHaveBeenCalled()

          describe "is false", ->
            describe "with split pane", ->
              beforeEach ->
                TuringEmailApp.isSplitPaneMode = -> return true
                TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, true, false)

              it "clears the current email thread", ->
                expect(@currentEmailThreadIsSpy).not.toHaveBeenCalled()
                expect(@goBackClickedSpy).not.toHaveBeenCalled()

            describe "without split pane", ->
              beforeEach ->
                TuringEmailApp.isSplitPaneMode = -> return false
                TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, true, false)

              it "clears the current email thread", ->
                expect(@currentEmailThreadIsSpy).not.toHaveBeenCalled()
                expect(@goBackClickedSpy).not.toHaveBeenCalled()

        describe "when an item is selected", ->
          beforeEach ->
            @emailThread = @emailThreads.models[0]
            @listView.select(@emailThread)

          describe "when remove is true", ->
            beforeEach ->
              TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, true)

            it "calls the single action", ->
              expect(@singleAction).toHaveBeenCalled()

            it "does NOT call the multi action", ->
              expect(@multiAction).not.toHaveBeenCalled()

            it "removes the item", ->
              expect(@emailThreads.findWhere(uid: @emailThread.uid)).toBeFalsy()

          describe "when remove is false", ->
            beforeEach ->
              TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, false)

            it "calls the single action", ->
              expect(@singleAction).toHaveBeenCalled()

            it "does NOT call the multi action", ->
              expect(@multiAction).not.toHaveBeenCalled()

            it "removes the item", ->
              expect(@emailThreads.findWhere(uid: @emailThread.uid)).toBeUndefined()

        describe "when an item is checked", ->
          beforeEach ->
            @emailThread = @emailThreads.models[0]
            @emailThreadUID = @emailThread.get("uid")
            @listItemView = @listView.listItemViews[@emailThreadUID]
            @listView.check(@emailThread)

          describe "when remove is true", ->
            beforeEach ->
              TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, true)

            it "does NOT call the single action", ->
              expect(@singleAction).not.toHaveBeenCalled()

            it "calls the multi action", ->
              expect(@multiAction).toHaveBeenCalledWith([@listItemView], [@emailThreadUID])

            it "removes the item", ->
              expect(@emailThreads.findWhere(uid: @emailThread.uid)).toBeFalsy()

          describe "when remove is false", ->
            beforeEach ->
              TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, false)

            it "does NOT call the single action", ->
              expect(@singleAction).not.toHaveBeenCalled()

            it "calls the multi action", ->
              expect(@multiAction).toHaveBeenCalledWith([@listItemView], [@emailThreadUID])

            it "removes the item", ->
              expect(@emailThreads.findWhere(uid: @emailThread.uid)).toBeUndefined()
