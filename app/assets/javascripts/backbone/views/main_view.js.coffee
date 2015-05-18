class TuringEmailApp.Views.Main extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/main"]

  events:
    "click .tm_compose-button": "compose"
    "click .tm_toptabs a": "updateActiveTab"

  initialize: (options) ->
    super(options)

    @app = options.app
    @emailTemplatesJSON = options.emailTemplatesJSON
    @uploadAttachmentPostJSON = options.uploadAttachmentPostJSON

    $(window).resize((evt) => @onWindowResize(evt))

    @toolbarView = new TuringEmailApp.Views.ToolbarView(
      app: @app
      demoMode: @app.models.userConfiguration.get("demo_mode_enabled")
    )

  render: ->
    @$el.html(@template())

    @primaryPaneDiv = @$(".tm_primary")

    @renderThreadsToolbar()

    @primaryPaneDiv.append('<div class="tm_mail-email-thread-loading" style="display: block;"><svg class="icon busy-indicator"><use xlink:href="/images/symbols.svg#busy-indicator"></use></svg><span>Loading...</span></div>')

    @sidebarView = new @app.Views.SidebarView(
      el: @$(".tm_sidebar")
    )
    @sidebarView.render()

    @composeView = new TuringEmailApp.Views.ModalComposeView(
      app: @app
      el: @$(".compose-view")
      uploadAttachmentPostJSON: @uploadAttachmentPostJSON
    )
    @composeView.render()

    @templateComposeView = new TuringEmailApp.Views.TemplateComposeView(
      app: @app
      el: @$(".template-compose-view")
    )
    @templateComposeView.render()

    @createFolderView = new TuringEmailApp.Views.CreateFolderView(
      app: @app
      el: @$(".create-folder-view")
    )
    @createFolderView.render()

    @resize()

  renderThreadsToolbar: ->
    @primaryPaneDiv.append(@toolbarView.$el)
    @toolbarView.render()
    @toolbarView.$el.find(".threads-toolbar").show()

  renderSharedToolbar: ->
    @primaryPaneDiv.append(@toolbarView.$el)
    @toolbarView.render()
    @toolbarView.$el.find(".threads-toolbar").hide()

  createEmailThreadsListView: (emailThreads) ->
    @emailThreadsListView = new TuringEmailApp.Views.PrimaryPane.EmailThreads.ListView(
      app: @app
      collection: emailThreads
    )

    return @emailThreadsListView

  compose: ->
    @app.views.composeView.loadEmpty()
    @app.views.composeView.loadEmailSignature()
    @app.views.composeView.show()

  composeWithSendLaterDatetime: (sendLaterDatetime) ->
    @compose()
    @app.views.composeView.sendLaterDatetimeIs(sendLaterDatetime)

  loadEmailDelayed: (delayedEmail) ->
    @composeView.loadEmailDelayed(delayedEmail)
    @composeView.show()

  updateActiveTab: (evt) ->
    @$(".tm_toptabs a.active").removeClass("active")
    $(evt.target).addClass("active")

  ########################
  ### Resize Functions ###
  ########################

  onWindowResize: (evt) ->
    @resize()

  resize: ->
    @resizeSidebar()
    @resizePrimaryPane()
    @resizePrimarySplitPane()
    @resizeAppsSplitPane()

  resizeSidebar: ->
    return if not @sidebarView?

    height = $(window).height() - @sidebarView.$el.offset().top
    @sidebarView.$el.height(height)

  resizePrimaryPane: ->
    return if not @primaryPaneDiv?

    height = $(window).height() - @primaryPaneDiv.offset().top
    @primaryPaneDiv.height(height)

  resizePrimarySplitPane: ->
    primarySplitPaneDiv = @$(".tm_mail-split-pane")
    return if primarySplitPaneDiv.length is 0

    height = $(window).height() - primarySplitPaneDiv.offset().top
    height = 1 if height <= 0

    primarySplitPaneDiv.height(height)

  resizeAppsSplitPane: ->
    appsSplitPaneDiv = @$(".apps_split_pane")
    return if appsSplitPaneDiv.length is 0

    height = $(window).height() - appsSplitPaneDiv.offset().top - 20
    height = 1 if height <= 0

    appsSplitPaneDiv.height(height)

  ######################
  ### View Functions ###
  ######################

  showEmails: (isSplitPaneMode) ->
    return false if not @primaryPaneDiv?

    @primaryPaneDiv.html("")

    email_threads_wrapper_template = JST["backbone/templates/primary_pane/email_threads/email_threads_wrapper"]
    emailThreadsListViewDiv = $(email_threads_wrapper_template(inbox_tabs_enabled: @app.models.userConfiguration.get("inbox_tabs_enabled"), emailFolderID: @app.selectedEmailFolderID()))

    @renderThreadsToolbar()

    if isSplitPaneMode
      primarySplitPane = $("<div />", {class: "tm_mail-split-pane"}).appendTo(@primaryPaneDiv)

      if @emailThreadsListView.collection.length is 0
        emptyFolderMessageDiv = $("<div />", {class: "tm_mail-box ui-layout-center"}).appendTo(primarySplitPane)
      else
        emailThreadsListViewDiv.addClass("ui-layout-center")
        primarySplitPane.append(emailThreadsListViewDiv)

      emailThreadViewDiv = $("<div class='tm_mail-view'><div class='tm_empty-pane'>No conversations selected</div></div>").appendTo(primarySplitPane)

      if @app.models.userConfiguration.get("split_pane_mode") is "horizontal"
        emailThreadViewDiv.addClass("ui-layout-south")
        primarySplitPane.addClass("horizontal-split-pane")
      else if @app.models.userConfiguration.get("split_pane_mode") is "vertical"
        emailThreadViewDiv.addClass("ui-layout-east")
        primarySplitPane.addClass("vertical-split-pane")

      @resizePrimarySplitPane()

      @splitPaneLayout = primarySplitPane.layout({
        applyDefaultStyles: false,
        resizable: true,
        closable: false,
        resizerDragOpacity: 0,
        livePaneResizing: true,
        showDebugMessages: true,
        spacing_open: 30,
        spacing_closed: 30,
        east__minSize: 300,
        south__minSize: 100,

        east__size: if @splitPaneLayout? then @splitPaneLayout.state.east.size else 0.75,
        south__size: if @splitPaneLayout? then @splitPaneLayout.state.south.size else 0.5,
        south__onresize: => @resizeAppsSplitPane()
      })
    else
      if @emailThreadsListView.collection.length is 0
        emptyFolderMessageDiv = @primaryPaneDiv
      else
        emailThreadsListViewDiv.addClass("no-split-pane")
        @primaryPaneDiv.append(emailThreadsListViewDiv)

    if @emailThreadsListView.collection.length is 0
      if @app.selectedEmailFolderID() is "INBOX"
        emptyFolderMessageDiv.append("<div class='tm_empty-pane'>Congratulations on reaching inbox zero!</div>")
      else
        emptyFolderMessageDiv.append("<div class='tm_empty-pane'>There are no conversations with this label</div>")
      @toolbarView.showRefreshToolbarButton()
    else
      @emailThreadsListView.$el = @$(".tm_table-mail-body")
      @emailThreadsListView.render()
      @toolbarView.hideRefreshToolbarButton()

    return true

  showAppsLibrary: ->
    return false if not @primaryPaneDiv?

    apps = new TuringEmailApp.Collections.AppsCollection()
    apps.fetch(reset: true)
    appsLibraryView = new TuringEmailApp.Views.PrimaryPane.AppsLibrary.AppsLibraryView({
      collection: apps,
      developer_enabled: @app.models.userConfiguration.get("developer_enabled")
    })
    appsLibraryView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar()
    @primaryPaneDiv.append(appsLibraryView.$el)

    return appsLibraryView

  showScheduleEmails: ->
    return false if not @primaryPaneDiv?

    scheduleEmails = new TuringEmailApp.Collections.DelayedEmailsCollection()
    scheduleEmails.fetch(reset: true)

    # Catch "addScheduleEmail" event and add new schedule emails to the collection
    # This will update the schedule email view when the user adds new schedule email
    scheduleEmails.listenTo @composeView, "addScheduleEmail", (scheduleEmail) ->
      @add scheduleEmail

    scheduleEmailsView = new TuringEmailApp.Views.PrimaryPane.ScheduleEmailsView({
      collection: scheduleEmails
    })
    scheduleEmailsView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar()
    @primaryPaneDiv.append(scheduleEmailsView.$el)

    return scheduleEmailsView

  showEmailTrackers: ->
    return false if not @primaryPaneDiv?

    emailTrackers = new TuringEmailApp.Collections.EmailTrackersCollection()
    emailTrackers.fetch(reset: true)
    emailTrackersView = new TuringEmailApp.Views.PrimaryPane.EmailTrackersView({
      collection: emailTrackers
    })
    emailTrackersView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar()
    @primaryPaneDiv.append(emailTrackersView.$el)

    return emailTrackersView

  showEmailSignatures: (emailSignatureCategoryUID) ->
    return false if not @primaryPaneDiv?

    emailSignatures = new TuringEmailApp.Collections.EmailSignaturesCollection()
    emailSignatures.fetch(reset: true)

    @emailSignaturesView = new TuringEmailApp.Views.PrimaryPane.EmailSignaturesView(
      app: @app
      emailSignatures: emailSignatures
      emailSignatureUID: @app.models.userConfiguration.get("email_signature_uid")
    )
    @emailSignaturesView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar()
    @primaryPaneDiv.append(@emailSignaturesView.$el)

    return @emailSignaturesView

  showEmailTemplates: (emailTemplateCategoryUID) ->
    return false if not @primaryPaneDiv?

    if emailTemplateCategoryUID == "-1" or not emailTemplateCategoryUID
      emailTemplateCategoryUID = ""

    emailTemplatesView = new TuringEmailApp.Views.PrimaryPane.EmailTemplates.EmailTemplatesView({
      categoryUID: emailTemplateCategoryUID
    })
    emailTemplatesView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar()
    @primaryPaneDiv.append(emailTemplatesView.$el)

    return emailTemplatesView

  showEmailTemplateCategories: ->
    return false if not @primaryPaneDiv?

    emailTemplateCategoriesView = new TuringEmailApp.Views.PrimaryPane.EmailTemplates.EmailTemplateCategoriesView({
      collection: @app.collections.emailTemplateCategories
      templatesCollection: @app.collections.emailTemplates
    })
    emailTemplateCategoriesView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar()
    @primaryPaneDiv.append(emailTemplateCategoriesView.$el)

    return emailTemplateCategoriesView

  showListSubscriptions: ->
    return false if not @primaryPaneDiv?

    listSubscriptions = new TuringEmailApp.Collections.ListSubscriptionsCollection()
    listSubscriptions.fetch(reset: true)
    listSubscriptionsView = new TuringEmailApp.Views.PrimaryPane.ListSubscriptionsView({
      collection: listSubscriptions
    })
    listSubscriptionsView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar()
    @primaryPaneDiv.append(listSubscriptionsView.$el)

    return listSubscriptionsView

  showInboxCleaner: ->
    return false if not @primaryPaneDiv?

    cleanerReport = new TuringEmailApp.Models.CleanerReport()
    cleanerReport.fetch(reset: true)
    inboxCleanerView = new TuringEmailApp.Views.PrimaryPane.InboxCleanerView({
      app: @app
      model: cleanerReport
    })
    inboxCleanerView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar()
    @primaryPaneDiv.append(inboxCleanerView.$el)

    return inboxCleanerView

  showSettings: ->
    return false if not @primaryPaneDiv?

    settingsView = new TuringEmailApp.Views.PrimaryPane.Settings.SettingsView(
      model: @app.models.userConfiguration
    )
    settingsView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar()
    @primaryPaneDiv.append(settingsView.$el)

    return settingsView

  showAnalytics: ->
    return false if not @primaryPaneDiv?

    analyticsView = new TuringEmailApp.Views.PrimaryPane.Analytics.AnalyticsView()
    analyticsView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar()
    @primaryPaneDiv.append(analyticsView.$el)

    return analyticsView

  showReport: (ReportModel, ReportView) ->
    return false if not @primaryPaneDiv?

    reportModel = new ReportModel()
    reportView = new ReportView(
      model: reportModel
    )

    @primaryPaneDiv.html("")
    @primaryPaneDiv.append(reportView.$el)

    reportModel.fetch(reset: true)

    return reportView

  showEmailThread: (emailThread, isSplitPaneMode) ->
    return false if not @primaryPaneDiv?

    @stopListening(@currentEmailThreadView) if @currentEmailThreadView?
    @currentEmailThreadView = emailThreadView = new TuringEmailApp.Views.PrimaryPane.EmailThreads.EmailThreadView(
      app: @app
      model: emailThread
      emailTemplatesJSON: @emailTemplatesJSON
      uploadAttachmentPostJSON: @uploadAttachmentPostJSON
    )

    if isSplitPaneMode
      emailThreadViewDiv = @$(".tm_mail-view")

      if emailThreadViewDiv.length is 0
        @showEmails(isSplitPaneMode)
        emailThreadViewDiv = @$(".tm_mail-view")
    else
      emailThreadViewDiv = @primaryPaneDiv

    emailThreadViewDiv.html("")

    if @app.models.userConfiguration?.get("installed_apps")?.length > 0
      appsSplitPane = $("<div />", {class: "apps_split_pane"}).appendTo(emailThreadViewDiv)

      emailThreadView.$el.addClass("ui-layout-center")
      appsSplitPane.append(emailThreadView.$el)
      emailThreadView.render()

      appsDiv = $("<div />").appendTo(appsSplitPane)
      appsDiv.addClass("ui-layout-east")
      appsDiv.attr("style", "overflow: hidden !important; padding: 0px !important;")

      @runApps(appsDiv, emailThread) if emailThread?
      @listenTo(@currentEmailThreadView, "expand:email", (emailThreadView, emailJSON) => @runApps(appsDiv, emailJSON))

      @resizeAppsSplitPane()

      appsSplitPane.layout({
        applyDefaultStyles: true,
        resizable: false,
        closable: false,
        livePaneResizing: true,
        showDebugMessages: true,

        east__size: 200
      })
    else
      emailThreadViewDiv.off("resize")
      emailThreadViewDiv.html(emailThreadView.$el)
      emailThreadView.render()

    if not isSplitPaneMode
      emailThreadViewDiv.prepend(@toolbarView.$el)
      @toolbarView.render()
      emailThreadView.$el.addClass("tm_content")

    return emailThreadView

  runApps: (appsDiv, object) ->
    appsDiv.html("")

    for installedAppJSON in @app.models.userConfiguration.get("installed_apps")
      appIframe = $("<iframe></iframe>").appendTo(appsDiv)
      appIframe.css("width", "100%")
      appIframe.css("height", "100%")
      installedApp = TuringEmailApp.Models.InstalledApps.InstalledApp.CreateFromJSON(installedAppJSON)
      installedApp.run(appIframe, object)

  showWelcomeTour: ->
    @tourView = new TuringEmailApp.Views.TourView(
      el: @$(".tour-view")
    )
    @tourView.render()

  showAbout: ->
    @aboutView = new TuringEmailApp.Views.AboutView(
      el: @$(".about-view")
    )
    @aboutView.render()

  showFAQ: ->
    @faqView = new TuringEmailApp.Views.FAQView(
      el: @$(".faq-view")
    )
    @faqView.render()

  showPrivacy: ->
    @privacyView = new TuringEmailApp.Views.PrivacyView(
      el: @$(".privacy-view")
    )
    @privacyView.render()

  showTerms: ->
    @termsView = new TuringEmailApp.Views.TermsView(
      el: @$(".terms-view")
    )
    @termsView.render()
