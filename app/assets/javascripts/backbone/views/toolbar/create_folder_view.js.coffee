class TuringEmailApp.Views.CreateFolderView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/toolbar/create_folder"]

  initialize: (options) ->
    super(options)

    @app = options.app
  
  render: ->
    @$el.html(@template())
    
    @setupCreateFolderView()
    
    @

  setupCreateFolderView: ->
    @$(".create-folder-form").submit (evt) =>
      console.log "Creating folder..."

      @trigger "createFolderFormSubmitted", this, @mode, $(".create-folder-form .create-folder-input").val()

      @hide()

    @$(".create-folder-modal").on "hidden.bs.modal", (evt) =>
      @resetView()

  show: (mode) ->
    @mode = mode
    @$(".create-folder-modal").modal "show"
    
  hide: ->
    @$(".create-folder-modal").modal "hide"
    @resetView()

  resetView: ->
    @$(".create-folder-form .create-folder-input").val("")
