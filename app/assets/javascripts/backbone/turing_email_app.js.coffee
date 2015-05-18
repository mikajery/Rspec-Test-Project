#= require_self
#= require_tree ./core
#= require_tree ./templates
#= require_tree ./validations
#= require ./models/email
#= require ./models/installed_apps/installed_app
#= require_tree ./models
#= require ./collections/base_collection
#= require_tree ./collections
#= require ./views/collection_view
#= require ./views/primary_pane/email_threads/list_item_view
#= require ./views/primary_pane/email_threads/list_view
#= require ./views/primary_pane/analytics/reports/report_view
#= require ./views/compose/compose_view
#= require ./views/toolbar/toolbar_view
#= require_tree ./views
#= require_tree ./routers

window.backboneWrapError = (model, options) ->
  error = options.error
  options.error = (resp) ->
    error model, resp, options  if error
    model.trigger "error", model, resp, options
    return

  return

window.TuringEmailApp = new(Backbone.View.extend(
  Models: {}
  Views: {}
  Collections: {}
  Routers: {}

  setupListeners: (source) ->
    @listenTo(source, arg, @[arg]) for arg in _.rest(arguments)

  threadsListInboxCountRequest: ->
    params =
      userId: "me"
      labelIds: "INBOX"
      fields: "resultSizeEstimate"

    gapi.client.gmail.users.messages.list(params)

  start: (userJSON, userConfigurationJSON, emailTemplateCategoriesJSON, emailTemplatesJSON, uploadAttachmentPostJSON, emailFoldersJSON) ->
    @models = {}
    @views = {}
    @collections = {}
    @routers = {}

    @setupUser(userJSON, userConfigurationJSON)

    @setupGmailAPI()

    @setupKeyboardHandler()

    # email template categories
    @setupEmailTemplateCategories()
    @loadEmailTemplateCategories emailTemplateCategoriesJSON

    # email templates
    @setupEmailTemplates()
    @loadEmailTemplates emailTemplatesJSON

    @setupMainView emailTemplatesJSON, uploadAttachmentPostJSON

    @setupToolbar()

    @setupComposeView()
    @setupCreateFolderView()
    @setupEmailThreads()
    @setupRouters()

    # email folders
    @setupEmailFolders()
    @loadEmailFolders emailFoldersJSON

    Backbone.history.start() if not Backbone.History.started

    windowLocationHash = window.location.hash.toString()
    if windowLocationHash is ""
      @routers.emailFoldersRouter.navigate("#email_folder/INBOX", trigger: true)

    @setupSyncTimeout()
    @setupObserver()

  #######################
  ### Setup Functions ###
  #######################

  setupObserver: ->
    observe = =>
      excluded = []
      for view in @_observedViews
        present = document.body.contains(view.$el[0])
        if (view._rendered && !present)
          view.remove()
          view._rendered = false
          excluded.push view
        else if (!view._rendered && present)
          view._rendered = true
      @_observedViews = _.difference @_observedViews, excluded

    # Assigning to member variable just to make sure it won't be removed by
    # the garbage collector
    if MutationObserver?
      @observer = new MutationObserver observe
      @observer.observe document.body, "childList": true, "subtree": true
    else
      @observer = window.setInterval observe, 10000

  setupSyncTimeout: ->
    if @syncTimeout
      clearTimeout @syncTimeout
      @syncTimeout = null

    @syncTimeout = window.setTimeout(=>
      @syncEmail()
    , 60000)

  setupGmailAPI: ->
    @gmailAPIReady = false

    gapi.client.load("gmail", "v1").then(=>
      @refreshGmailAPIToken().done(=>
        @gmailAPIReady = true
      )

      return
    )

  refreshGmailAPIToken: ->
    $.get("/api/v1/gmail_accounts/get_token").done(
      (data, status) ->
        gapi.auth.setToken(data)
    )

  setupKeyboardHandler: ->
    @keyboardHandler = new TuringEmailAppKeyboardHandler(this)
    @keyboardHandler.start() if @models.userConfiguration.get("keyboard_shortcuts_enabled")

  setupMainView: (emailTemplatesJSON, uploadAttachmentPostJSON) ->
    @views.mainView = new TuringEmailApp.Views.Main(
      app: TuringEmailApp
      el: $("#main")
      emailTemplatesJSON: emailTemplatesJSON
      uploadAttachmentPostJSON: uploadAttachmentPostJSON
    )
    @views.mainView.render()

  setupToolbar: ->
    @views.toolbarView = @views.mainView.toolbarView

    @setupListeners(@views.toolbarView,
                    "checkAllClicked",
                    "checkAllReadClicked",
                    "checkAllUnreadClicked",
                    "uncheckAllClicked",
                    "readClicked",
                    "unreadClicked",
                    "trashClicked",
                    "snoozeClicked",
                    "archiveClicked",
                    "refreshClicked",
                    "pauseClicked",
                    "createNewLabelClicked",
                    "createNewEmailFolderClicked",
                    "demoModeSwitchClicked")

    @listenTo(@views.toolbarView, "labelAsClicked", (toolbarView, labelID) => @labelAsClicked(labelID))
    @listenTo(@views.toolbarView, "moveToFolderClicked", (toolbarView, folderID) => @moveToFolderClicked(folderID))
    @listenTo(@views.toolbarView, "searchClicked", (toolbarView, query) => @searchClicked(query))

    @trigger("change:toolbarView", this, @views.toolbarView)

  setupUser: (userJSON, userConfigurationJSON) ->
    @models.user = new TuringEmailApp.Models.User(userJSON)
    @models.userConfiguration = new TuringEmailApp.Models.UserConfiguration(userConfigurationJSON)

    @listenTo(@models.userConfiguration, "change:demo_mode_enabled", =>
      @collections.emailFolders.demoMode = @models.userConfiguration.get("demo_mode_enabled")
      @collections.emailThreads.demoMode = @models.userConfiguration.get("demo_mode_enabled")
      @views.toolbarView.demoMode = @models.userConfiguration.get("demo_mode_enabled")

      @reloadEmailThreads()
      @loadEmailFolders()
      @views.toolbarView.render()
    )

    @listenTo(@models.userConfiguration, "change:keyboard_shortcuts_enabled", =>
      if @models.userConfiguration.get("keyboard_shortcuts_enabled")
        @keyboardHandler.start()
      else
        @keyboardHandler.stop()
    )

  setupEmailFolders: ->
    @collections.emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection(undefined,
      app: TuringEmailApp
      demoMode: @models.userConfiguration.get("demo_mode_enabled")
    )
    @views.emailFoldersTreeView = new TuringEmailApp.Views.TreeView(
      app: this
      el: $(".tm_email-folders")
      collection: @collections.emailFolders
    )

    @listenTo(@views.emailFoldersTreeView, "emailFolderSelected", @emailFolderSelected)

  setupEmailTemplateCategories: ->
    @collections.emailTemplateCategories = new TuringEmailApp.Collections.EmailTemplateCategoriesCollection()

  setupEmailTemplates: ->
    @collections.emailTemplates = new TuringEmailApp.Collections.EmailTemplatesCollection()

  setupComposeView: ->
    @views.composeView = @views.mainView.composeView

    @listenTo(@views.composeView, "change:draft", @draftChanged)
    @listenTo(@views.composeView, "archiveClicked", @archiveClicked)

  setupCreateFolderView: ->
    @views.createFolderView = @views.mainView.createFolderView

    @listenTo(@views.createFolderView, "createFolderFormSubmitted", (createFolderView, mode, folderName) => @createFolderFormSubmitted(mode, folderName))

  setupEmailThreads: ->
    @collections.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
      app: this
      demoMode: @models.userConfiguration.get("demo_mode_enabled")
    )
    @views.emailThreadsListView = @views.mainView.createEmailThreadsListView(@collections.emailThreads)

    @listenTo(@views.emailThreadsListView, "listItemSelected", @listItemSelected)
    @listenTo(@views.emailThreadsListView, "listItemDeselected", @listItemDeselected)
    @listenTo(@views.emailThreadsListView, "listItemChecked", @listItemChecked)
    @listenTo(@views.emailThreadsListView, "listItemUnchecked", @listItemUnchecked)
    @listenTo(@views.emailThreadsListView, "listViewBottomReached", @listViewBottomReached)

  setupRouters: ->
    for k, v of TuringEmailApp.Routers
      routerName = k[0].toLowerCase() + k[1..]
      @routers[routerName] = new v

  ###############
  ### Getters ###
  ###############

  selectedEmailThread: ->
    return @views.emailThreadsListView.selectedItem()

  selectedEmailFolder: ->
    return @views.emailFoldersTreeView.selectedItem()

  selectedEmailFolderID: ->
    return @views.emailFoldersTreeView.selectedItem()?.get("label_id")

  ###############
  ### Setters ###
  ###############

  currentEmailThreadIs: (emailThreadUID=".", refresh=false) ->
    loadEmailThreadCallback = (emailThread) =>
      # Do short-circuit only when refresh is false
      return if not refresh and @currentEmailThreadView?.model is emailThread

      if @views.emailThreadsListView.collection.length is 0
        @currentEmailFolderIs emailThread.primaryEmailFolder()

      @views.emailThreadsListView.select(emailThread, silent: true)
      @showEmailThread(emailThread)

      @views.toolbarView.uncheckAllCheckbox()

      @trigger "change:selectedEmailThread", this, emailThread

    # if refresh, reload the current email thread if exists
    if refresh
      loadEmailThreadCallback @currentEmailThreadView.model if @currentEmailThreadView?.model
    else if emailThreadUID != "."
      @loadEmailThread(emailThreadUID, loadEmailThreadCallback)
    else
      # do the show show first so then if the select below triggers this again it will exit above
      @showEmailThread()
      @views.emailThreadsListView.deselect()
      @views.toolbarView.uncheckAllCheckbox()

      @trigger "change:selectedEmailThread", this, null

  currentEmailFolderIs: (emailFolderID, pageTokenIndex, lastEmailThreadUID=null, dir="DESC") ->
    @searchQuery = undefined

    @collections.emailThreads.folderIDIs(emailFolderID)
    @collections.emailThreads.pageTokenIndexIs(parseInt(pageTokenIndex))  if pageTokenIndex?
    @collections.emailThreads.setupURL(lastEmailThreadUID, dir) if @models.userConfiguration.get("demo_mode_enabled")

    reset = not pageTokenIndex?
    lastItem = @collections.emailThreads.last()

    @reloadEmailThreads(
      skipRender: true
      reset: reset

      success: (collection, response, options) =>
        emailFolder = @collections.emailFolders.get(emailFolderID)
        @views.emailFoldersTreeView.select(emailFolder, silent: true)
        @trigger("change:currentEmailFolder", this, emailFolder, @collections.emailThreads.pageTokenIndex + 1)

        @showEmails()
        @views.emailThreadsListView.scrollListItemIntoView(lastItem, "bottom") if !reset

        if @isSplitPaneMode() && @collections.emailThreads.length > 0
          @currentEmailThreadIs(@collections.emailThreads.models[0].get("uid"))
    )

  ######################
  ### Sync Functions ###
  ######################

  syncEmail: ->
    reload = =>
      @reloadEmailThreads()
      @loadEmailFolders()

    if !@models.userConfiguration.get("demo_mode_enabled")
      reload()
    else
      $.post("api/v1/email_accounts/sync", undefined, undefined).done(
        (data) =>
          last_email_update = new Date(data)

          if not @last_email_update || last_email_update > @last_email_update
            @last_email_update = last_email_update
            reload()
      )

    @setupSyncTimeout()

  #######################
  ### Alert Functions ###
  #######################

  showAlert: (text, classType, removeAfterSeconds) ->
    @removeAlert(@currentAlert.token) if @currentAlert?

    @currentAlert = new TuringEmailApp.Views.AlertView(
      text: text
      classType: classType
    )
    @currentAlert.render()

    $(@currentAlert.el).prependTo('body').addClass('tm_alert-animated')

    token = @currentAlert.token
    setTimeout (=>
      @removeAlert(token)
    ), removeAfterSeconds if removeAfterSeconds?

    return @currentAlert.token

  removeAlert: (token) ->
    return if not @currentAlert? || @currentAlert.token != token
    $(@currentAlert.el).fadeOut('fast', ->
      $(@).remove()
    )
    @currentAlert = undefined

  ##############################
  ### Email Folder Functions ###
  ##############################

  loadEmailFolders: (emailFoldersJSON) ->
    # load from json, if json is provided
    if emailFoldersJSON
      @collections.emailFolders.reset emailFoldersJSON

      @trigger("change:emailFolders", @, @collections.emailFolders)
      @trigger("change:currentEmailFolder", @, @selectedEmailFolder(), @collections.emailThreads.pageTokenIndex + 1)
    else
      @collections.emailFolders.fetch(
        reset: true

        success: (collection, response, options) =>
          @trigger("change:emailFolders", this, collection)
          @trigger("change:currentEmailFolder", this, @selectedEmailFolder(), @collections.emailThreads.pageTokenIndex + 1)
      )

  ###########################################
  ### Email Template Categories Functions ###
  ###########################################

  loadEmailTemplateCategories: (emailTemplateCategoriesJSON) ->
    # load from json, if json is provided
    if emailTemplateCategoriesJSON
      @collections.emailTemplateCategories.reset emailTemplateCategoriesJSON
    else
      @collections.emailTemplateCategories.fetch(reset: true)

  ###########################################
  ### Email Template Categories Functions ###
  ###########################################

  loadEmailTemplates: (emailTemplatesJSON) ->
    # load from json, if json is provided
    if emailTemplatesJSON
      @collections.emailTemplates.reset emailTemplatesJSON
    else
      @collections.emailTemplates.fetch(reset: true)

  ##############################
  ### Email Thread Functions ###
  ##############################

  loadEmailThread: (emailThreadUID, callback) ->
    emailThread = @collections.emailThreads?.get(emailThreadUID)

    if emailThread?
      callback(emailThread)
    else
      emailThread = new TuringEmailApp.Models.EmailThread(undefined,
        app: TuringEmailApp
        emailThreadUID: emailThreadUID
        demoMode: @models.userConfiguration.get("demo_mode_enabled")
      )
      emailThread.fetch(
        success: (model, response, options) ->
          callback?(emailThread)
      )

  reloadEmailThreads: (myOptions=skipRender: false, reset: true) ->
    selectedEmailThread = @selectedEmailThread()

    @views.emailThreadsListView.skipRender = myOptions.skipRender

    @collections.emailThreads.fetch(
      query: myOptions.query
      reset: myOptions.reset
      remove: myOptions.reset

      success: (collection, response, options) =>
        @views.emailThreadsListView.skipRender = false

        if options.previousModels?
          @stopListening(emailThread) for emailThread in options.previousModels

        for emailThread in collection.models
          @listenTo(emailThread, "change:seen", @emailThreadSeenChanged)
          @listenTo(emailThread, "change:folder", @emailThreadFolderChanged)

        if selectedEmailThread? && not @selectedEmailThread()?
          emailThreadToSelect = collection.get(selectedEmailThread.get("uid"))

          if emailThreadToSelect?
            @ignoreListItemSelected = true
            @views.emailThreadsListView.select(emailThreadToSelect)
            @ignoreListItemSelected = false

        @views.mainView.resize()
        myOptions.success(collection, response, options) if myOptions?.success?

      error: (collection, response, options) =>
        @views.emailThreadsListView.skipRender = false

        myOptions.error(collection, response, options) if myOptions?.error?
    )

  loadSearchResults: (query, reset = true) ->
    @searchQuery = query
    @collections.emailThreads.resetPageTokens() if reset

    lastItem = @collections.emailThreads.last()

    @reloadEmailThreads(
      query: query
      skipRender: true
      reset: reset

      success: (collection, response, options) =>
        @showEmails()
        @views.emailThreadsListView.scrollListItemIntoView(lastItem, "bottom") if !reset
    )

  applyActionToSelectedThreads: (singleAction, multiAction, remove=false, clearSelection=false, refreshFolders=false, moveSelection=false) ->
    checkedListItemViews = @views.emailThreadsListView.getCheckedListItemViews()

    if checkedListItemViews.length == 0
      selectedIndex = @views.emailThreadsListView.selectedIndex()
      singleAction()
      @collections.emailThreads.remove @selectedEmailThread() if remove
      (if @isSplitPaneMode() then @currentEmailThreadIs() else @goBackClicked()) if clearSelection and not moveSelection
      @views.emailThreadsListView.selectedIndexIs selectedIndex if moveSelection
    else
      selectedEmailThreads = []
      selectedEmailThreadUIDs = []

      for listItemView in checkedListItemViews
        selectedEmailThreads.push(listItemView.model)
        selectedEmailThreadUIDs.push(listItemView.model.get("uid"))

      multiAction(checkedListItemViews, selectedEmailThreadUIDs)

      @collections.emailThreads.remove selectedEmailThreads if remove

      (if @isSplitPaneMode() then @currentEmailThreadIs() else @goBackClicked()) if clearSelection

    @loadEmailFolders() if refreshFolders

  ######################
  ### General Events ###
  ######################

  checkAllClicked: ->
    @views.emailThreadsListView.checkAll()

  checkAllReadClicked: ->
    @views.emailThreadsListView.checkAllRead()

  checkAllUnreadClicked: ->
    @views.emailThreadsListView.checkAllUnread()

  uncheckAllClicked: ->
    @views.emailThreadsListView.uncheckAll()

  readClickedIs: (isRead) ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.setSeen(isRead)
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        @collections.emailThreads.emailThreadsSeenIs(selectedEmailThreadUIDs, isRead)

        for listItemView in checkedListItemViews
          listItemView.model.setSeen(isRead, silent: true)
          listItemView.uncheck()
          listItemView.removeCheckStyles()
      false, false
    )

  readClicked: ->
    @readClickedIs true

  unreadClicked: ->
    @readClickedIs false

  labelAsClicked: (labelID, labelName) ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.applyGmailLabel(labelID, labelName)
      (checkedListItemViews, selectedEmailThreadUIDs) ->
        TuringEmailApp.Models.EmailThread.applyGmailLabel(TuringEmailApp, selectedEmailThreadUIDs, labelID, labelName)
      false, false
    )

  moveToFolderClicked: (folderID, folderName) ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.moveToFolder(folderID, folderName)
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        for emailThreadUID in selectedEmailThreadUIDs
          @collections.emailThreads.get(emailThreadUID).moveToFolder(folderID, folderName)
      true, true, true, true
    )

  refreshClicked: ->
    @reloadEmailThreads()

  pauseClicked: ->
    clearTimeout(@syncTimeout)
    @syncTimeout = null
    @showAlert("Email sync paused.", "alert-success", 5000)

  searchClicked: (query) ->
    if query
      @routers.searchResultsRouter.navigate("#search/" + query, trigger: true)
    else
      @routers.emailFoldersRouter.navigate("#email_folder/INBOX", trigger: true)


  goBackClicked: ->
    @routers.emailFoldersRouter.showFolder(@selectedEmailFolderID())

  responseClicked: (responseType) ->
    return false if not @selectedEmailThread()?

    @showEmailEditorWithEmailThread(@selectedEmailThread().get("uid"), responseType)
    return @selectedEmailThread()

  replyClicked: ->
    @responseClicked "reply"

  replyToAllClicked: ->
    @responseClicked "reply-to-all"

  forwardClicked: ->
    @responseClicked "forward"

  archiveClicked: ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.removeFromFolder(@selectedEmailFolderID())
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.removeFromFolder(TuringEmailApp, selectedEmailThreadUIDs, @selectedEmailFolderID())
      true, true, true, true
    )

  trashClicked: ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.trash()
      (checkedListItemViews, selectedEmailThreadUIDs) ->
        TuringEmailApp.Models.EmailThread.trash(TuringEmailApp, selectedEmailThreadUIDs)
      true, true, true, true
    )

  snoozeClicked: (view, minutes) ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.snooze(minutes)
      (checkedListItemViews, selectedEmailThreadUIDs) ->
        TuringEmailApp.Models.EmailThread.snooze(TuringEmailApp, selectedEmailThreadUIDs, minutes)
      true, true, true, true
    )

  createNewLabelClicked: ->
    @views.createFolderView.show("label")

  createNewEmailFolderClicked: ->
    @views.createFolderView.show("folder")

  demoModeSwitchClicked: (demoMode) ->
    @models.userConfiguration.set("demo_mode_enabled", demoMode)
    @showAlert("Changing mode... just a minute please", "alert-success", 2000)

    @models.userConfiguration.save(null, {
      patch: true
      success: (model, response) =>
        if demoMode
          @showAlert("You are now viewing Turing mode - look how few emails there are!", "alert-success", 15000)
        else
          @showAlert("You are now viewing your live Gmail account - look how many emails there are!", "alert-success", 15000)
      }
    )

  installAppClicked: (view, appID) ->
    TuringEmailApp.Models.App.Install(appID)
    @models.userConfiguration.fetch(reset: true)

  uninstallAppClicked: (view, appID) ->
    TuringEmailApp.Models.InstalledApps.InstalledApp.Uninstall(appID)
    @models.userConfiguration.fetch(reset: true)

  unsubscribeListClicked: (view, listSubscription) ->
    TuringEmailApp.Models.ListSubscription.Unsubscribe(listSubscription)

    view.collection.remove(listSubscription)
    listSubscription.set("unsubscribed", true)
    view.collection.add(listSubscription)

  resubscribeListClicked: (view, listSubscription) ->
    TuringEmailApp.Models.ListSubscription.Resubscribe(listSubscription)

    view.collection.remove(listSubscription)
    listSubscription.set("unsubscribed", false)
    view.collection.add(listSubscription)

  #############################
  ### EmailThreads.ListView ###
  #############################

  listItemSelected: (listView, listItemView) ->
    return if @ignoreListItemSelected? && @ignoreListItemSelected

    emailThread = listItemView.model
    emailThreadUID = emailThread.get("uid")

    @views.mainView.toolbarView.hideRefreshToolbarButton()
    @routers.emailThreadsRouter.navigate("#email_thread/" + emailThreadUID, trigger: true)

  listItemDeselected: (listView, listItemView) ->
    @views.mainView.toolbarView.showRefreshToolbarButton()

    @routers.emailThreadsRouter.navigate("#email_thread/.", trigger: true)

  listItemChecked: (listView, listItemView) ->
    @currentEmailThreadView.$el.hide() if @currentEmailThreadView

  listItemUnchecked: (listView, listItemView) ->
    if @views.emailThreadsListView.getCheckedListItemViews().length is 0
      @currentEmailThreadView.$el.show() if @currentEmailThreadView

  listViewBottomReached: (listView) ->
    @tryToLoadMoreEmailThreadsInFolder()

  tryToLoadMoreEmailThreadsInFolder: ->
    if @collections.emailThreads.hasNextPage()
      if not @searchQuery?
        url = "#email_folder/" + @selectedEmailFolderID()
        url += "/" + (@collections.emailThreads.pageTokenIndex + 1)
        url += "/" + @collections.emailThreads.last().get("uid") + "/DESC" if @models.userConfiguration.get("demo_mode_enabled")

        @routers.emailFoldersRouter.navigate(url, trigger: true)
      else
        if @collections.emailThreads.hasNextPage(true)
          @collections.emailThreads.pageTokenIndexIs(@collections.emailThreads.pageTokenIndex + 1)
          @loadSearchResults(@searchQuery, false)

  ####################################
  ### EmailFolders.TreeView Events ###
  ####################################

  emailFolderSelected: (treeView, emailFolder) ->
    return if not emailFolder?

    emailFolderID = emailFolder.get("label_id")

    emailFolderURL = "#email_folder/" + emailFolderID
    if window.location.hash is emailFolderURL
      @routers.emailFoldersRouter.showFolder(emailFolderID)
    else
      @routers.emailFoldersRouter.navigate("#email_folder/" + emailFolderID, trigger: true)

  ##########################
  ### ComposeView Events ###
  ##########################

  draftChanged: (composeView, draft, emailThreadParent) ->
    if emailThreadParent?
      emails = _.clone(emailThreadParent.get("emails"))

      for index in [emails.length-1 .. 0]
        email = emails[index]

        if email["draft_id"] == draft.get("draft_id")
          emails.splice(index, 1)
          break

      emails.push(draft.toJSON())
      emailThreadParent.set("emails", emails)

    @reloadEmailThreads()
    @loadEmailFolders()

  ###############################
  ### CreateFolderView Events ###
  ###############################

  createFolderFormSubmitted: (mode, folderName) ->
    if mode == "label"
      @labelAsClicked undefined, folderName
    else
      @moveToFolderClicked undefined, folderName

  ##########################
  ### EmailThread Events ###
  ##########################

  emailThreadSeenChanged: (emailThread, seenValue) ->
    delta = if seenValue then -1 else 1

    for folderID in emailThread.get("folder_ids")
      folder = @collections.emailFolders.get(folderID)
      continue if not folder?

      folder.set("num_unread_threads", folder.get("num_unread_threads") + delta)
      @trigger("change:emailFolderUnreadCount", this, folder)

  emailThreadFolderChanged: (emailThread, newFolder) ->
    folder = @collections.emailFolders.get(newFolder["label_id"])

    @loadEmailFolders() if not folder?

  ######################
  ### View Functions ###
  ######################

  isSplitPaneMode: ->
    splitPaneMode = @models.userConfiguration.get("split_pane_mode")
    return splitPaneMode is "horizontal" || splitPaneMode is "vertical"

  showEmailThread: (emailThread) ->
    emailThreadView = @views.mainView.showEmailThread(emailThread, @isSplitPaneMode())

    @listenTo(emailThreadView, "goBackClicked", @goBackClicked)
    @listenTo(emailThreadView, "replyClicked", @replyClicked)
    @listenTo(emailThreadView, "replyToAllClicked", @replyToAllClicked)
    @listenTo(emailThreadView, "forwardClicked", @forwardClicked)
    @listenTo(emailThreadView, "archiveClicked", @archiveClicked)
    @listenTo(emailThreadView, "trashClicked", @trashClicked)

    if @currentEmailThreadView?
      @stopListening(@currentEmailThreadView)
      @currentEmailThreadView.stopListening()

    @currentEmailThreadView = emailThreadView

  showEmailEditorWithEmailThread: (emailThreadUID, mode="draft") ->
    @loadEmailThread(emailThreadUID, (emailThread) =>
      @currentEmailThreadIs emailThread.get("uid")

      emails = emailThread.get("emails")

      switch mode
        when "forward"
          @views.composeView.loadEmailAsForward(_.last(emails), emailThread)
        when "reply"
          @views.composeView.loadEmailAsReply(_.last(emails), emailThread)
        when "reply-to-all"
          @views.composeView.loadEmailAsReplyToAll(_.last(emails), emailThread)
        else
          @views.composeView.loadEmailDraft(_.last(emails), emailThread)

      @views.composeView.show()
    )

  showEmails: ->
    @views.mainView.showEmails(@isSplitPaneMode())

  showAppsLibrary: ->
    @stopListening(@appsLibraryView) if @appsLibraryView

    @appsLibraryView = @views.mainView.showAppsLibrary()
    @listenTo(@appsLibraryView, "installAppClicked", @installAppClicked)

  showScheduleEmails: ->
    @scheduleEmailsView = @views.mainView.showScheduleEmails()

  showEmailTrackers: ->
    @views.mainView.showEmailTrackers()

  showEmailSignatures: ->
    @views.mainView.showEmailSignatures()

  showEmailTemplates: (emailTemplateCategoryUID) ->
    @views.mainView.showEmailTemplates(emailTemplateCategoryUID)

  showEmailTemplateCategories: ->
    @views.mainView.showEmailTemplateCategories()

  showListSubscriptions: ->
    @stopListening(@listSubscriptionsView) if @listSubscriptionsView

    @listSubscriptionsView = @views.mainView.showListSubscriptions()
    @listenTo(@listSubscriptionsView, "unsubscribeListClicked", @unsubscribeListClicked)
    @listenTo(@listSubscriptionsView, "resubscribeListClicked", @resubscribeListClicked)

  showInboxCleaner: ->
    @inboxCleanerView = @views.mainView.showInboxCleaner()

  showWelcomeTour: ->
    @showEmails()
    @views.mainView.showWelcomeTour()

  showAbout: ->
    @views.mainView.showAbout()

  showFAQ: ->
    @views.mainView.showFAQ()

  showPrivacy: ->
    @views.mainView.showPrivacy()

  showTerms: ->
    @views.mainView.showTerms()

  showSettings: ->
    @models.userConfiguration.fetch(reset: true)

    @stopListening(@settingsView) if @settingsView

    @settingsView = @views.mainView.showSettings()
    @listenTo(@settingsView, "uninstallAppClicked", @uninstallAppClicked)

  showAnalytics: ->
    @views.mainView.showAnalytics()

  showReport: (ReportModel, ReportView) ->
    @views.mainView.showReport(ReportModel, ReportView)

  ######################
  ### Misc Functions ###
  ######################

  # TODO write tests
  downloadFile: (url) ->
    if not @downloadIframe
      @downloadIframe = $("<iframe></iframe>").appendTo("body")[0]
      @downloadIframe.hidden = true

    @downloadIframe.src = url

  refreshPane: (splitMode) ->
    windowLocationHash = window.location.hash.toString()

    if /^(#email_folder)/.test windowLocationHash
      @showEmails()

      # select the current email thread only when horizontal or vertical mode
      @currentEmailThreadIs null, true if splitMode is "horizontal" or splitMode is "vertical"
    else if /^(#email_thread)/.test windowLocationHash
      @showEmails()
      @currentEmailThreadIs null, true

))(el: document.body)

TuringEmailApp.tattletale = new Tattletale('/api/v1/log.json')

$(document).ajaxError((event, jqXHR, ajaxSettings, thrownError) ->
  TuringEmailApp.tattletale.log(JSON.stringify(jqXHR))
  TuringEmailApp.tattletale.send()
)

window.onerror = (message, url, lineNumber, column, errorObj) ->
  #save error and send to server for example.
  TuringEmailApp.tattletale.log(JSON.stringify(message))
  TuringEmailApp.tattletale.log(JSON.stringify(url.toString()))
  TuringEmailApp.tattletale.log(JSON.stringify("Line number: " + lineNumber.toString()))

  if errorObj?
    TuringEmailApp.tattletale.log(JSON.stringify(errorObj.stack))

  TuringEmailApp.tattletale.send()
