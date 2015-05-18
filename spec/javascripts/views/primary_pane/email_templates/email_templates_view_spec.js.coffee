describe "EmailTemplatesView", ->
  beforeEach ->
    specStartTuringEmailApp()

    if emailTemplateCategoryUID == "-1" or not emailTemplateCategoryUID
      emailTemplateCategoryUID = ""

    TuringEmailApp.collections.emailTemplateCategories = new TuringEmailApp.Collections.EmailTemplateCategoriesCollection(FactoryGirl.createLists("EmailTemplateCategory", FactoryGirl.SMALL_LIST_SIZE))
    TuringEmailApp.collections.emailTemplates = new TuringEmailApp.Collections.EmailTemplatesCollection(FactoryGirl.createLists("EmailTemplate", FactoryGirl.SMALL_LIST_SIZE))

    @emailTemplatesView = new TuringEmailApp.Views.PrimaryPane.EmailTemplates.EmailTemplatesView(
      categoryUID: emailTemplateCategoryUID
    )

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@emailTemplatesView.template).toEqual JST["backbone/templates/primary_pane/email_templates/email_templates"]

  it "has the right className", ->
    expect(@emailTemplatesView.className).toEqual "tm_content tm_content-with-toolbar"

  describe "Render", ->
    it "email template container should contain [data-uid] attribute", ->
      @emailTemplatesView.render()
      expect(@emailTemplatesView.$el.find("[data-uid]").length).toEqual @emailTemplatesView.collection.length

  describe "Events", ->
    beforeEach ->
      @emailTemplatesView.render()

    it "should trigger destroy() when .delete-email-template-button is clicked", ->
      button = $(@emailTemplatesView.$el.find(".delete-email-template-button")[0])
      uid = $(button).closest("[data-uid]").data("uid")
      email = TuringEmailApp.collections.emailTemplates.get uid

      destroyStub = sinon.stub email, "destroy", ->
        deferred = $.Deferred()
        deferred.resolve()

        return deferred.promise()

      button.click()

      expect(destroyStub).toHaveBeenCalled()
