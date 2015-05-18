class TuringEmailApp.Views.SidebarView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/sidebar/sidebar"]

  render: ->
    @$el.html(@template())

    @composebuttonview = new TuringEmailApp.Views.ComposeButtonView(
      el: @$(".tm_sidebar-content")
    )
    @composebuttonview.render()

    @
