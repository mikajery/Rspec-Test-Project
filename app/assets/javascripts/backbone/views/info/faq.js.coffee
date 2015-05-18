class TuringEmailApp.Views.FAQView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/info/faq"]

  render: ->
    @$el.html(@template())
    @show()

    @

  #################
  ### Show/Hide ###
  #################

  show: ->
    @$(".faq-modal").modal(
      backdrop: 'static'
      keyboard: false
    ).show()

  hide: ->
    @$(".faq-modal").modal "hide"
