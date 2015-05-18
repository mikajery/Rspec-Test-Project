describe "AppsLibrary", ->
  beforeEach ->
    specStartTuringEmailApp()

    @apps = new TuringEmailApp.Collections.AppsCollection(FactoryGirl.createLists("App", FactoryGirl.SMALL_LIST_SIZE))
    @appsLibraryView = new TuringEmailApp.Views.PrimaryPane.AppsLibrary.AppsLibraryView(collection: @apps, developer_enabled: true)

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@appsLibraryView.template).toEqual JST["backbone/templates/primary_pane/apps_library/apps_library"]

  describe "#render", ->
    beforeEach ->
      @setupButtonsStub = sinon.stub(@appsLibraryView, "setupButtons")

      @appsLibraryView.render()
      
    afterEach ->
      @setupButtonsStub.restore()
      
    it "calls setupButtons", ->
      expect(@setupButtonsStub).toHaveBeenCalled()
      
    describe "developer_enabled=true", ->
      beforeEach ->
        @appsLibraryView.render()
        
      it "renders the create button", ->
        expect(@appsLibraryView.$el.find(".create-app-button").length).toEqual(1)
      
    describe "developer_enabled=false", ->
      beforeEach ->
        @appsLibraryView.developer_enabled = false
        @appsLibraryView.render()

      it "does NOT render the create button", ->
        expect(@appsLibraryView.$el.find(".create-app-button").length).toEqual(0)
        
  describe "after render", ->
    beforeEach ->
      @appsLibraryView.render()

    describe "#setupButtons", ->
      beforeEach ->
        @appsLibraryView.setupButtons()

      it "creates the create app view", ->
        expect(@appsLibraryView.createAppView).toBeDefined()
        
      it "renders the create app view", ->
        expect(@appsLibraryView.$el.find(".create_app_view").html()).toEqual(@appsLibraryView.createAppView.$el.html())

      it "create-app-button click", ->
        @onCreateAppButtonClickStub = sinon.stub(TuringEmailApp.Views.PrimaryPane.AppsLibrary.AppsLibraryView.prototype, 'onCreateAppButtonClick', ->)

        newAppsLibraryView = new TuringEmailApp.Views.PrimaryPane.AppsLibrary.AppsLibraryView(collection: @apps, developer_enabled: true)
        newAppsLibraryView.render()

        newAppsLibraryView.$el.find(".create-app-button").click()
        expect(@onCreateAppButtonClickStub).toHaveBeenCalled()

        TuringEmailApp.Views.PrimaryPane.AppsLibrary.AppsLibraryView.prototype.onCreateAppButtonClick.restore()

      it "install-app-button click", ->
        @onInstallAppButtonClickStub = sinon.stub(TuringEmailApp.Views.PrimaryPane.AppsLibrary.AppsLibraryView.prototype, "onInstallAppButtonClick", ->)

        newAppsLibraryView = new TuringEmailApp.Views.PrimaryPane.AppsLibrary.AppsLibraryView(collection: @apps, developer_enabled: true)
        newAppsLibraryView.render()

        newAppsLibraryView.$el.find(".install-app-button").click()
        expect(@onInstallAppButtonClickStub).toHaveBeenCalled()

        TuringEmailApp.Views.PrimaryPane.AppsLibrary.AppsLibraryView.prototype.onInstallAppButtonClick.restore()

    describe "after setupButtons", ->
      beforeEach ->
        @appsLibraryView.setupButtons()

      describe "#onCreateAppButtonClick", ->
        it "shows the app view", ->
          @createAppViewShowStub = sinon.stub(TuringEmailApp.Views.PrimaryPane.AppsLibrary.CreateAppView.prototype, "show", ->)

          newAppsLibraryView = new TuringEmailApp.Views.PrimaryPane.AppsLibrary.AppsLibraryView(collection: @apps, developer_enabled: true)
          newAppsLibraryView.render()

          newAppsLibraryView.onCreateAppButtonClick(null)

          expect(@createAppViewShowStub).toHaveBeenCalled()

          TuringEmailApp.Views.PrimaryPane.AppsLibrary.CreateAppView.prototype.show.restore()

      describe "#onInstallAppButtonClick", ->
        beforeEach ->
          @clock = sinon.useFakeTimers()
        
          @event =
            currentTarget: $(@appsLibraryView.$el.find(".install-app-button")[0])
            preventDefault: ->

          @alertToken = {}
          @showAlertStub = sinon.stub(TuringEmailApp, "showAlert", => @alertToken)

          @appsLibraryView.onInstallAppButtonClick(@event)

        afterEach ->
          @clock.restore()

          @showAlertStub.restore()

        it "triggers installAppClicked", ->
          @triggerStub = sinon.stub(TuringEmailApp.Views.PrimaryPane.AppsLibrary.AppsLibraryView.prototype, "trigger", ->)

          newAppsLibraryView = new TuringEmailApp.Views.PrimaryPane.AppsLibrary.AppsLibraryView(collection: @apps, developer_enabled: true)
          newAppsLibraryView.render()
          @event.currentTarget = $(newAppsLibraryView.$el.find(".install-app-button")[0])
          newAppsLibraryView.onInstallAppButtonClick(@event)

          expect(@triggerStub).toHaveBeenCalledWith("installAppClicked", newAppsLibraryView, @apps.at(0).get("uid"))

          TuringEmailApp.Views.PrimaryPane.AppsLibrary.AppsLibraryView.prototype.trigger.restore()

        it "shows the alert", ->
          expect(@showAlertStub).toHaveBeenCalledWith("You have installed the app!", "alert-success")
  
        it "removes the alert after three seconds", ->
          expect(@showAlertStub).toHaveBeenCalledWith("You have installed the app!", "alert-success", 3000)
