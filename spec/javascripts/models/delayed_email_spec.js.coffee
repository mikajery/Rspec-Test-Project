describe "DelayedEmail", ->
  beforeEach ->
    @delayedEmail = new TuringEmailApp.Models.DelayedEmail()

  it "uses uid as idAttribute", ->
    expect(@delayedEmail.idAttribute).toEqual("uid")
