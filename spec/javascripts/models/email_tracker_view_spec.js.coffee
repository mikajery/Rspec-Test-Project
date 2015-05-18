describe "EmailTrackerView", ->

  beforeEach ->
    @emailTrackerView = new TuringEmailApp.Models.EmailTrackerView()

  it "uses uid as idAttribute", ->
    expect(@emailTrackerView.idAttribute).toEqual("uid")