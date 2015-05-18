class TuringEmailApp.Routers.EmailFoldersRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "email_folder/:emailFolderID": "showFolder"
    "email_folder/:emailFolderID/:pageTokenIndex": "showFolderPage"
    "email_folder/:emailFolderID/:pageTokenIndex/:lastEmailThreadUID/:dir": "showFolderPageDir"

  showFolder: (emailFolderID) ->
    TuringEmailApp.currentEmailFolderIs(emailFolderID)

  showFolderPage: (emailFolderID, pageTokenIndex) ->
    TuringEmailApp.currentEmailFolderIs(emailFolderID, pageTokenIndex)

  showFolderPageDir: (emailFolderID, pageTokenIndex, lastEmailThreadUID, dir) ->
    TuringEmailApp.currentEmailFolderIs(emailFolderID, pageTokenIndex, lastEmailThreadUID, dir)
