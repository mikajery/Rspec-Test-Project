describe "MainView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @mainView = TuringEmailApp.views.mainView
    @mainView.app.models.userConfiguration.set("split_pane_mode", "horizontal")

    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  describe "#initialize", ->
    it "has the right template", ->
      expect(@mainView.template).toEqual JST["backbone/templates/main"]

    it "has the right event", ->
      expect(@mainView.events["click .tm_compose-button"]).toEqual "compose"

    it "saves the app initialization parameter", ->
      expect(@mainView.app).toEqual(TuringEmailApp)

    it "hooks the window resize event", ->
      expect($(window)).toHandle("resize")

    it "creates the toolbar", ->
      expect(@mainView.toolbarView).toBeDefined()

  describe "#render", ->
    beforeEach ->
      @clock = sinon.useFakeTimers()
      @resizeSpy = sinon.spy(@mainView, "resize")
      @mainView.render()

    afterEach ->
      @resizeSpy.restore()
      @clock.restore()

    it "creates the primary_pane", ->
      expect(@mainView.primaryPaneDiv).toBeDefined()

    it "creates the sidebar view", ->
      expect(@mainView.sidebarView).toBeDefined()

    it "creates the compose view", ->
      expect(@mainView.composeView).toBeDefined()

    it "resized", ->
      expect(@resizeSpy).toHaveBeenCalled()

    it "creates the create folder view", ->
      expect(@mainView.createFolderView).toBeDefined()

  describe "#createEmailThreadsListView", ->
    beforeEach ->
      @server.restore()

      @emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
        app: TuringEmailApp
        demoMode: false
      )
      @emailThreads.reset(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE))
      @mainView.createEmailThreadsListView(@emailThreads)

    it "creates the emailThreadsListView", ->
      expect(@mainView.emailThreadsListView).toBeDefined()

  describe "Resize Functions", ->
    describe "#onWindowResize", ->
      beforeEach ->
        @resizeSpy = sinon.stub(@mainView, "resize", ->)

        @mainView.onWindowResize()

      afterEach ->
        @resizeSpy.restore()

      it "resizes", ->
        expect(@resizeSpy).toHaveBeenCalled()

    describe "#resize", ->
      beforeEach ->
        @sidebarResizeSpy = sinon.stub(@mainView, "resizeSidebar", ->)
        @resizePrimaryPaneSpy = sinon.stub(@mainView, "resizePrimaryPane", ->)
        @resizePrimarySplitPaneSpy = sinon.stub(@mainView, "resizePrimarySplitPane", ->)
        @resizeAppsSplitPaneSpy = sinon.stub(@mainView, "resizeAppsSplitPane", ->)

        @mainView.resize()

      afterEach ->
        @sidebarResizeSpy.restore()
        @resizePrimaryPaneSpy.restore()
        @resizePrimarySplitPaneSpy.restore()
        @resizeAppsSplitPaneSpy.restore()

      it "resizes the sidebar", ->
        expect(@sidebarResizeSpy).toHaveBeenCalled()

      it "resizes the primary pane", ->
        expect(@resizePrimaryPaneSpy).toHaveBeenCalled()

      it "resizes the primary split pane", ->
        expect(@resizePrimarySplitPaneSpy).toHaveBeenCalled()

      it "resizes the apps split pane", ->
        expect(@resizeAppsSplitPaneSpy).toHaveBeenCalled()

  describe "after render and createEmailThreadsListView", ->
    beforeEach ->
      @mainView.render()

      @server.restore()

      @emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
        app: TuringEmailApp
        demoMode: false
      )
      @emailThreads.reset(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE))
      @mainView.createEmailThreadsListView(@emailThreads)

      @primaryPane = @mainView.$el.find(".tm_primary")

    describe "#compose", ->

      it "loads an empty compose view on click", ->
        @spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmpty")

        @mainView.compose()

        expect(@spy).toHaveBeenCalled()
        @spy.restore()

      it "shows the compose view on click", ->
        @spy = sinon.spy(TuringEmailApp.views.composeView, "show")

        @mainView.compose()

        expect(@spy).toHaveBeenCalled()
        @spy.restore()

    describe "View Functions", ->
      describe "#showEmails", ->

        describe "when the inbox tabs feature is enabled", ->
          beforeEach ->
            @mainView.app.models.userConfiguration.set("inbox_tabs_enabled", true)

          afterEach ->
            @mainView.app.models.userConfiguration.set("inbox_tabs_enabled", false)

          describe "when the email folder is one of the core system labels", ->
            beforeEach ->
              @selectedEmailFolderIDStub = sinon.stub(TuringEmailApp, "selectedEmailFolderID")
              @selectedEmailFolderIDStub.returns("INBOX")
              @mainView.showEmails()

            afterEach ->
              @selectedEmailFolderIDStub.restore()

            it "renders the inbox tabs in the primary pane", ->
              expect(@mainView.$el).toContain($(".tm_inbox-tabs"))

          describe "when the email folder is not one of the core system labels", ->
            beforeEach ->
              @selectedEmailFolderIDStub = sinon.stub(TuringEmailApp, "selectedEmailFolderID")
              @selectedEmailFolderIDStub.returns("Label_45")
              @mainView.showEmails()

            afterEach ->
              @selectedEmailFolderIDStub.restore()

            it "does not render the inbox tabs in the primary pane", ->
              expect(@mainView.$el).not.toContain($(".tm_inbox-tabs"))

        describe "when the inbox tabs feature is disabled", ->
          beforeEach ->
            @mainView.app.models.userConfiguration.set("inbox_tabs_enabled", false)

          describe "when the email folder is one of the core system labels", ->
            beforeEach ->
              @selectedEmailFolderIDStub = sinon.stub(TuringEmailApp, "selectedEmailFolderID")
              @selectedEmailFolderIDStub.returns("INBOX")
              @mainView.showEmails()

            afterEach ->
              @selectedEmailFolderIDStub.restore()

            it "does not render the inbox tabs in the primary pane", ->
              expect(@mainView.$el).not.toContain($(".tm_inbox-tabs"))

          describe "when the email folder is not one of the core system labels", ->
            beforeEach ->
              @selectedEmailFolderIDStub = sinon.stub(TuringEmailApp, "selectedEmailFolderID")
              @selectedEmailFolderIDStub.returns("Label_45")
              @mainView.showEmails()

            afterEach ->
              @selectedEmailFolderIDStub.restore()

            it "does not render the inbox tabs in the primary pane", ->
              expect(@mainView.$el).not.toContain($(".tm_inbox-tabs"))

        describe "without split pane", ->
          beforeEach ->
            @resizePrimarySplitPaneSpy = sinon.spy(@mainView, "resizePrimarySplitPane")

            @mainView.showEmails(false)

          afterEach ->
            @resizePrimarySplitPaneSpy.restore()

          it "shows the email controls", ->
            expect(@primaryPane.children().length).toEqual(2)
            expect($(@primaryPane.children()[0])).toHaveClass("tm_headbar")
            expect( $($(@primaryPane.children()[1]).children()[1]).hasClass("email-threads-list-view") or $($(@primaryPane.children()[1]).children()[1]).hasClass("tm_mail-box-loading")).toBeTruthy()

        describe "with split pane", ->
          beforeEach ->
            @mainView.showEmails(true)

          it "shows the email controls", ->
            expect(@primaryPane.children().length).toEqual(2)
            expect($(@primaryPane.children()[0])).toHaveClass("tm_headbar")
            expect($(@primaryPane.children()[1])).toHaveClass("tm_mail-split-pane")

            splitPane = $(@primaryPane.children()[1])
            expect(splitPane.children().length).toEqual(3)

            expect(splitPane.children().first().children().first()).toHaveClass("email-threads-list-view")
            expect(splitPane.children()[1]).toHaveClass("tm_mail-view")
            expect(splitPane.children()[2]).toHaveClass("ui-layout-resizer-south")

          it "adds the no conversation selected text when there is no conversation selected", ->
            splitPane = $(@primaryPane.children()[1])
            emailThreadView = splitPane.children()[1]
            expect(emailThreadView).toContainHtml("<div class='tm_empty-pane'>No conversations selected</div>")

        describe "when there are no emails in list view's collection", ->
          beforeEach ->
            @mainView.emailThreadsListView.collection =
              new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
                app: TuringEmailApp
                demoMode: false
              )

            @selectedEmailFolderIDStub = sinon.stub(TuringEmailApp, "selectedEmailFolderID")

          afterEach ->
            @selectedEmailFolderIDStub.restore()

          it "does not render the email thread list view", ->
            spy = sinon.spy(@mainView.emailThreadsListView, "render")
            @mainView.showEmails(true)
            expect(spy).not.toHaveBeenCalled()
            spy.restore()

          describe "when the currently selected folder is the inbox", ->
            beforeEach ->
              @selectedEmailFolderIDStub.returns("INBOX")
              @mainView.showEmails(true)

            it "renders that there are not conversations with that label.", ->
              expect(@mainView.primaryPaneDiv).toContainHtml("<div class='tm_empty-pane'>Congratulations on reaching inbox zero!</div>")

          describe "when the currently selected folder is not the inbox", ->
            beforeEach ->
              @selectedEmailFolderIDStub.returns("Label_45")
              @mainView.showEmails(true)

            it "renders that there are not conversations with that label.", ->
              expect(@mainView.primaryPaneDiv).toContainHtml("<div class='tm_empty-pane'>There are no conversations with this label</div>")

      describe "#showSettings", ->
        beforeEach ->
          @server.restore()

          @server = sinon.fakeServer.create()


          @settingsView = @mainView.showSettings()

        it "shows the settings view", ->
          expect(@primaryPane.children().length).toEqual(2)
          expect($(@primaryPane.children()[1]).html()).toEqual(@settingsView.$el.html())

      describe "#showAppsLibrary", ->
        beforeEach ->
          @appsLibraryView = @mainView.showAppsLibrary()

        it "shows the apps library view", ->
          expect(@primaryPane.children().length).toEqual(2)
          expect($(@primaryPane.children()[1]).html()).toEqual(@appsLibraryView.$el.html())

      describe "#showScheduleEmails", ->
        beforeEach ->
          @delayedEmailsView = @mainView.showScheduleEmails()

        it "shows the delayed emails view", ->
          expect(@primaryPane.children().length).toEqual(2)
          expect($(@primaryPane.children()[1]).html()).toEqual(@delayedEmailsView.$el.html())

      describe "#showEmailTrackers", ->
        beforeEach ->
          @emailTrackersView = @mainView.showEmailTrackers()

        it "shows the email trackers view", ->
          expect(@primaryPane.children().length).toEqual(2)
          expect($(@primaryPane.children()[1]).html()).toEqual(@emailTrackersView.$el.html())

      describe "#showListSubscriptions", ->
        beforeEach ->
          @listSubscriptionsView = @mainView.showListSubscriptions()

        it "shows the list subscriptions view", ->
          expect(@primaryPane.children().length).toEqual(2)
          expect($(@primaryPane.children()[1]).html()).toEqual(@listSubscriptionsView.$el.html())

      describe "#showInboxCleaner", ->
        beforeEach ->
          @inboxCleanerView = @mainView.showInboxCleaner()

        it "shows the inbox cleaner view", ->
          expect(@primaryPane.children().length).toEqual(2)
          expect($(@primaryPane.children()[1]).html()).toEqual(@inboxCleanerView.$el.html())

      describe "#showAnalytics", ->
        beforeEach ->
          @server.restore()
          @server = specPrepareReportFetches()

          @analyticsView = @mainView.showAnalytics()

          @server.respond()

        it "shows the analytics view", ->
          expect(@primaryPane.children().length).toEqual(2)
          expect($(@primaryPane.children()[1]).html()).toEqual(@analyticsView.$el.html())
          reportDiv = $(@primaryPane).find(".attachments_report")
          expect(reportDiv.length).toEqual(1)
          expect(reportDiv.html()).not.toEqual("")

      describe "#showReport", ->
        beforeEach ->
          @reportView = @mainView.showReport(TuringEmailApp.Models.Reports.AttachmentsReport,
                                             TuringEmailApp.Views.PrimaryPane.Analytics.Reports.AttachmentsReportView)

        it "shows the report view", ->
          expect(@primaryPane.children().length).toEqual(1)
          expect($(@primaryPane.children()[0]).html()).toEqual(@reportView.$el.html())

      describe "#showEmailThread", ->
        beforeEach ->
          emailThreadAttributes = FactoryGirl.create("EmailThread")
          emailDraftAttributes = FactoryGirl.create("Email", draft_id: "draft")
          emailThreadAttributes.emails.push(emailDraftAttributes)

          @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes.toJSON(),
            app: TuringEmailApp
            emailThreadUID: emailThreadAttributes.uid
            demoMode: false
          )

        describe "with apps", ->
          beforeEach ->
            TuringEmailApp.models.userConfiguration.set(FactoryGirl.create("UserConfiguration"))
            @oldCurrentEmailThreadView = @mainView.currentEmailThreadView = {}

            @server = sinon.fakeServer.create()

            @resizeAppsSplitPaneStub = sinon.stub(@mainView, "resizeAppsSplitPane")
            @runAppsStub = sinon.stub(@mainView, "runApps")
            @stopListeningStub = sinon.stub(@mainView, "stopListening")
            @listenToStub = sinon.stub(@mainView, "listenTo")

            @emailThreadView = TuringEmailApp.views.mainView.showEmailThread(@emailThread, true)
            @appsSplitPaneDiv = $(@primaryPane.find(".apps_split_pane"))

            @appsDiv = $(@appsSplitPaneDiv.children()[1])

          afterEach ->
            @stopListeningStub.restore()
            @listenToStub.restore()
            @runAppsStub.restore()
            @resizeAppsSplitPaneStub.restore()
            @server.restore()

          it "stops listening on the currentEmailThreadView", ->
            expect(@stopListeningStub).toHaveBeenCalledWith(@oldCurrentEmailThreadView)

          it "creates the split pane", ->
            expect(@appsSplitPaneDiv).toBeDefined()

          it "puts the thread view in the center pane", ->
            expect(@emailThreadView.$el).toHaveClass("ui-layout-center")

          it "adds the email thread view to the split pane", ->
            expect(@appsSplitPaneDiv.children()[0]).toEqual(@emailThreadView.$el[0])

          it "adds the apps div to the split pane", ->
            expect(@appsDiv[0].nodeName).toEqual("DIV")

          it "puts the apps div in the east pane", ->
            expect(@appsDiv).toHaveClass("ui-layout-east")

          it "runs all the apps", ->
            expect(@runAppsStub).toHaveBeenCalled()
            expect(@runAppsStub.args[0][0].html()).toEqual(@appsDiv.html())
            expect(@runAppsStub.args[0][1]).toEqual(@emailThread)

          it "listens for expand:email", ->
            expect(@listenToStub).toHaveBeenCalledWith(@emailThreadView, "expand:email")
            specCompareFunctions(((emailThreadView, emailJSON) => @runApps(appsDiv, emailJSON)), @listenToStub.args[0][2])

          it "resizes the apps split pane", ->
            expect(@resizeAppsSplitPaneStub).toHaveBeenCalled()

        describe "without apps", ->
          describe "when split pane mode is on", ->
            beforeEach ->
              @emailThreadView = TuringEmailApp.views.mainView.showEmailThread(@emailThread, true)

            it "renders the email thread in the email_thread_view", ->
              emailThreadView = $(@primaryPane.find(".email-thread,.tm_empty-pane,.tm_mail-email-thread-loading")).parent()
              expect(emailThreadView.html()).toEqual(@emailThreadView.$el.html())

          describe "when split pane mode is off", ->
            beforeEach ->
              @emailThreadView = TuringEmailApp.views.mainView.showEmailThread(@emailThread, false)

            it "renders the email thread in the primary pane", ->
              emailThreadView = $(@primaryPane.children()[1])
              expect(emailThreadView.html()).toEqual(@emailThreadView.$el.html())

      describe "#runApps", ->
        beforeEach ->
          TuringEmailApp.models.userConfiguration.set(FactoryGirl.create("UserConfiguration"))

          @appsDiv = $("<div />")
          @email = new TuringEmailApp.Models.Email(FactoryGirl.create("Email").toJSON())

          @runStub = sinon.stub(TuringEmailApp.Models.InstalledApps.InstalledPanelApp.prototype, "run")

          @mainView.runApps(@appsDiv, @email)

        afterEach ->
          @runStub.restore()

        it "runs the apps", ->
          expect(@runStub.callCount).toEqual(TuringEmailApp.models.userConfiguration.get("installed_apps").length)

        it "adds the app iframes to the split pane", ->
          expect(@appsDiv.children().length).toEqual(TuringEmailApp.models.userConfiguration.get("installed_apps").length)

      describe "#showWelcomeTour", ->
        beforeEach ->
          @mainView.tourView = null
          @mainView.showWelcomeTour()

        it "create the tour view", ->
          expect(@mainView.tourView).toBeDefined()
