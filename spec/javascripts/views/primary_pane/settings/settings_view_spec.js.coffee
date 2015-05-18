describe "SettingsView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @server = sinon.fakeServer.create()


    @userConfiguration = new TuringEmailApp.Models.UserConfiguration()

    @settingsDiv = $("<div />", {id: "settings"}).appendTo("body")
    @settingsView = new TuringEmailApp.Views.PrimaryPane.Settings.SettingsView(
      el: @settingsDiv
      model: @userConfiguration
    )

    @userConfiguration.set(FactoryGirl.create("UserConfiguration"))

  afterEach ->
    @server.restore()
    @settingsDiv.remove()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@settingsView.template).toEqual JST["backbone/templates/primary_pane/settings/settings"]

  it "has the right events", ->
    expect(@settingsView.events["click .uninstall-app-button"]).toEqual "uninstallApp"

  describe "#render", ->
    it "renders the settings view", ->
      expect(@settingsDiv).toContainHtml('<h1>Settings</h1>')

      expect(@settingsDiv).toContainHtml('Keyboard Shortcuts')
      expect(@settingsDiv).toContainHtml('Inbox Cleaner')
      expect(@settingsDiv).toContainHtml('Horizontal')

    it "renders the tabs", ->
      expect(@settingsDiv.find("a[href=#tab-1]").text()).toEqual("General")
      expect(@settingsDiv.find("a[href=#tab-2]").text()).toEqual("Installed Apps")
      expect(@settingsDiv.find("a[href=#tab-3]").text()).toEqual("Profile")

    it "renders the keyboard shortcuts switch", ->
      keyboardShortcutsSwitch = $(".keyboard-shortcuts-switch")
      expect(@settingsDiv).toContain(keyboardShortcutsSwitch)
      expect(keyboardShortcutsSwitch.is(":checked")).toEqual(@userConfiguration.get("keyboard_shortcuts_enabled"))

    it "renders the split pane select", ->
      splitPaneSelect = $(".split-pane-select")
      expect(@settingsDiv).toContain(splitPaneSelect)

    it "renders the auto cleaner switch", ->
      autoCleanerSwitch = $(".auto-cleaner-switch")
      expect(@settingsDiv).toContain(autoCleanerSwitch)
      expect(autoCleanerSwitch.is(":checked")).toEqual(@userConfiguration.get("auto_cleaner_enabled"))

    it "renders the developer switch", ->
      developerSwitch = $(".developer-switch")
      expect(@settingsDiv).toContain(developerSwitch)
      expect(developerSwitch.is(":checked")).toEqual(@userConfiguration.get("developer_enabled"))

    it "renders the inbox tabs switch", ->
      inboxTabsSwitch = $(".inbox-tabs-switch")
      expect(@settingsDiv).toContain(inboxTabsSwitch)
      expect(inboxTabsSwitch.is(":checked")).toEqual(@userConfiguration.get("inbox_tabs_enabled"))

    describe "with selected tab", ->
      beforeEach ->
        @selectedTabID = "#tab-3"
        @selector = "a[href=" + @selectedTabID + "]"
        $(@selector).click()

        @newSelectedTabID = $(".tm_content-tabs li.active a").attr("href")

      afterEach ->
        @selectedTabID = "#tab-1"
        @selector = "a[href=" + @selectedTabID + "]"
        $(@selector).click()

      it "selects the tab", ->
        expect(@newSelectedTabID).toEqual(@selectedTabID)

    it "renders the installed apps table", ->
      installedAppsTable = $(".installed-apps-table")
      expect(@settingsDiv).toContain(installedAppsTable)

    it "renders the installed apps information", ->
      installedAppsTable = $(".installed-apps-table")
      for installedApp, index in @userConfiguration.toJSON().installed_apps
        expect(@settingsDiv.find(".installed-app")[index]).toContainHtml('<td>' + installedApp.app.name + '</td>')
        expect(@settingsDiv.find(".installed-app")[index]).toContainHtml('<td>' + installedApp.app.description + '</td>')

  describe "#setupSwitches", ->

    it "sets up the keyboard shortcuts switch", ->
      @settingsView.setupSwitches()
      expect(@settingsDiv.find(".keyboard-shortcuts-switch").parent().parent()).toHaveClass "has-switch"

      @settingsView.setupSwitches()
    it "sets up the genie switch", ->
      expect(@settingsDiv.find(".genie-switch").parent().parent()).toHaveClass "has-switch"

  describe "#saveSettings", ->
    it "is called by the switch change event on the switches", ->
      spy = sinon.spy(@settingsView, "saveSettings")

      genieSwitch = @settingsView.$el.find(".genie-switch")
      genieSwitch.click()
      expect(spy).toHaveBeenCalled()
      spy.restore()

    describe "when saveSettings is called", ->
      it "patches the server", ->
        genieSwitch = @settingsView.$el.find(".genie-switch")
        genieSwitch.click()

        request = @server.requests[@server.requests.length - 1]

        expect(request.method).toEqual "PATCH"
        expect(request.url).toEqual "/api/v1/user_configurations"

      it "updates the user settings model with the correct values", ->
        expect(@userConfiguration.get("genie_enabled")).toEqual(true)
        expect(@userConfiguration.get("inbox_tabs_enabled")).toEqual(false)

        inboxTabsSwitch = $(".inbox-tabs-switch")
        inboxTabsSwitch.click()

        expect(@userConfiguration.get("genie_enabled")).toEqual(true)
        expect(@userConfiguration.get("inbox_tabs_enabled")).toEqual(true)

      it "displays a success alert after the save button is clicked and then hides it", ->
        @clock = sinon.useFakeTimers()

        showAlertSpy = sinon.spy(TuringEmailApp, "showAlert")
        removeAlertSpy = sinon.spy(TuringEmailApp, "removeAlert")

        @settingsView.saveSettings()

        @server.respondWith "PATCH", @userConfiguration.url, stringifyUserConfiguration(@userConfiguration)
        @server.respond()

        expect(showAlertSpy).toHaveBeenCalled()

        @clock.tick(5000)

        expect(removeAlertSpy).toHaveBeenCalled()

        @clock.restore()
        @server.restore()

        showAlertSpy.restore()
        removeAlertSpy.restore()

  describe "#setupUninstallAppButtons", ->
    describe "clicking on the uninstall app button", ->
      beforeEach ->
        @triggerStub = sinon.stub(@settingsView, "trigger")
        @removeSpy = sinon.spy($.prototype, "remove")

      afterEach ->
        @removeSpy.restore()
        @triggerStub.restore()

      it "triggers uninstallAppClicked and removes its element from the DOM", ->
        index = 0

        for uninstallButton in @settingsView.$el.find(".uninstall-app-button")
          uninstallButton = $(uninstallButton)
          @removeSpy.reset()

          uninstallButton.click()
          appID = uninstallButton.attr("data")

          expect(@triggerStub).toHaveBeenCalledWith("uninstallAppClicked", @settingsView, appID)
          expect(@removeSpy).toHaveBeenCalled()

          index += 1
