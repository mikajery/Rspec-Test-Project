class TuringEmailApp.Views.AboutView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/info/about"]

  render: ->
    @$el.html(@template())
    @show()

    @

  #################
  ### Show/Hide ###
  #################

  show: ->
    @$(".about-modal").modal(
      backdrop: 'static'
      keyboard: false
    ).show()

  hide: ->
    @$(".about-modal").modal "hide"
