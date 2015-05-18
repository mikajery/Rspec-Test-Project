describe "AlertView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @classtype = 'testClassType'
    @alertView = new TuringEmailApp.Views.AlertView(
      classType: @classtype
      text: "testText"
    )

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@alertView.template).toEqual JST["backbone/templates/alert/alert"]

  describe "#render", ->
    beforeEach ->
      @alertView.render()

    it "adds the classes and styling to the alert view", ->
      expect(@alertView.$el).toHaveClass(@classtype)

    describe "when the dismiss alert link is clicked", ->
      beforeEach ->
        @removeAlertStub = sinon.stub(TuringEmailApp, "removeAlert")

      afterEach ->
        @removeAlertStub.restore()

      it "removes the alert view", ->
        @alertView.$el.find(".tm_alert-dismiss").click()
        expect(@removeAlertStub).toHaveBeenCalled()
