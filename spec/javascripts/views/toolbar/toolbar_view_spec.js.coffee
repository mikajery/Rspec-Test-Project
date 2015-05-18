describe "ToolbarView", ->
  beforeEach ->
    specStartTuringEmailApp()

    TuringEmailApp.collections.emailFolders.add(FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE))
    @toolbarView = TuringEmailApp.views.toolbarView

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@toolbarView.template).toEqual JST["backbone/templates/toolbar/toolbar"]

  describe "#initialize", ->

    it "adds a listener for change:currentEmailFolder that calls currentEmailFolderChanged", ->
      # TODO figure out how to test this, and then write tests for it.
      return

    it "adds a listener for change:emailFolders that calls emailFoldersChanged", ->
      # TODO figure out how to test this, and then write tests for it.
      return

  describe "after render", ->
    beforeEach ->
      @toolbarView.emailFoldersChanged(TuringEmailApp, TuringEmailApp.collections.emailFolders)
      @toolbarView.render()

    describe "#render", ->
      it "renders as a DIV", ->
        expect(@toolbarView.el.nodeName).toEqual "DIV"

      it "sets up the all checkbox", ->
        spy = sinon.spy(@toolbarView, "setupAllCheckbox")
        @toolbarView.render()
        expect(spy).toHaveBeenCalled()

      it "sets up the buttons", ->
        spy = sinon.spy(@toolbarView, "setupButtons")
        @toolbarView.render()
        expect(spy).toHaveBeenCalled()

      it "renders refresh button", ->
        stub = sinon.stub(@toolbarView, "renderRefreshButton")
        @toolbarView.render()
        expect(stub).toHaveBeenCalled()

      it "sets the select all checkbox element", ->
        expect(@toolbarView.divAllCheckbox).toEqual @toolbarView.$el.find("div.icheckbox")

      it "doesn't crash when there is an empty folders collection", ->
        TuringEmailApp.collections.emailFolders = null
        expect(@toolbarView.render()).toEqual @toolbarView

      it "renders the label as options in sorted order", ->
        labelAsUnorderedListElements = @toolbarView.$el.find(".label-as .dropdown-menu li")
        labelAsUnorderedListElements.each (index, labelAsUnorderedListElement) ->
          if index is not 0 or index is not labelAsUnorderedListElements.length - 1
            expect(labelAsUnorderedListElement.find("a").text() < labelAsUnorderedListElements[index - 1].find("a").text()).toBeTruthy()

      it "renders the move to options in sorted order", ->
        moveToUnorderedListElements = @toolbarView.$el.find(".move-to .dropdown-menu li")
        moveToUnorderedListElements.each (index, moveToUnorderedListElement) ->
          if index is not 0 or index is not moveToUnorderedListElements.length - 1
            expect(moveToUnorderedListElement.find("a").text() < moveToUnorderedListElements[index - 1].find("a").text()).toBeTruthy()

    describe "#setupAllCheckbox", ->

      it "sets up the all checkbox", ->
        iChecks = @toolbarView.$el.find("div.icheckbox")
        expect(iChecks).toHaveClass("icheckbox")
        expect(iChecks).toContain("input.i-checks")
        expect(iChecks).toContain("ins.iCheck-helper")

      it "should make the check all checkbox handle clicks", ->
        expect(@toolbarView.$el.find("div.icheckbox ins")).toHandle("click")

      describe "when the all checkbox element is clicked", ->

        describe "when the select all checkbox element is checked", ->
          beforeEach ->
            @toolbarView.divAllCheckbox.iCheck("uncheck")

          it "should trigger select all", ->
            spy = sinon.backbone.spy(@toolbarView, "checkAllClicked")
            @toolbarView.$el.find("div.icheckbox ins").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()

        describe "when the select all checkbox element is not checked", ->
          beforeEach ->
            @toolbarView.divAllCheckbox.iCheck("check")

          it "should trigger deselect all", ->
            spy = sinon.backbone.spy(@toolbarView, "uncheckAllClicked")
            @toolbarView.$el.find("div.icheckbox ins").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()

    describe "#renderRefreshButton", ->
      it "handles click", ->
        expect(@toolbarView.$el.find(".refresh-button")).toHandle("click")

      describe "when .refresh-button is clicked", ->
        it "triggers refreshClicked", ->
          @toolbarView.$el.find(".refresh-button").show()
          spy = sinon.backbone.spy(@toolbarView, "refreshClicked")
          @toolbarView.$el.find(".refresh-button").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

    describe "#setupButtons", ->
      beforeEach ->
        @setupSnoozeButtonsStub = sinon.stub(@toolbarView, "setupSnoozeButtons")

      afterEach ->
        @setupSnoozeButtonsStub.restore()

      it "should handle archive clicks", ->
        expect(@toolbarView.$el.find(".archive-button")).toHandle("click")

      it "should handle trash clicks", ->
        expect(@toolbarView.$el.find(".trash-button")).toHandle("click")

      it "should handle label as clicks", ->
        expect(@toolbarView.$el.find(".label_as_link")).toHandle("click")

      it "should handle move to folders clicks", ->
        expect(@toolbarView.$el.find(".move_to_folder_link")).toHandle("click")

      it "should handle mark as read clicks", ->
        expect(@toolbarView.$el.find(".mark_as_read")).toHandle("click")

      it "should handle mark as unread clicks", ->
        expect(@toolbarView.$el.find(".mark_as_unread")).toHandle("click")

      it "should handle pause clicks", ->
        expect(@toolbarView.$el.find(".pause-button")).toHandle("click")

      it "sets up bulk action buttons", ->
        spy = sinon.spy(@toolbarView, "setupBulkActionButtons")
        @toolbarView.setupButtons()
        expect(spy).toHaveBeenCalled()

      it "sets up snooze buttons", ->
        @toolbarView.setupButtons()
        expect(@setupSnoozeButtonsStub).toHaveBeenCalled()

      describe "when mark_as_read is clicked", ->
        it "triggers readClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "readClicked")
          @toolbarView.$el.find(".mark_as_read").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when mark_as_unread is clicked", ->
        it "triggers unreadClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "unreadClicked")
          @toolbarView.$el.find(".mark_as_unread").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when .archive-button is clicked", ->
        it "triggers archiveClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "archiveClicked")
          @toolbarView.$el.find(".archive-button").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when .trash-button is clicked", ->
        it "triggers trashClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "trashClicked")
          @toolbarView.$el.find(".trash-button").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when .label_as_link is clicked", ->
        it "triggers labelAsClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "labelAsClicked")
          @toolbarView.$el.find(".label_as_link").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when .move_to_folder_link is clicked", ->
        it "triggers moveToFolderClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "moveToFolderClicked")
          @toolbarView.$el.find(".move_to_folder_link").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when .pause-button is clicked", ->
        it "triggers pauseClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "pauseClicked")
          @toolbarView.$el.find(".pause-button").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

    describe "#setupBulkActionButtons", ->

      it "should handle clicks", ->
        expect(@toolbarView.$el.find(".all-bulk-action")).toHandle("click")
        expect(@toolbarView.$el.find(".none-bulk-action")).toHandle("click")
        expect(@toolbarView.$el.find(".read-bulk-action")).toHandle("click")
        expect(@toolbarView.$el.find(".unread-bulk-action")).toHandle("click")

      describe "when all-bulk-action is clicked", ->
        it "triggers checkAllClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "checkAllClicked")
          @toolbarView.$el.find(".all-bulk-action").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "checks the all checkbox", ->
          @toolbarView.$el.find(".all-bulk-action").click()
          expect(@toolbarView.allCheckboxIsChecked()).toBeTruthy()

      describe "when none-bulk-action is clicked", ->
        it "triggers uncheckAllClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "uncheckAllClicked")
          @toolbarView.$el.find(".none-bulk-action").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "unchecks the all checkbox", ->
          @toolbarView.$el.find(".none-bulk-action").click()
          expect(@toolbarView.allCheckboxIsChecked()).toBeFalsy()

      describe "when read-bulk-action is clicked", ->
        it "triggers checkAllReadClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "checkAllReadClicked")
          @toolbarView.$el.find(".read-bulk-action").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when unread-bulk-action is clicked", ->
        it "triggers checkAllUnreadClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "checkAllUnreadClicked")
          @toolbarView.$el.find(".unread-bulk-action").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

    describe "#setupSnoozeButtons", ->

      beforeEach ->
        @triggerStub = sinon.stub(@toolbarView, "trigger", ->)

      afterEach ->
        @triggerStub.restore()

      it "handles clicks", ->
        expect(@toolbarView.$el.find(".snooze-dropdown .dropdown-menu .one-hour")).toHandle("click")
        expect(@toolbarView.$el.find(".snooze-dropdown .dropdown-menu .four-hours")).toHandle("click")
        expect(@toolbarView.$el.find(".snooze-dropdown .dropdown-menu .eight-hours")).toHandle("click")
        expect(@toolbarView.$el.find(".snooze-dropdown .dropdown-menu .one-day")).toHandle("click")

      it "triggers", ->
        @toolbarView.$el.find(".snooze-dropdown .dropdown-menu .one-hour").click()
        expect(@triggerStub).toHaveBeenCalledWith("snoozeClicked", @toolbarView, 60)
        @toolbarView.$el.find(".snooze-dropdown .dropdown-menu .four-hours").click()
        expect(@triggerStub).toHaveBeenCalledWith("snoozeClicked", @toolbarView, 60 * 4)
        @toolbarView.$el.find(".snooze-dropdown .dropdown-menu .eight-hours").click()
        expect(@triggerStub).toHaveBeenCalledWith("snoozeClicked", @toolbarView, 60 * 8)
        @toolbarView.$el.find(".snooze-dropdown .dropdown-menu .one-day").click()
        expect(@triggerStub).toHaveBeenCalledWith("snoozeClicked", @toolbarView, 60 * 24)

    describe "#allCheckboxIsChecked", ->

      describe "when the all checkbox is checked", ->
        beforeEach ->
          @toolbarView.divAllCheckbox.iCheck("check")

        it "returns true", ->
          expect(@toolbarView.allCheckboxIsChecked()).toBeTruthy()

      describe "when the all checkbox is not checked", ->
        beforeEach ->
          @toolbarView.divAllCheckbox.iCheck("uncheck")

        it "returns false", ->
          expect(@toolbarView.allCheckboxIsChecked()).toBeFalsy()

    describe "#uncheckAllCheckbox", ->

      it "unchecks the all checkbox", ->
        spy = sinon.spy(@toolbarView.divAllCheckbox, "iCheck")
        @toolbarView.uncheckAllCheckbox()
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith("uncheck")
        spy.restore()

    describe "#updatePaginationText", ->
      beforeEach ->
        @emailFolder = TuringEmailApp.collections.emailFolders.models[0]

        @validatePaginationText = ->
          totalEmailsNumber = parseInt(@toolbarView.$el.find(".total-emails-number").text())
          expect(totalEmailsNumber).toEqual @emailFolder.get("num_threads")

    describe "#showMoveToFolderMenu", ->
      beforeEach ->
        spyOnEvent(@toolbarView.$el.find(".move-to-folder-dropdown-menu"), "click.bs.dropdown")
        @toolbarView.showMoveToFolderMenu()

      it "shows the move to folder menu", ->
        expect("click.bs.dropdown").toHaveBeenTriggeredOn(@toolbarView.$el.find(".move-to-folder-dropdown-menu"))

    describe "TuringEmailApp Events", ->

      describe "#currentEmailFolderChanged", ->
        beforeEach ->
          @updatePaginationTextSpy = sinon.spy(@toolbarView, "updatePaginationText")

        afterEach ->
          @updatePaginationTextSpy.restore()

        describe "with an email folder", ->
          beforeEach ->
            @toolbarView.currentEmailFolder = null
            @toolbarView.currentEmailFolderPage = 0

            @emailFolder = TuringEmailApp.collections.emailFolders.models[0]
            @emailFolderPage = 1

            @toolbarView.currentEmailFolderChanged(TuringEmailApp, @emailFolder, @emailFolderPage)

          it "updates the current email folder variables", ->
            expect(@toolbarView.currentEmailFolder).toEqual(@emailFolder)
            expect(@toolbarView.currentEmailFolderPage).toEqual(@emailFolderPage)

          it "updates the pagination text", ->
            expect(@updatePaginationTextSpy).toHaveBeenCalledWith(@emailFolder, @emailFolderPage)

        describe "without an email folder", ->
          beforeEach ->
            @toolbarView.currentEmailFolder = TuringEmailApp.collections.emailFolders.models[0]
            @toolbarView.currentEmailFolderPage = 1

            @emailFolder = null
            @emailFolderPage = 0

            @toolbarView.currentEmailFolderChanged(TuringEmailApp, @emailFolder, @emailFolderPage)

          it "updates the current email folder variables", ->
            expect(@toolbarView.currentEmailFolder).toEqual(@emailFolder)
            expect(@toolbarView.currentEmailFolderPage).toEqual(@emailFolderPage)

          it "updates the pagination text", ->
            expect(@updatePaginationTextSpy).toHaveBeenCalledWith(@emailFolder, @emailFolderPage)

      describe "#emailFoldersChanged", ->
        beforeEach ->
          @renderSpy = sinon.spy(@toolbarView, "render")
          @toolbarView.emailFoldersChanged()

        afterEach ->
          @renderSpy.restore()

        it "triggers render", ->
          expect(@renderSpy).toHaveBeenCalled()
