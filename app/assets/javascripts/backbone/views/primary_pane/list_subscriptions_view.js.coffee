TuringEmailApp.Views.PrimaryPane ||= {}

class TuringEmailApp.Views.PrimaryPane.ListSubscriptionsView extends TuringEmailApp.Views.CollectionView
  template: JST["backbone/templates/primary_pane/list_subscriptions"]

  events:
    "click .unsubscribe-list-button": "onUnsubscribeListClick"
    "click .resubscribe-list-button": "onResubscribeListClick"
    "click .list-subscription-pagination .next-list-subscription-page": "nextSubscriptionPage"
    "click .list-subscription-pagination .previous-list-subscription-page": "previousSubscriptionPage"
    "click .list-unsubscription-pagination .next-list-unsubscription-page": "nextUnsubscriptionPage"
    "click .list-unsubscription-pagination .previous-list-unsubscription-page": "previousUnsubscriptionPage"

  className: "tm_content tm_subscriptions-view"

  initialize: (options) ->
    super(options)
    @currentListsSubscribedPageNumber = 0
    @currentListsUnsubscribedPageNumber = 0
    @pageSize = 25

  render: ->
    selectedTabID = $(".tm_content-tab-pane.active").attr("id")

    @listsSubscribed = []
    @listsUnsubscribed = []

    listsSubscribedJSON = []
    listsUnsubscribedJSON = []

    for listSubscription in @collection.models
      if listSubscription.get("unsubscribed")
        @listsUnsubscribed.push(listSubscription)
        listsUnsubscribedJSON.push(listSubscription.toJSON())
      else
        @listsSubscribed.push(listSubscription)
        listsSubscribedJSON.push(listSubscription.toJSON())

    params =
      listsSubscribed: listsSubscribedJSON
      listsUnsubscribed: listsUnsubscribedJSON
      currentListsSubscribedPageNumber: @currentListsSubscribedPageNumber
      currentListsUnsubscribedPageNumber: @currentListsUnsubscribedPageNumber
      pageSize: @pageSize

    @$el.html(@template(params))


    $("a[href=#" + selectedTabID + "]").click() if selectedTabID?

    @

  #TODO write tests, or replace with infinite scroll and then write tests.
  nextSubscriptionPage: ->
    if @listsSubscribed.length >= ((@currentListsSubscribedPageNumber + 1) * @pageSize)
      @currentListsSubscribedPageNumber += 1
      @render()
    false

  previousSubscriptionPage: ->
    if @currentListsSubscribedPageNumber > 0
      @currentListsSubscribedPageNumber -= 1
      @render()
    false

  nextUnsubscriptionPage: ->
    if @listsUnsubscribed.length >= ((@currentListsUnsubscribedPageNumber + 1) * @pageSize)
      @currentListsUnsubscribedPageNumber += 1
      @render()
    false

  previousUnsubscriptionPage: ->
    if @currentListsUnsubscribedPageNumber > 0
      @currentListsUnsubscribedPageNumber -= 1
      @render()
    false

  onUnsubscribeListClick: (evt) ->
    index = @$(".unsubscribe-list-button").index(evt.currentTarget)
    listSubscription = @listsSubscribed[index]

    @trigger("unsubscribeListClicked", this, listSubscription)

  onResubscribeListClick: (evt) ->
    index = @$(".resubscribe-list-button").index(evt.currentTarget)
    listSubscription = @listsUnsubscribed[index]

    @trigger("resubscribeListClicked", this, listSubscription)
