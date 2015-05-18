describe "EmailTemplatesCollection", ->
  beforeEach ->
    @emailTemplates = new TuringEmailApp.Collections.EmailTemplatesCollection()

  it "uses the Email Template model", ->
    expect(@emailTemplates.model).toEqual(TuringEmailApp.Models.EmailTemplate)

  it "has the right URL", ->
    expect(@emailTemplates.url).toEqual("/api/v1/email_templates")
 