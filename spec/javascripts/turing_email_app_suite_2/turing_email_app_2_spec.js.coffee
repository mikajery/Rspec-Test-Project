describe "TuringEmailApp suite 2", ->
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

  describe "after start", ->
    beforeEach ->
      TuringEmailApp.start(FactoryGirl.create("User"), FactoryGirl.create("UserConfiguration"), @emailTemplatesJSON, @uploadAttachmentPostJSON, @emailFoldersJSON)
      TuringEmailApp.showEmails()

      @server.restore()
      @server = sinon.fakeServer.create()

    describe "General Events", ->
      describe "#checkAllClicked", ->
        beforeEach ->
          @spy = sinon.spy(TuringEmailApp.views.emailThreadsListView, "checkAll")
          TuringEmailApp.checkAllClicked()

        afterEach ->
          @spy.restore()

        it "checks all the items in the email threads list view", ->
          expect(@spy).toHaveBeenCalled()

      describe "#checkAllReadClicked", ->
        beforeEach ->
          @spy = sinon.spy(TuringEmailApp.views.emailThreadsListView, "checkAllRead")
          TuringEmailApp.checkAllReadClicked()

        afterEach ->
          @spy.restore()

        it "checks all the read items in the email threads list view", ->
          expect(@spy).toHaveBeenCalled()

      describe "#checkAllUnreadClicked", ->
        beforeEach ->
          @spy = sinon.spy(TuringEmailApp.views.emailThreadsListView, "checkAllUnread")
          TuringEmailApp.checkAllUnreadClicked()

        afterEach ->
          @spy.restore()

        it "checks all the unread items in the email threads list view", ->
          expect(@spy).toHaveBeenCalled()

      describe "#uncheckAllClicked", ->
        beforeEach ->
          @spy = sinon.spy(TuringEmailApp.views.emailThreadsListView, "uncheckAll")
          TuringEmailApp.uncheckAllClicked()

        afterEach ->
          @spy.restore()

        it "unchecks all items in the email threads list view", ->
          expect(@spy).toHaveBeenCalled()

      describe "#readClicked", ->
        beforeEach ->
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = @emailThreads.models[0]

        afterEach ->
          @listViewDiv.remove()

        describe "when an email thread is selected", ->
          beforeEach ->
            @listView.select(@emailThread)

            @setStub = sinon.stub(@emailThread, "set", ->)

            TuringEmailApp.readClicked()

          afterEach ->
            @setStub.restore()

          it "sets the email thread to read", ->
            expect(@setStub).toHaveBeenCalledWith("seen", true)

        describe "when an email thread is checked", ->
          beforeEach ->
            @listView.check(@emailThread)

            @setStub = sinon.stub(@emailThread, "set", ->)

            TuringEmailApp.readClicked()

          afterEach ->
            @setStub.restore()

          it "sets the email thread to read", ->
            expect(@setStub).toHaveBeenCalledWith("seen", true)

      describe "#unreadClicked", ->
        beforeEach ->
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = @emailThreads.models[0]

        afterEach ->
          @listViewDiv.remove()

        describe "when an email thread is selected", ->
          beforeEach ->
            @listView.select(@emailThread)

            @setSeenStub = sinon.stub(@emailThread, "setSeen", ->)

            TuringEmailApp.unreadClicked()

          afterEach ->
            @setSeenStub.restore()

          it "sets the email thread to unread", ->
            expect(@setSeenStub).toHaveBeenCalledWith(false)

        describe "when an email thread is checked", ->
          beforeEach ->
            @listView.check(@emailThread)

            @setSeenStub = sinon.stub(@emailThread, "setSeen", ->)

            TuringEmailApp.unreadClicked()

          afterEach ->
            @setSeenStub.restore()

          it "sets the email thread to unread", ->
            expect(@setSeenStub).toHaveBeenCalledWith(false)

      describe "#listViewBottomReached", ->
        beforeEach ->
          TuringEmailApp.collections.emailThreads.reset(
            _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
            (emailThread) => emailThread.toJSON()
            )
          )

          @hasNextPageStub = sinon.stub(TuringEmailApp.collections.emailThreads, "hasNextPage")

          @selectedEmailFolderIDStub = sinon.stub(TuringEmailApp, "selectedEmailFolderID")
          @folderID = "test"
          @selectedEmailFolderIDStub.returns(@folderID)

          @navigateStub = sinon.stub(TuringEmailApp.routers.emailFoldersRouter, "navigate")

        afterEach ->
          @hasNextPageStub.restore()
          @selectedEmailFolderIDStub.restore()
          @navigateStub.restore()

        describe "has a next page", ->
          beforeEach ->
            @hasNextPageStub.returns(true)

          describe "demoMode=true", ->
            beforeEach ->
              TuringEmailApp.models.userConfiguration.set("demo_mode_enabled", true)
              TuringEmailApp.listViewBottomReached()

            it "goes to the next page", ->
              url = "#email_folder/" + @folderID +
                    "/" + (TuringEmailApp.collections.emailThreads.pageTokenIndex + 1) +
                    "/" + TuringEmailApp.collections.emailThreads.last().get("uid") +
                    "/DESC"
              expect(@navigateStub).toHaveBeenCalledWith(url, trigger: true)

          describe "demoMode=false", ->
            beforeEach ->
              TuringEmailApp.models.userConfiguration.set("demo_mode_enabled", false)
              TuringEmailApp.listViewBottomReached()

            it "goes to the next page", ->
              url = "#email_folder/" + @folderID +
                    "/" + (TuringEmailApp.collections.emailThreads.pageTokenIndex + 1)
              expect(@navigateStub).toHaveBeenCalledWith(url, trigger: true)

        describe "does NOT have a next page", ->
          beforeEach ->
            @hasNextPageStub.returns(false)
            TuringEmailApp.listViewBottomReached()

          it "does NOT go to the next page", ->
            expect(@navigateStub).not.toHaveBeenCalled()

      describe "#readClickedIs", ->
        beforeEach ->
          @server.restore()
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = @emailThreads.models[0]

        afterEach ->
          @listViewDiv.remove()

        describe "when an email thread is selected", ->
          beforeEach ->
            @setStub = sinon.stub(@emailThread, "set")

            @listView.select(@emailThread)

            @isRead = true
            TuringEmailApp.readClickedIs(@isRead)

          afterEach ->
            @setStub.restore()

          it "sets the seen to the read", ->
            expect(@setStub).toHaveBeenCalledWith("seen", @isRead)

        describe "when an email thread is checked", ->
          beforeEach ->
            @setStub = sinon.stub(@emailThread, "set")

            @listView.check(@emailThread)

            @isRead = true
            TuringEmailApp.readClickedIs(@isRead)

          afterEach ->
            @setStub.restore()

          it "sets the seen to the read", ->
            expect(@setStub).toHaveBeenCalledWith("seen", @isRead)


      describe "#labelAsClicked", ->
        beforeEach ->
          @server.restore()
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = @emailThreads.models[0]

        afterEach ->
          @listViewDiv.remove()

        describe "when an email thread is selected", ->
          beforeEach ->
            @applyGmailLabelStub = sinon.stub(@emailThread, "applyGmailLabel")

            @listView.select(@emailThread)

            @labelID = "test"
            TuringEmailApp.labelAsClicked(@labelID)

          afterEach ->
            @applyGmailLabelStub.restore()

          it "applies the label to the selected email thread", ->
            expect(@applyGmailLabelStub).toHaveBeenCalledWith(@labelID)

        describe "when an email thread is checked", ->
          beforeEach ->
            @applyGmailLabelStub = sinon.stub(TuringEmailApp.Models.EmailThread, "applyGmailLabel")

            @listView.check(@emailThread)

            @labelID = "test"
            TuringEmailApp.labelAsClicked(@labelID)

          afterEach ->
            @applyGmailLabelStub.restore()

          it "applies the label to the checked email threads", ->
            expect(@applyGmailLabelStub).toHaveBeenCalledWith(TuringEmailApp, [@emailThread.get("uid")], @labelID)

      describe "#moveToFolderClicked", ->
        beforeEach ->
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = @emailThreads.models[0]

        afterEach ->
          @listViewDiv.remove()

        describe "when an email thread is selected", ->
          beforeEach ->
            @moveToFolderStub = sinon.stub(@emailThread, "moveToFolder")

            @listView.select(@emailThread)

            @folderID = "test"
            TuringEmailApp.moveToFolderClicked(@folderID)

          afterEach ->
            @moveToFolderStub.restore()

          it "moves the selected email thread to the folder", ->
            expect(@moveToFolderStub).toHaveBeenCalledWith(@folderID)

        describe "when an email thread is checked", ->
          beforeEach ->
            @moveToFolderStub = sinon.stub(@emailThread, "moveToFolder")

            @listView.check(@emailThread)

            @folderID = "test"
            TuringEmailApp.moveToFolderClicked(@folderID)

          afterEach ->
            @moveToFolderStub.restore()

          it "moves the checked email threads to the folder", ->
            expect(@moveToFolderStub).toHaveBeenCalledWith(@folderID)

      describe "#refreshClicked", ->

        it "reloads the email threads", ->
          spy = sinon.spy(TuringEmailApp, "reloadEmailThreads")
          TuringEmailApp.refreshClicked()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "#pauseClicked", ->

        it "clears the sync timeout", ->
          TuringEmailApp.pauseClicked()
          expect(TuringEmailApp.syncTimeout is null).toBeTruthy()

        it "show the pause alert", ->
          spy = sinon.spy(TuringEmailApp, "showAlert")
          TuringEmailApp.pauseClicked()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "#searchClicked", ->

        it "navigates to perform the search with the query", ->
          seededChance = new Chance(1)
          randomSearchQuery = seededChance.string({length: 10})
          spy = sinon.spy(TuringEmailApp.routers.searchResultsRouter, "navigate")
          TuringEmailApp.searchClicked(randomSearchQuery)
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith("#search/" + randomSearchQuery)
          spy.restore()

      describe "#goBackClicked", ->
        beforeEach ->
          @selectedEmailFolderIDFunction = TuringEmailApp.selectedEmailFolderID
          TuringEmailApp.selectedEmailFolderID = -> return "test"

        afterEach ->
          TuringEmailApp.selectedEmailFolderID = @selectedEmailFolderIDFunction

        it "shows the selected email folder", ->
          spy = sinon.spy(TuringEmailApp.routers.emailFoldersRouter, "showFolder")
          TuringEmailApp.goBackClicked()
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith("test")
          spy.restore()

      describe "#responseClicked", ->
        beforeEach ->
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = _.values(@listView.listItemViews)[0].model

          @responseType = "test"

          @showEmailEditorWithEmailThreadStub = sinon.stub(TuringEmailApp, "showEmailEditorWithEmailThread", ->)

        afterEach ->
          @showEmailEditorWithEmailThreadStub.restore()

        describe "with the selected email threads", ->
          beforeEach ->
            TuringEmailApp.views.emailThreadsListView.select @emailThread

          it "shows the email editor with the selected email thread", ->
            TuringEmailApp.responseClicked(@responseType)
            expect(@showEmailEditorWithEmailThreadStub).toHaveBeenCalledWith(@emailThread.get("uid"), @responseType)

        describe "with no selected email threads", ->
          it "returns false", ->
            expect( TuringEmailApp.responseClicked(@responseType) ).toBe(false)

      describe "#replyClicked", ->
        beforeEach ->
          @responseClickedStub = sinon.stub(TuringEmailApp, "responseClicked")
          TuringEmailApp.replyClicked()

        afterEach ->
          @responseClickedStub.restore()

        it "calls @responseClicked with the reply", ->
          expect(@responseClickedStub).toHaveBeenCalledWith("reply")

      describe "#replyToAllClicked", ->
        beforeEach ->
          @responseClickedStub = sinon.stub(TuringEmailApp, "responseClicked")
          TuringEmailApp.replyClicked()

        afterEach ->
          @responseClickedStub.restore()

        it "calls @responseClicked with the reply-to-all", ->
          expect(@responseClickedStub).toHaveBeenCalled

      describe "#forwardClicked", ->
        beforeEach ->
          @responseClickedStub = sinon.stub(TuringEmailApp, "responseClicked")
          TuringEmailApp.replyClicked()

        afterEach ->
          @responseClickedStub.restore()

        it "calls @responseClicked with the forward", ->
          expect(@responseClickedStub).toHaveBeenCalled

      describe "#archiveClicked", ->
        beforeEach ->
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = @emailThreads.models[0]

          @origSelectedEmailFolderID = TuringEmailApp.selectedEmailFolderID
          @folderID = "test"
          TuringEmailApp.selectedEmailFolderID = => @folderID

        afterEach ->
          TuringEmailApp.selectedEmailFolderID = => @origSelectedEmailFolderID
          @listViewDiv.remove()

        describe "when an email thread is selected", ->
          beforeEach ->
            @removeFromFolderStub = sinon.stub(@emailThread, "removeFromFolder")

            @listView.select(@emailThread)

            @folderID = "test"
            TuringEmailApp.archiveClicked(@folderID)

          afterEach ->
            @removeFromFolderStub.restore()

          it "remove the selected email thread from the selected folder", ->
            expect(@removeFromFolderStub).toHaveBeenCalledWith(@folderID)

        describe "when an email thread is checked", ->
          beforeEach ->
            @removeFromFolderStub = sinon.stub(TuringEmailApp.Models.EmailThread, "removeFromFolder")

            @listView.check(@emailThread)

            @folderID = "test"
            TuringEmailApp.archiveClicked()

          afterEach ->
            @removeFromFolderStub.restore()

          it "removed the checked email threads from the selected folder", ->
            expect(@removeFromFolderStub).toHaveBeenCalledWith(TuringEmailApp, [@emailThread.get("uid")], @folderID)

      describe "#trashClicked", ->
        beforeEach ->
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = @emailThreads.models[0]

        afterEach ->
          @listViewDiv.remove()

        describe "when an email thread is selected", ->
          beforeEach ->
            @trashStub = sinon.stub(@emailThread, "trash")

            @listView.select(@emailThread)

            TuringEmailApp.trashClicked()

          afterEach ->
            @trashStub.restore()

          it "trash the selected email", ->
            expect(@trashStub).toHaveBeenCalled()

        describe "when an email thread is checked", ->
          beforeEach ->
            @trashStub = sinon.stub(TuringEmailApp.Models.EmailThread, "trash")

            @listView.check(@emailThread)

            TuringEmailApp.trashClicked()

          afterEach ->
            @trashStub.restore()

          it "trash the checked email threads", ->
            expect(@trashStub).toHaveBeenCalledWith(TuringEmailApp, [@emailThread.get("uid")])

      describe "#snoozeClicked", ->
        beforeEach ->
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = @emailThreads.models[0]

        afterEach ->
          @listViewDiv.remove()

        describe "when an email thread is selected", ->
          beforeEach ->
            @snoozeStub = sinon.stub(@emailThread, "snooze")

            @listView.select(@emailThread)

            TuringEmailApp.snoozeClicked(60)

          afterEach ->
            @snoozeStub.restore()

          it "snooze the selected email", ->
            expect(@snoozeStub).toHaveBeenCalled()

        describe "when an email thread is checked", ->
          beforeEach ->
            @snoozeStub = sinon.stub(TuringEmailApp.Models.EmailThread, "snooze")

            @listView.check(@emailThread)

            TuringEmailApp.snoozeClicked(60)

          afterEach ->
            @snoozeStub.restore()

          it "snooze the checked email threads", ->
            expect(@snoozeStub).toHaveBeenCalledWith(TuringEmailApp, [@emailThread.get("uid")])

      describe "#createNewLabelClicked", ->
        beforeEach ->
          @showStub = sinon.stub(TuringEmailApp.views.createFolderView, "show")

          TuringEmailApp.createNewLabelClicked()

        afterEach ->
          @showStub.restore()

        it "shows the create label view", ->
          expect(@showStub).toHaveBeenCalledWith("label")

      describe "#createNewEmailFolderClicked", ->
        beforeEach ->
          @showStub = sinon.stub(TuringEmailApp.views.createFolderView, "show")

          TuringEmailApp.createNewEmailFolderClicked()

        afterEach ->
          @showStub.restore()

        it "shows the create folder view", ->
          expect(@showStub).toHaveBeenCalledWith("folder")

      describe "#demoModeSwitchClicked", ->
        beforeEach ->
          @token = {}

          @setStub = sinon.stub(TuringEmailApp.models.userConfiguration, "set")
          @showAlertStub = sinon.stub(TuringEmailApp, "showAlert", => @token)
          @saveStub = sinon.stub(TuringEmailApp.models.userConfiguration, "save")

          TuringEmailApp.demoModeSwitchClicked(true)

        afterEach ->
          @setStub.restore()
          @showAlertStub.restore()
          @saveStub.restore()

        it "updates demo_mode_enabled", ->
          expect(@setStub).toHaveBeenCalledWith("demo_mode_enabled", true)

        it "shows the changing alert", ->
          expect(@showAlertStub).toHaveBeenCalledWith("Changing mode... just a minute please", "alert-success")

        it "saves with patch", ->
          expect(@saveStub.args[0][1].patch).toBeTruthy()

        describe "on success", ->
          beforeEach ->
            @clock = sinon.useFakeTimers()
            @removeAlertStub = sinon.stub(TuringEmailApp, "removeAlert", ->)

            @showAlertStub.restore()
            @showAlertStub = sinon.stub(TuringEmailApp, "showAlert", => @token)

            @saveStub.args[0][1].success()

          afterEach ->
            @clock.restore()
            @removeAlertStub.restore()

          it "shows the alert", ->
            expect(@showAlertStub).toHaveBeenCalled()

          it "removes the alert after 15 seconds", ->
            expect(@showAlertStub).toHaveBeenCalledWith("You are now viewing Turing mode - look how few emails there are!", "alert-success", 15000)

      describe "#installAppClicked", ->
        beforeEach ->
          @installStub = sinon.stub(TuringEmailApp.Models.App, "Install")
          @userConfigurationFetchStub = sinon.stub(TuringEmailApp.models.userConfiguration, "fetch")

          @appID = "1"
          TuringEmailApp.installAppClicked(undefined, @appID)

        afterEach ->
          @userConfigurationFetchStub.restore()
          @installStub.restore()

        it "installs the app", ->
          expect(@installStub).toHaveBeenCalledWith(@appID)

        it "refreshes the user settings", ->
          expect(@userConfigurationFetchStub).toHaveBeenCalledWith(reset: true)

      describe "#uninstallAppClicked", ->
        beforeEach ->
          @uninstallStub = sinon.stub(TuringEmailApp.Models.InstalledApps.InstalledApp, "Uninstall")
          @userConfigurationFetchStub = sinon.stub(TuringEmailApp.models.userConfiguration, "fetch")

          @appID = "1"
          TuringEmailApp.uninstallAppClicked(undefined, @appID)

        afterEach ->
          @userConfigurationFetchStub.restore()
          @uninstallStub.restore()

        it "installs the app", ->
          expect(@uninstallStub).toHaveBeenCalledWith(@appID)

        it "refreshes the user settings", ->
          expect(@userConfigurationFetchStub).toHaveBeenCalledWith(reset: true)

      describe "#unsubscribeListClicked", ->
        beforeEach ->
          @unsubscribeStub = sinon.stub(TuringEmailApp.Models.ListSubscription, "Unsubscribe", ->)

          @listSubscription =
            set: sinon.stub()

          @view =
            collection:
              remove: sinon.stub()
              add: sinon.stub()

          TuringEmailApp.unsubscribeListClicked(@view, @listSubscription)

        afterEach ->
          @unsubscribeStub.restore()

        it "unsubscribes the delayed email", ->
          expect(@unsubscribeStub).toHaveBeenCalledWith(@listSubscription)

        it "removes the delayed email from the collection", ->
          expect(@view.collection.remove).toHaveBeenCalledWith(@listSubscription)

        it "updates the unsubscribed property", ->
          expect(@listSubscription.set).toHaveBeenCalledWith("unsubscribed", true)

        it "adds the delayed email to the collection", ->
          expect(@view.collection.add).toHaveBeenCalledWith(@listSubscription)

      describe "#resubscribeListClicked", ->
        beforeEach ->
          @resubscribeStub = sinon.stub(TuringEmailApp.Models.ListSubscription, "Resubscribe", ->)

          @listSubscription =
            set: sinon.stub()

          @view =
            collection:
              remove: sinon.stub()
              add: sinon.stub()

          TuringEmailApp.resubscribeListClicked(@view, @listSubscription)

        afterEach ->
          @resubscribeStub.restore()

        it "resubscribes the delayed email", ->
          expect(@resubscribeStub).toHaveBeenCalledWith(@listSubscription)

        it "removes the delayed email from the collection", ->
          expect(@view.collection.remove).toHaveBeenCalledWith(@listSubscription)

        it "updates the unsubscribed property", ->
          expect(@listSubscription.set).toHaveBeenCalledWith("unsubscribed", false)

        it "adds the delayed email to the collection", ->
          expect(@view.collection.add).toHaveBeenCalledWith(@listSubscription)

    describe "#listItemSelected", ->
      beforeEach ->
        @listView = specCreateEmailThreadsListView()
        @listViewDiv = @listView.$el
        @emailThreads = @listView.collection

        TuringEmailApp.views.emailThreadsListView = @listView
        TuringEmailApp.collections.emailThreads = @emailThreads

        @listItemView = _.values(@listView.listItemViews)[0]

        @emailThreadUID = @listItemView.model.get("uid")

        @navigateStub = sinon.stub(TuringEmailApp.routers.emailThreadsRouter, "navigate")

      afterEach ->
        @listViewDiv.remove()
        @navigateStub.restore()

      it "navigates to the email thread", ->
        TuringEmailApp.listItemSelected @listView, @listItemView

        expect(@navigateStub).toHaveBeenCalledWith("#email_thread/" +  @emailThreadUID)

    describe "#listItemDeselected", ->
      it "navigates to the email thread url", ->
        spy = sinon.spy(TuringEmailApp.routers.emailThreadsRouter, "navigate")
        TuringEmailApp.listItemDeselected null, null
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith("#email_thread/.")
        spy.restore()

    describe "#listItemChecked", ->

      beforeEach ->
        TuringEmailApp.collections.emailThreads.reset(
          _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
            (emailThread) => emailThread.toJSON()
          )
        )
        emailThread = TuringEmailApp.collections.emailThreads.at(0)
        @setStub = sinon.stub(emailThread, "set")
        TuringEmailApp.showEmailThread emailThread

      afterEach ->
        @setStub.restore()

      it "hides the current email thread view.", ->
        spy = sinon.spy(TuringEmailApp.currentEmailThreadView.$el, "hide")
        TuringEmailApp.listItemChecked null, null
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "#listItemUnchecked", ->

      describe "when there is a current email thread view", ->
        beforeEach ->
          TuringEmailApp.collections.emailThreads.reset(
            _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
              (emailThread) => emailThread.toJSON()
            )
          )
          emailThread = TuringEmailApp.collections.emailThreads.at(0)
          @setStub = sinon.stub(emailThread, "set")
          TuringEmailApp.showEmailThread emailThread

        afterEach ->
          @setStub.restore()

        describe "when the number of check list items is not 0", ->

          beforeEach ->
            @getCheckedListItemViewsFunction = TuringEmailApp.getCheckedListItemViews
            TuringEmailApp.views.emailThreadsListView.getCheckedListItemViews = -> return {"length" : 1}

          afterEach ->
            TuringEmailApp.getCheckedListItemViews = @getCheckedListItemViewsFunction

          it "does not shows the current email thread view", ->
            spy = sinon.spy(TuringEmailApp.currentEmailThreadView.$el, "show")
            TuringEmailApp.listItemUnchecked null, null
            expect(spy).not.toHaveBeenCalled()
            spy.restore()

        describe "when the number of check list items is 0 and there is a current email thread view", ->

          beforeEach ->
            @getCheckedListItemViewsFunction = TuringEmailApp.getCheckedListItemViews
            TuringEmailApp.views.emailThreadsListView.getCheckedListItemViews = -> return {"length" : 0}

          afterEach ->
            TuringEmailApp.getCheckedListItemViews = @getCheckedListItemViewsFunction

          it "shows the current email thread view", ->
            spy = sinon.spy(TuringEmailApp.currentEmailThreadView.$el, "show")
            TuringEmailApp.listItemUnchecked null, null
            expect(spy).toHaveBeenCalled()
            spy.restore()

    describe "#emailFolderSelected", ->

      describe "when the email folder is defined", ->
        beforeEach ->
          @emailFolder = new TuringEmailApp.Models.EmailFolder()

        describe "when the window location is already set to show the email folder page", ->
          beforeEach ->
            TuringEmailApp.routers.emailThreadsRouter.navigate("#email_folder/INBOX", trigger: true)
            @emailFolder.set("label_id", "INBOX")

          it "navigates to the email folder url", ->
            spy = sinon.spy(TuringEmailApp.routers.emailFoldersRouter, "showFolder")
            TuringEmailApp.emailFolderSelected null, @emailFolder
            expect(spy).toHaveBeenCalledWith(@emailFolder.get("label_id"))
            spy.restore()

        describe "when the window location is not already set to show the email folder page", ->
          beforeEach ->
            @emailFolder.set("label_id", "Label_45")

          it "navigates to the email folder url", ->
            spy = sinon.spy(TuringEmailApp.routers.emailFoldersRouter, "navigate")
            TuringEmailApp.emailFolderSelected null, @emailFolder
            expect(spy).toHaveBeenCalledWith("#email_folder/" + @emailFolder.get("label_id"))
            spy.restore()

    describe "#draftChanged", ->
      beforeEach ->
        @selectedEmailFolderIDStub = sinon.stub(TuringEmailApp, "selectedEmailFolderID")
        @selectedEmailFolderIDStub.returns("INBOX")

        @reloadEmailThreadsStub = sinon.stub(TuringEmailApp, "reloadEmailThreads")
        @loadEmailFoldersStub = sinon.stub(TuringEmailApp, "loadEmailFolders")

        @draft = new TuringEmailApp.Models.EmailDraft()

        TuringEmailApp.collections.emailThreads.reset(
          _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
            (emailThread) => emailThread.toJSON()
          )
        )
        @emailThreadParent = TuringEmailApp.collections.emailThreads.at(0)

        @setStub = sinon.stub(@emailThreadParent, "set", ->)
        TuringEmailApp.draftChanged(TuringEmailApp.views.composeView, @draft, @emailThreadParent)

      afterEach ->
        @selectedEmailFolderIDStub.restore()
        @reloadEmailThreadsStub.restore()
        @loadEmailFoldersStub.restore()
        @setStub.restore()

      it "reloads the email threads", ->
        expect(@reloadEmailThreadsStub).toHaveBeenCalled()

      it "reloads the email folders", ->
        expect(@loadEmailFoldersStub).toHaveBeenCalled()

      it "updates the emailThreadParent", ->
        expect(@setStub).toHaveBeenCalledWith("emails")

    describe "#createFolderFormSubmitted", ->
      beforeEach ->
        seededChance = new Chance(1)
        @randomFolderName = seededChance.string({length: 20})

      describe "when the mode is label", ->

        it "calls labels as clicked with the label name", ->
          spy = sinon.spy(TuringEmailApp, "labelAsClicked")
          TuringEmailApp.createFolderFormSubmitted("label", @randomFolderName)
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(undefined, @randomFolderName)
          spy.restore()

      describe "when the mode is folder", ->

        it "calls move to folder clicked with the folder name", ->
          spy = sinon.spy(TuringEmailApp, "moveToFolderClicked")
          TuringEmailApp.createFolderFormSubmitted("folder", @randomFolderName)
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(undefined, @randomFolderName)
          spy.restore()

    describe "#emailThreadSeenChanged", ->
      beforeEach ->
        TuringEmailApp.collections.emailThreads.reset(
          _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
            (emailThread) => emailThread.toJSON()
          )
        )
        TuringEmailApp.collections.emailFolders.reset(FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE))

        @selectedEmailFolderIDStub = sinon.stub(TuringEmailApp, "selectedEmailFolderID")
        @selectedEmailFolderIDStub.returns("INBOX")

        @emailThread = TuringEmailApp.collections.emailThreads.at(0)
        @emailThread.set("folder_ids", [TuringEmailApp.collections.emailFolders.at(0).get("label_id")])

        folderIDs = @emailThread.get("folder_ids")
        expect(folderIDs.length > 0).toBeTruthy()

        @unreadCounts = {}
        for folderID in @emailThread.get("folder_ids")
          folder = TuringEmailApp.collections.emailFolders.get(folderID)
          @unreadCounts[folderID] = folder.get("num_unread_threads")

      afterEach ->
        @selectedEmailFolderIDStub.restore()

      it "triggers a change:emailFolderUnreadCount event", ->
        spy = sinon.backbone.spy(TuringEmailApp, "change:emailFolderUnreadCount")

        TuringEmailApp.emailThreadSeenChanged @emailThread, true

        for folderID in @emailThread.get("folder_ids")
          folder = TuringEmailApp.collections.emailFolders.get(folderID)
          expect(spy).toHaveBeenCalledWith(TuringEmailApp, folder)

        spy.restore()

      describe "seenValue=true", ->
        beforeEach ->
          TuringEmailApp.emailThreadSeenChanged @emailThread, true

        it "decrements the unread count", ->
          for folderID in @emailThread.get("folder_ids")
            folder = TuringEmailApp.collections.emailFolders.get(folderID)
            expect(folder.get("num_unread_threads")).toEqual(@unreadCounts[folderID] - 1)

      describe "seenValue=false", ->
        beforeEach ->
          TuringEmailApp.emailThreadSeenChanged @emailThread, false

        it "increments the unread count", ->
          for folderID in @emailThread.get("folder_ids")
            folder = TuringEmailApp.collections.emailFolders.get(folderID)
            expect(folder.get("num_unread_threads")).toEqual(@unreadCounts[folderID] + 1)

    describe "#emailThreadFolderChanged", ->

      describe "when the folder is not already in the collection", ->
        beforeEach ->
          @getStub = sinon.stub(TuringEmailApp.collections.emailFolders, "get")
          @getStub.returns(null)

        afterEach ->
          @getStub.restore()

        it "it reloads the email folders", ->
          spy = sinon.spy(TuringEmailApp, "loadEmailFolders")
          TuringEmailApp.emailThreadFolderChanged undefined, {"label_id" : "INBOX"}
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when the folder is already in the collection", ->
        beforeEach ->
          @getStub = sinon.stub(TuringEmailApp.collections.emailFolders, "get")
          @getStub.returns({})

        afterEach ->
          @getStub.restore()

        it "it reloads the email folders", ->
          spy = sinon.spy(TuringEmailApp, "loadEmailFolders")
          TuringEmailApp.emailThreadFolderChanged undefined, {"label_id" : "INBOX"}
          expect(spy).not.toHaveBeenCalled()
          spy.restore()

    describe "#isSplitPaneMode", ->
      beforeEach ->
        TuringEmailApp.models.userConfiguration = new TuringEmailApp.Models.UserConfiguration(FactoryGirl.create("UserConfiguration"))

      describe "when split pane mode is horizontal in the user settings", ->
        beforeEach ->
          TuringEmailApp.models.userConfiguration.attributes.split_pane_mode = "horizontal"

        it "should return true", ->
          expect(TuringEmailApp.isSplitPaneMode()).toBeTruthy()

      describe "when split pane mode is vertical in the user settings", ->
        beforeEach ->
          TuringEmailApp.models.userConfiguration.attributes.split_pane_mode = "vertical"

        it "should return true", ->
          expect(TuringEmailApp.isSplitPaneMode()).toBeTruthy()

      describe "when split pane mode is off in the user settings", ->
        beforeEach ->
          TuringEmailApp.models.userConfiguration.attributes.split_pane_mode = "off"

        it "should return false", ->
          expect(TuringEmailApp.isSplitPaneMode()).toBeFalsy()

    describe "#showEmailThread", ->
      beforeEach ->
        TuringEmailApp.collections.emailThreads.reset(
          _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
            (emailThread) => emailThread.toJSON()
          )
        )
        @emailThread = TuringEmailApp.collections.emailThreads.at(0)

        @setStub = sinon.stub(@emailThread, "set")
        @eventSpy = null

      afterEach ->
        @eventSpy.restore() if @eventSpy?
        @setStub.restore()

      emailThreadViewEvents = ["goBackClicked", "replyClicked", "replyToAllClicked", "forwardClicked", "archiveClicked", "trashClicked"]
      for event in emailThreadViewEvents
        it "hooks the emailThreadView " + event + " event", ->
          @eventSpy = sinon.spy(TuringEmailApp, event)

          TuringEmailApp.showEmailThread(@emailThread)
          TuringEmailApp.currentEmailThreadView.trigger(event)

          expect(@eventSpy).toHaveBeenCalled()

      describe "when the current email Thread is not null", ->
        beforeEach ->
          TuringEmailApp.showEmailThread(@emailThread)
          @appSpy = sinon.spy(TuringEmailApp, "stopListening")
          @viewSpy = sinon.spy(TuringEmailApp.currentEmailThreadView, "stopListening")

        afterEach ->
          @appSpy.restore()
          @viewSpy.restore()

        it "stops listening to the current email thread view", ->
          TuringEmailApp.showEmailThread(@emailThread)
          expect(@appSpy).toHaveBeenCalled()
          expect(@viewSpy).toHaveBeenCalled()

    describe "#showEmailEditorWithEmailThread", ->
      beforeEach ->
        TuringEmailApp.collections.emailThreads.reset(
          _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
            (emailThread) => emailThread.toJSON()
          )
        )

        @emailThread = TuringEmailApp.collections.emailThreads.at(0)
        @setStub = sinon.stub(@emailThread, "set")

        @email = _.last(@emailThread.get("emails"))

      afterEach ->
        @setStub.restore()

      it "loads the email thread", ->
        spy = sinon.spy(TuringEmailApp, "loadEmailThread")
        TuringEmailApp.showEmailEditorWithEmailThread @emailThread.get("uid")
        expect(spy).toHaveBeenCalledWith(@emailThread.get("uid"))
        spy.restore()

      it "shows the compose view", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "show")
        TuringEmailApp.showEmailEditorWithEmailThread @emailThread.get("uid")
        expect(spy).toHaveBeenCalled()
        spy.restore()

      describe "when in draft mode", ->

        it "loads the email draft", ->
          spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailDraft")
          TuringEmailApp.showEmailEditorWithEmailThread @emailThread.get("uid")
          expect(spy).toHaveBeenCalledWith(@email, @emailThread)
          spy.restore()

      describe "when in forward mode", ->

        it "loads the email as a forward", ->
          spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailAsForward")
          TuringEmailApp.showEmailEditorWithEmailThread @emailThread.get("uid"), "forward"
          expect(spy).toHaveBeenCalledWith(@email, @emailThread)
          spy.restore()

      describe "when in reply mode", ->

        it "loads the email as a reply", ->
          spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailAsReply")
          TuringEmailApp.showEmailEditorWithEmailThread @emailThread.get("uid"), "reply"
          expect(spy).toHaveBeenCalledWith(@email, @emailThread)
          spy.restore()

      describe "when in reply-to-all mode", ->

        it "loads the email as a reply-to-all", ->
          spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailAsReplyToAll")
          TuringEmailApp.showEmailEditorWithEmailThread @emailThread.get("uid"), "reply-to-all"
          expect(spy).toHaveBeenCalledWith(@email, @emailThread)
          spy.restore()

    describe "#showEmails", ->
      beforeEach ->
        @showEmailsSpy = sinon.spy(TuringEmailApp.views.mainView, "showEmails")

        TuringEmailApp.showEmails()

      afterEach ->
        @showEmailsSpy.restore()

      it "shows the emails on the main view", ->
        expect(@showEmailsSpy).toHaveBeenCalledWith(TuringEmailApp.isSplitPaneMode())

    describe "#showAppsLibrary", ->
      beforeEach ->
        @oldAppsLibraryView = TuringEmailApp.appsLibraryView = {}

        @appsLibraryView = {}
        @showAppsLibraryStub = sinon.stub(TuringEmailApp.views.mainView, "showAppsLibrary", => @appsLibraryView)
        @listenToStub = sinon.stub(TuringEmailApp, "listenTo", ->)
        @stopListeningStub = sinon.stub(TuringEmailApp, "stopListening", ->)

        TuringEmailApp.showAppsLibrary()

      afterEach ->
        @stopListeningStub.restore()
        @listenToStub.restore()
        @showAppsLibraryStub.restore()

      it "shows the apps library on the main view", ->
        expect(@showAppsLibraryStub).toHaveBeenCalled()

      it "stops listening on the old apps library view", ->
        expect(@stopListeningStub).toHaveBeenCalledWith(@oldAppsLibraryView)

      it "listens for installAppClicked on the apps library view", ->
        expect(@listenToStub).toHaveBeenCalledWith(@appsLibraryView, "installAppClicked", TuringEmailApp.installAppClicked)

    describe "#showScheduleEmails", ->
      beforeEach ->
        @showScheduleEmailsStub = sinon.stub(TuringEmailApp.views.mainView, "showScheduleEmails", =>)

        TuringEmailApp.showScheduleEmails()

      afterEach ->
        @showScheduleEmailsStub.restore()

      it "shows the delayed emails on the main view", ->
        expect(@showScheduleEmailsStub).toHaveBeenCalled()

    describe "#showEmailTrackers", ->
      beforeEach ->
        @emailTrackersView = {}
        @showEmailTrackersStub = sinon.stub(TuringEmailApp.views.mainView, "showEmailTrackers", => @emailTrackersView)

        TuringEmailApp.showEmailTrackers()

      afterEach ->
        @showEmailTrackersStub.restore()

      it "shows the email trackers on the main view", ->
        expect(@showEmailTrackersStub).toHaveBeenCalled()

    describe "#showListSubscriptions", ->
      beforeEach ->
        @oldListSubscriptionsView = TuringEmailApp.listSubscriptionsView = {}

        @listSubscriptionsView = {}
        @showListSubscriptionsStub = sinon.stub(TuringEmailApp.views.mainView, "showListSubscriptions", => @listSubscriptionsView)
        @listenToStub = sinon.stub(TuringEmailApp, "listenTo", ->)
        @stopListeningStub = sinon.stub(TuringEmailApp, "stopListening", ->)

        TuringEmailApp.showListSubscriptions()

      afterEach ->
        @stopListeningStub.restore()
        @listenToStub.restore()
        @showListSubscriptionsStub.restore()

      it "shows the list subscriptions on the main view", ->
        expect(@showListSubscriptionsStub).toHaveBeenCalled()

      it "stops listening on the old list subscriptions view", ->
        expect(@stopListeningStub).toHaveBeenCalledWith(@oldListSubscriptionsView)

      it "listens for unsubscribeListClicked on the list subscriptions view", ->
        expect(@listenToStub).toHaveBeenCalledWith(@listSubscriptionsView, "unsubscribeListClicked", TuringEmailApp.unsubscribeListClicked)

      it "listens for resubscribeListClicked on the list subscriptions view", ->
        expect(@listenToStub).toHaveBeenCalledWith(@listSubscriptionsView, "resubscribeListClicked", TuringEmailApp.resubscribeListClicked)

    describe "#showInboxCleaner", ->
      beforeEach ->
        @oldInboxCleanerView = TuringEmailApp.inboxCleanerView = {}

        @inboxCleanerView = {}
        @showInboxCleanerViewStub = sinon.stub(TuringEmailApp.views.mainView, "showInboxCleaner", => @inboxCleanerView)

        TuringEmailApp.showInboxCleaner()

      afterEach ->
        @showInboxCleanerViewStub.restore()

      it "shows the list subscriptions on the main view", ->
        expect(@showInboxCleanerViewStub).toHaveBeenCalled()

    describe "#showWelcomeTour", ->
      beforeEach ->
        @showEmailsStub = sinon.stub(TuringEmailApp, "showEmails", ->)
        @showWelcomeTourViewStub = sinon.stub(TuringEmailApp.views.mainView, "showWelcomeTour", => @welcomeTourView)

        TuringEmailApp.showWelcomeTour()

      afterEach ->
        @showEmailsStub.restore()
        @showWelcomeTourViewStub.restore()

      it "shows the emails", ->
        expect(@showEmailsStub).toHaveBeenCalled()

      it "shows the welcome tour on the main view", ->
        expect(@showWelcomeTourViewStub).toHaveBeenCalled()

    describe "#showSettings", ->
      beforeEach ->
        @oldSettingsView = TuringEmailApp.settingsView = {}

        @settingsView = {}
        @showSettingsStub = sinon.stub(TuringEmailApp.views.mainView, "showSettings", => @settingsView)
        @listenToStub = sinon.stub(TuringEmailApp, "listenTo", ->)
        @stopListeningStub = sinon.stub(TuringEmailApp, "stopListening", ->)

        @server.restore()

        @server = sinon.fakeServer.create()

        userConfigurationData = FactoryGirl.create("UserConfiguration")
        TuringEmailApp.models.userConfiguration = new TuringEmailApp.Models.UserConfiguration(userConfigurationData)

        TuringEmailApp.showSettings()

      afterEach ->
        @server.restore()

        @stopListeningStub.restore()
        @listenToStub.restore()
        @showSettingsStub.restore()

      it "shows the Settings on the main view", ->
        expect(@showSettingsStub).toHaveBeenCalled()
        @showSettingsStub.restore()

      it "stops listening on the old settings view", ->
        expect(@stopListeningStub).toHaveBeenCalledWith(@oldSettingsView)

      it "listens for uninstallAppClicked on the settings view", ->
        expect(@listenToStub).toHaveBeenCalledWith(@settingsView, "uninstallAppClicked", TuringEmailApp.uninstallAppClicked)

    describe "#showAnalytics", ->
      beforeEach ->
        @showAnalyticsSpy = sinon.spy(TuringEmailApp.views.mainView, "showAnalytics")

        TuringEmailApp.showAnalytics()

      afterEach ->
        @showAnalyticsSpy.restore()

      it "shows the Analytics on the main view", ->
        expect(@showAnalyticsSpy).toHaveBeenCalled()

    describe "#showReport", ->
      beforeEach ->
        @showReportSpy = sinon.spy(TuringEmailApp.views.mainView, "showReport")

        TuringEmailApp.showReport(TuringEmailApp.Models.Reports.AttachmentsReport,
                                  TuringEmailApp.Views.PrimaryPane.Analytics.Reports.AttachmentsReportView)

      afterEach ->
        @showReportSpy.restore()

      it "shows the Analytics on the main view", ->
        expect(@showReportSpy).toHaveBeenCalled()

    describe "#downloadFile", ->
      beforeEach ->
        @url = "#"
        TuringEmailApp.downloadFile(@url)

      afterEach ->
        TuringEmailApp.downloadIframe = undefined

      it "creates downloadIframe", ->
        expect( TuringEmailApp.downloadIframe ).not.toBe(undefined)

      it "hidden the downloadIframe", ->
        expect( TuringEmailApp.downloadIframe.hidden ).toBe(true)

      it "sets up the src of the downloadIframe with the url", ->
        src = TuringEmailApp.downloadIframe.src
        last_url = src[src.length-1]
        expect( last_url ).toEqual(@url)
