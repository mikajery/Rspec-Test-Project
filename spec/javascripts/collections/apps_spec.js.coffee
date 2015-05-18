describe "AppsCollection", ->
  beforeEach ->
    @appsCollection = new TuringEmailApp.Collections.AppsCollection()

  it "uses the App model", ->
    expect(@appsCollection.model).toEqual(TuringEmailApp.Models.App)

  it "has the right URL", ->
    expect(@appsCollection.url).toEqual("/api/v1/apps")
