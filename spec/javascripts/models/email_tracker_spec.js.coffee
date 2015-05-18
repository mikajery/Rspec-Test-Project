describe "EmailTracker", ->
  beforeEach ->
    @emailTracker = new TuringEmailApp.Models.EmailTracker()

  it "uses uid as idAttribute", ->
    expect(@emailTracker.idAttribute).toEqual("uid")
