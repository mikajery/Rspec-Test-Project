class TuringEmailApp.Views.WebsitePreviewView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/compose/website_preview"]

  events:
    "click .compose-link-preview-close-button": "hide"

  initialize: ->
    @listenTo(@model, "change", @render)

  render: ->
    @$el.append(@template(@model.toJSON()))

    @

  hide: ->
    @$(".compose-link-preview").remove()
