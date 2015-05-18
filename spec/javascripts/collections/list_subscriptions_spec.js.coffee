describe "ListSubscriptionsCollection", ->
  beforeEach ->
    @listSubscriptions = new TuringEmailApp.Collections.ListSubscriptionsCollection()

  it "uses the List Subscription model", ->
    expect(@listSubscriptions.model).toEqual(TuringEmailApp.Models.ListSubscription)

  it "has the right URL", ->
    expect(@listSubscriptions.url).toEqual("/api/v1/list_subscriptions")
