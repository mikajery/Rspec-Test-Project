describe "TourView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @tourView = new TuringEmailApp.Views.TourView()

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@tourView.template).toEqual JST["backbone/templates/tour/tour"]
