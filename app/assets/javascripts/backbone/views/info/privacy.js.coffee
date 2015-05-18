class TuringEmailApp.Views.PrivacyView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/info/privacy"]

  render: ->
    @$el.html(@template())
    @show()

    @

  #################
  ### Show/Hide ###
  #################

  show: ->
    @$(".privacy-modal").modal(
      backdrop: 'static'
      keyboard: false
    ).show()

  hide: ->
    @$(".privacy-modal").modal "hide"
