describe "WebsitePreview", ->
  beforeEach ->
    @websitePreview = new TuringEmailApp.Models.WebsitePreview(
      websiteURL: ""
    )
    @seededChance = new Chance(1)
    
  it "has the right url", ->
    expect(@websitePreview.url).toEqual("/api/v1/website_previews/proxy?url=")

  it "correctly sets the suffix", ->
    randomUrl = @seededChance.string({length: 20})
    otherWebsitePreview = new TuringEmailApp.Models.WebsitePreview(
      websiteURL: randomUrl
    )
    expect(otherWebsitePreview.url).toEqual("/api/v1/website_previews/proxy?url=" + randomUrl)

  describe "#websiteURLIs", ->
    beforeEach ->
      @randomUrl = @seededChance.string({length: 20})

    it "correctly sets the websiteUrl", ->
      @websitePreview.websiteURLIs @randomUrl
      expect(@websitePreview.url).toEqual("/api/v1/website_previews/proxy?url=" + @randomUrl)

    it "returns the url", ->
      expect( @websitePreview.websiteURLIs(@randomUrl) ).toEqual("/api/v1/website_previews/proxy?url=" + @randomUrl)

  describe "#parse", ->
    beforeEach ->
      websitePreviewServerResponseAttributes = FactoryGirl.create("WebsitePreviewServerResponse")
      @websitePreview = new TuringEmailApp.Models.WebsitePreview(websitePreviewServerResponseAttributes,
        websiteURL: websitePreviewServerResponseAttributes.url
      )

      @parsedResponse = @websitePreview.parse(websitePreviewServerResponseAttributes)

    it "correctly parses out the title attributes from the response html", ->
      expect(@parsedResponse["title"]).toEqual "Apple"

    it "correctly parses out the snippet attributes from the response html", ->
      expect(@parsedResponse["snippet"]).toEqual "Apple designs and creates the iPhone, iPad, Mac notebooks and desktop computers, iOS, OS X, iPod and iTunes, and the new Apple Watch."

    it "correctly parses out the image url attributes from the response html", ->
      expect(@parsedResponse["imageUrl"]).toEqual "http://images.apple.com/home/images/og.jpg?201410151147"
