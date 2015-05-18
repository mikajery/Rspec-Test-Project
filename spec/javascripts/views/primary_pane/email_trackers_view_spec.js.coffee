describe "EmailTrackersView", ->
  beforeEach ->
    @collection = new Backbone.Collection([{}])
    @emailTrackersView = new TuringEmailApp.Views.PrimaryPane.EmailTrackersView(collection: @collection)

  it "has the right template", ->
    expect(@emailTrackersView.template).toEqual JST["backbone/templates/primary_pane/email_trackers"]
