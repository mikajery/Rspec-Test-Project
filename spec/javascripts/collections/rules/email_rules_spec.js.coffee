describe "EmailRulesCollection", ->
  beforeEach ->
    @url = "/api/v1/email_rules"
    @emailRulesCollection = new TuringEmailApp.Collections.Rules.EmailRulesCollection()

  it "should use the EmailRule model", ->
    expect(@emailRulesCollection.model).toEqual TuringEmailApp.Models.Rules.EmailRule

  it "has the right url", ->
    expect(@emailRulesCollection.url).toEqual @url
