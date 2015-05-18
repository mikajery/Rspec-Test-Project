class TuringEmailApp.Routers.BaseRouter extends Backbone.Router
  execute: (callback, args) ->
    route = window.location.hash

    # Update top bar
    $('.tm_toptabs a.active').removeClass("active")
    $('.tm_toptabs a[href="' + route + '"]').addClass("active")

    # Update side bar
    $('.tm_folders a.tm_folder-selected').removeClass("tm_folder-selected")
    $('.tm_folders a[href="' + route + '"]').addClass("tm_folder-selected")

    super(callback, args)
