describe "SkinsCollection", ->
  beforeEach ->
    @url = "/api/v1/skins"
    @skinsCollection = new TuringEmailApp.Collections.SkinsCollection()

  it "should use the Skin model", ->
    expect(@skinsCollection.model).toEqual TuringEmailApp.Models.Skin

  it "has the right url", ->
    expect(@skinsCollection.url).toEqual @url
