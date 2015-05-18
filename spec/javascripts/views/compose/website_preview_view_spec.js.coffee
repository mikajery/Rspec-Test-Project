describe "WebsitePreviewView", ->
  beforeEach ->
    websitePreviewAttributes = FactoryGirl.create("WebsitePreview")
    @websitePreview = new TuringEmailApp.Models.WebsitePreview(websitePreviewAttributes,
      websiteURL: websitePreviewAttributes.url
    )

    @websitePreviewView = new TuringEmailApp.Views.WebsitePreviewView(
      model: @websitePreview
    )

  it "has the right template", ->
    expect(@websitePreviewView.template).toEqual JST["backbone/templates/compose/website_preview"]

  it "has the right events", ->
    expect(@websitePreviewView.events["click .compose-link-preview-close-button"]).toEqual "hide"

  describe "after render", ->
    beforeEach ->
      @websitePreviewView.render()

    describe "#render", ->

      describe "#attributes", ->

        attributes = ["title", "snippet", "imageUrl"]

        for attribute in attributes
          it "renders the " + attribute + " attribute", ->
            expect(@websitePreviewView.$el).toContainHtml @websitePreviewView.model.get(attribute)

    describe "#hide", ->

      it "removes the preview", ->
        removeSpy = sinon.spy($.prototype, "remove")
        @websitePreviewView.hide()
        expect(removeSpy).toHaveBeenCalled()
        removeSpy.restore()
