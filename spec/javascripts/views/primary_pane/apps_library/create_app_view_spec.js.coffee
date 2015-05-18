describe "CreateAppView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @createAppDiv = $("<div class='create_app_view'></div>").appendTo("body")
    @createAppView = new TuringEmailApp.Views.PrimaryPane.AppsLibrary.CreateAppView(
      app: TuringEmailApp
      el: $(".create_app_view")
    )

  afterEach ->
    @createAppDiv.remove()
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@createAppView.template).toEqual JST["backbone/templates/primary_pane/apps_library/create_app"]

  describe "after render", ->
    beforeEach ->
      @createAppView.render()

    describe "#show", ->
      beforeEach ->
        spyOnEvent('.dropdown a', 'click.bs.dropdown')
        @createAppView.show()

      it "triggers the click.bs.dropdown event on the dropdown link", ->
        expect("click.bs.dropdown").toHaveBeenTriggeredOn(".dropdown a")

    describe "#hide", ->
      beforeEach ->
        spyOnEvent('.dropdown a', 'click.bs.dropdown')
        @createAppView.hide()

      it "triggers the click.bs.dropdown event on the dropdown link", ->
        expect("click.bs.dropdown").toHaveBeenTriggeredOn(".dropdown a")

    describe "#onSubmit", ->
      beforeEach ->
        @createAppView.$el.find(".create-app-form .create-app-name").val("Name")
        @createAppView.$el.find(".create-app-form .create-app-description").val("Desc")
        @createAppView.$el.find(".create-app-form .create-app-type").val("Type")
        @createAppView.$el.find(".create-app-form .create-app-callback-url").val("Callback")

        @server = sinon.fakeServer.create()
        @clock = sinon.useFakeTimers()

        @hideStub = sinon.stub(@createAppView, "hide")

        @alertToken = {}
        @showAlertStub = sinon.stub(TuringEmailApp, "showAlert", => @alertToken)

        @createAppView.onSubmit()

      afterEach ->
        @clock.restore()
        @server.restore()

        @showAlertStub.restore()
        @hideStub.restore()

      it "posts the create app request", ->
        expect(@server.requests.length).toEqual 1

        request = @server.requests[0]
        expect(request.method).toEqual("POST")
        expect(request.url).toEqual("/api/v1/apps")

        expect(request.requestBody).toEqual('{"app_type":"panel","name":"","description":"","callback_url":""}')

      it "hides the view", ->
        expect(@hideStub).toHaveBeenCalled()
