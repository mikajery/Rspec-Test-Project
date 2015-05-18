specStartedHistory = false

window.TestMode = true

oldPrettyPrinterFormat = jasmine.PrettyPrinter::format
jasmine.PrettyPrinter::format = (value) ->
  self = this
  if value instanceof Backbone.Model
    @emitObject value.attributes
  else if value instanceof Backbone.Collection
    value.each (model) ->
      self.emitScalar model.cid
      return

  else
    oldPrettyPrinterFormat.apply this, arguments
  return

window.specStopTuringEmailApp = ->
  $("#main").remove()
  $(".xdsoft_datetimepicker").remove()
  $(".redactor-toolbar-tooltip").remove()
  $(".ui-widget").remove()

window.specStartTuringEmailApp = ->
  TuringEmailApp.models = {}
  TuringEmailApp.views = {}
  TuringEmailApp.collections = {}
  TuringEmailApp.routers = {}

  $("<div />", {id: "main"}).appendTo("body")

  TuringEmailApp.models.user = new TuringEmailApp.Models.User()
  TuringEmailApp.models.userConfiguration = new TuringEmailApp.Models.UserConfiguration()

  TuringEmailApp.views.mainView = new TuringEmailApp.Views.Main(
    app: TuringEmailApp
    el: $("#main")
    uploadAttachmentPostJSON: fixture.load("upload_attachment_post.fixture.json", true)
    emailTemplatesJSON: FactoryGirl.createLists("EmailTemplate", FactoryGirl.SMALL_LIST_SIZE)
  )
  TuringEmailApp.views.mainView.render()

  TuringEmailApp.views.toolbarView = new TuringEmailApp.Views.ToolbarView(
    app: TuringEmailApp
  )

  TuringEmailApp.collections.emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection(undefined,
    app: TuringEmailApp
    demoMode: false
  )
  TuringEmailApp.views.emailFoldersTreeView = new TuringEmailApp.Views.TreeView(
    app: TuringEmailApp
    el: $(".tm_email-folders")
    collection: TuringEmailApp.collections.emailFolders
  )

  TuringEmailApp.views.composeView = TuringEmailApp.views.mainView.composeView
  TuringEmailApp.listenTo(TuringEmailApp.views.composeView, "change:draft", TuringEmailApp.draftChanged)

  TuringEmailApp.views.createFolderView = TuringEmailApp.views.mainView.createFolderView

  TuringEmailApp.collections.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
    app: TuringEmailApp
    demoMode: false
  )
  TuringEmailApp.views.emailThreadsListView = TuringEmailApp.views.mainView.createEmailThreadsListView(TuringEmailApp.collections.emailThreads)

  TuringEmailApp.routers.emailFoldersRouter = new TuringEmailApp.Routers.EmailFoldersRouter()
  TuringEmailApp.routers.emailThreadsRouter = new TuringEmailApp.Routers.EmailThreadsRouter()
  TuringEmailApp.routers.analyticsRouter = new TuringEmailApp.Routers.AnalyticsRouter()
  TuringEmailApp.routers.reportsRouter = new TuringEmailApp.Routers.ReportsRouter()
  TuringEmailApp.routers.settingsRouter = new TuringEmailApp.Routers.SettingsRouter()
  TuringEmailApp.routers.searchResultsRouter = new TuringEmailApp.Routers.SearchResultsRouter()
  TuringEmailApp.routers.appsLibraryRouter = new TuringEmailApp.Routers.AppsLibraryRouter()
  TuringEmailApp.routers.scheduleEmailsRouter = new TuringEmailApp.Routers.ScheduleEmailsRouter()
  TuringEmailApp.routers.emailTrackersRouter = new TuringEmailApp.Routers.EmailTrackersRouter()

  if not specStartedHistory
    Backbone.history.start(silent: true)
    specStartedHistory = true

window.specCompareFunctions = (fExpected, f) ->
  expect(f.toString().replace(/\s/g, "")).toEqual(fExpected.toString().replace(/\s/g, ""))

window.specPrepareReportFetches = (server) ->
  attachmentsReportFixtures = fixture.load("reports/attachments_report.fixture.json", true);
  attachmentsReportFixture = attachmentsReportFixtures[0]

  emailVolumeReportFixtures = fixture.load("reports/email_volume_report.fixture.json", true);
  emailVolumeReportFixture = emailVolumeReportFixtures[0]

  foldersReportFixtures = fixture.load("reports/folders_report.fixture.json", true);
  foldersReportFixture = foldersReportFixtures[0]

  geoReportFixtures = fixture.load("reports/geo_report.fixture.json", true);
  geoReportFixture = geoReportFixtures[0]

  threadsFixtures = fixture.load("reports/threads_report.fixture.json", true);
  threadsFixture = threadsFixtures[0]

  listsFixtures = fixture.load("reports/lists_report.fixture.json", true);
  listsFixture = listsFixtures[0]

  contactsReportFixtures = fixture.load("reports/contacts_report.fixture.json", true);
  contactsReportFixture = contactsReportFixtures[0]

  server = sinon.fakeServer.create() if not server?

  server.respondWith "GET", new TuringEmailApp.Models.Reports.AttachmentsReport().url, JSON.stringify(attachmentsReportFixture)
  server.respondWith "GET", new TuringEmailApp.Models.Reports.EmailVolumeReport().url, JSON.stringify(emailVolumeReportFixture)
  server.respondWith "GET", new TuringEmailApp.Models.Reports.FoldersReport().url, JSON.stringify(foldersReportFixture)
  server.respondWith "GET", new TuringEmailApp.Models.Reports.GeoReport().url, JSON.stringify(geoReportFixture)
  server.respondWith "GET", new TuringEmailApp.Models.Reports.ThreadsReport().url, JSON.stringify(threadsFixture)
  server.respondWith "GET", new TuringEmailApp.Models.Reports.ListsReport().url, JSON.stringify(listsFixture)
  server.respondWith "GET", new TuringEmailApp.Models.Reports.ContactsReport().url, JSON.stringify(contactsReportFixture)

  return server

window.specCreateEmailThreadsListView = () ->
  emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
    app: TuringEmailApp
    demoMode: false
  )
  emailThreadsListView = new TuringEmailApp.Views.PrimaryPane.EmailThreads.ListView(
    app: TuringEmailApp
    collection: emailThreads
  )
  $("body").append(emailThreadsListView)

  emailThreadsData = FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE)
  emailThreads.reset(emailThreadsData)

  return emailThreadsListView

window.validateKeys = (objectJSON, expectedKeys) ->
  keys = (key for key in _.keys(objectJSON))
  keys.sort()

  expectedKeys = expectedKeys.slice().sort()

  expect(keys).toEqual expectedKeys

window.validateBrainRulesAttributes = (brainRulesJSON) ->
  expectedAttributes = ["uid", "from_address", "to_address", "subject", "list_id"]
  validateKeys(brainRulesJSON, expectedAttributes)

window.validateEmailRulesAttributes = (emailRulesJSON) ->
  expectedAttributes = ["uid", "from_address", "to_address", "subject", "list_id", "destination_folder_name"]
  validateKeys(emailRulesJSON, expectedAttributes)

window.stringifyUserConfiguration = (userConfiguration) ->
  userConfigurationJSON = userConfiguration.toJSON()

  for installedApp in userConfigurationJSON.installed_apps
    installedApp.app = JSON.stringify(installedApp.app)

  return JSON.stringify(userConfigurationJSON)
