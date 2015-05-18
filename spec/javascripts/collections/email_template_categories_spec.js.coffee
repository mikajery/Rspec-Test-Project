describe "EmailTemplateCategoriesCollection", ->
  beforeEach ->
    @emailTemplateCategories = new TuringEmailApp.Collections.EmailTemplateCategoriesCollection()

  it "uses the Email Template model", ->
    expect(@emailTemplateCategories.model).toEqual(TuringEmailApp.Models.EmailTemplateCategory)

  it "has the right URL", ->
    expect(@emailTemplateCategories.url).toEqual("/api/v1/email_template_categories")
