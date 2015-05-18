describe "EmailTemplateCategoriesView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @emailTemplateCategories = new TuringEmailApp.Collections.EmailTemplateCategoriesCollection(FactoryGirl.createLists("EmailTemplateCategory", FactoryGirl.SMALL_LIST_SIZE))
    @emailTemplateCategoriesView = new TuringEmailApp.Views.PrimaryPane.EmailTemplates.EmailTemplateCategoriesView(collection: @emailTemplateCategories)

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@emailTemplateCategoriesView.template).toEqual JST["backbone/templates/primary_pane/email_templates/email_template_categories"]

  it "has the right className", ->
    expect(@emailTemplateCategoriesView.className).toEqual "tm_content tm_content-with-toolbar"

  describe "Render", ->
    it "email template categories should contain [data-uid] attribute", ->
      @emailTemplateCategoriesView.render()
      expect(@emailTemplateCategoriesView.$el.find("[data-uid]").length).toEqual @emailTemplateCategoriesView.collection.length

  describe "Events", ->
    beforeEach ->
      @emailTemplateCategoriesView.render()

    it "should trigger destroy() when .delete-email-template-category-button is clicked", ->
      button = $(@emailTemplateCategoriesView.$el.find(".delete-email-template-category-button")[0])
      uid = $(button).closest("[data-uid]").data("uid")
      email = @emailTemplateCategories.get uid

      destroyStub = sinon.stub email, "destroy", ->
        deferred = $.Deferred()
        deferred.resolve()

        return deferred.promise()

      button.click()

      expect(destroyStub).toHaveBeenCalled()
