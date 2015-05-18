describe "EmailTemplateCategory", ->
  beforeEach ->
    @emailTemplateCategory = new TuringEmailApp.Models.EmailTemplateCategory()

  it "uses uid as idAttribute", ->
    expect(@emailTemplateCategory.idAttribute).toEqual("uid")

  it "has the right urlRoot", ->
    expect(@emailTemplateCategory.urlRoot).toEqual("/api/v1/email_template_categories")
