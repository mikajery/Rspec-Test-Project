describe "EmailSignature", ->

  beforeEach ->
    @emailSignature = new TuringEmailApp.Models.EmailSignature()

  it "uses uid as idAttribute", ->
    expect(@emailSignature.idAttribute).toEqual("uid")

  it "uses '/api/v1/email_signatures' as urlRoot", ->
    expect( @emailSignature.urlRoot ).toEqual '/api/v1/email_signatures'
