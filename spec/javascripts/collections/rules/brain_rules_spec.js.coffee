describe "BrainRulesCollection", ->
  beforeEach ->
    @url = "/api/v1/genie_rules"
    @brainRulesCollection = new TuringEmailApp.Collections.Rules.BrainRulesCollection()

  it "should use the BrainRule model", ->
    expect(@brainRulesCollection.model).toEqual TuringEmailApp.Models.Rules.BrainRule

  it "has the right url", ->
    expect(@brainRulesCollection.url).toEqual @url
