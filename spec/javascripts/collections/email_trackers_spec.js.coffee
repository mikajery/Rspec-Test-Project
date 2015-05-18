describe "EmailTrackersCollection", ->
  beforeEach ->
    @emailTrackers = new TuringEmailApp.Collections.EmailTrackersCollection()

  it "uses the Email Tracker model", ->
    expect(@emailTrackers.model).toEqual(TuringEmailApp.Models.EmailTracker)

  it "has the right URL", ->
    expect(@emailTrackers.url).toEqual("/api/v1/email_trackers")
