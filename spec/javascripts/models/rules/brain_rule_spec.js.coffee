describe "BrainRule", ->

  beforeEach ->
    @brainRule = new TuringEmailApp.Models.Rules.BrainRule()

  it "uses uid as idAttribute", ->
    expect(@brainRule.idAttribute).toEqual("uid")
