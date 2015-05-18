class TuringEmailApp.Views.CollectionView extends TuringEmailApp.Views.BaseView
  initialize: (options) ->
    super(options)

    @listenTo(@collection, "add", => @render())
    @listenTo(@collection, "remove", => @render())
    @listenTo(@collection, "reset", => @render())
    @listenTo(@collection, "destroy", => @render())
