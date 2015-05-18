describe "EmailRule", ->

  beforeEach ->
    @emailRule = new TuringEmailApp.Models.Rules.EmailRule()

  it "uses uid as idAttribute", ->
    expect(@emailRule.idAttribute).toEqual("uid")
