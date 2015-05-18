describe "EmailTemplate", ->
  beforeEach ->
    @emailTemplate = new TuringEmailApp.Models.EmailTemplate()

  it "uses uid as idAttribute", ->
    expect(@emailTemplate.idAttribute).toEqual("uid")

  it "has the right urlRoot", ->
    expect(@emailTemplate.urlRoot).toEqual("/api/v1/email_templates")
