class TuringEmailApp.Views.TermsView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/info/terms"]

  render: ->
    @$el.html(@template())
    @show()

    @

  #################
  ### Show/Hide ###
  #################

  show: ->
    @$(".terms-modal").modal(
      backdrop: 'static'
      keyboard: false
    ).show()

  hide: ->
    @$(".terms-modal").modal "hide"
