describe "ReportsRouter", ->
  beforeEach ->
    specStartTuringEmailApp()

    @reportsRouter = new TuringEmailApp.Routers.ReportsRouter()
    
    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the expected routes", ->
    expect(@reportsRouter.routes["attachments_report"]).toEqual "showAttachmentsReport"
    expect(@reportsRouter.routes["email_volume_report"]).toEqual "showEmailVolumeReport"
    expect(@reportsRouter.routes["folders_report"]).toEqual "showFoldersReport"
    expect(@reportsRouter.routes["geo_report"]).toEqual "showGeoReport"
    expect(@reportsRouter.routes["impact_report"]).toEqual "showImpactReport"
    expect(@reportsRouter.routes["inbox_efficiency_report"]).toEqual "showInboxEfficiencyReport"
    expect(@reportsRouter.routes["lists_report"]).toEqual "showListsReport"
    expect(@reportsRouter.routes["recommended_rules_report"]).toEqual "showRecommendedRulesReport"
    expect(@reportsRouter.routes["summary_analytics_report"]).toEqual "showSummaryAnalyticsReport"
    expect(@reportsRouter.routes["threads_report"]).toEqual "showThreadsReport"
    expect(@reportsRouter.routes["top_contacts"]).toEqual "showTopContactsReport"
    expect(@reportsRouter.routes["word_count_report"]).toEqual "showWordCountReport"

  describe "attachments_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp, "showReport")
      @reportsRouter.navigate "attachments_report", trigger: true
    
    afterEach ->
      @spy.restore()
    
    it "shows an AttachmentsReportView", ->
      expect(@spy).toHaveBeenCalled()

  describe "email_volume_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp, "showReport")
      @reportsRouter.navigate "email_volume_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows an EmailVolumeReportView", ->
      expect(@spy).toHaveBeenCalled()

  describe "folders_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp, "showReport")
      @reportsRouter.navigate "folders_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows a showFoldersReport", ->
      expect(@spy).toHaveBeenCalled()

  describe "geo_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp, "showReport")
      @reportsRouter.navigate "geo_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows a GeoReportView", ->
      expect(@spy).toHaveBeenCalled()

  describe "impact_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp, "showReport")
      @reportsRouter.navigate "impact_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows an ImpactReportView", ->
      expect(@spy).toHaveBeenCalled()

  describe "inbox_efficiency_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp, "showReport")
      @reportsRouter.navigate "inbox_efficiency_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows an InboxEfficiencyReportView", ->
      expect(@spy).toHaveBeenCalled()

  describe "lists_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp, "showReport")
      @reportsRouter.navigate "lists_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows a ListsReportView", ->
      expect(@spy).toHaveBeenCalled()

  describe "recommended_rules_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp, "showReport")
      @reportsRouter.navigate "recommended_rules_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows a RecommendedRulesReportView", ->
      expect(@spy).toHaveBeenCalled()

  describe "summary_analytics_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp, "showReport")
      @reportsRouter.navigate "summary_analytics_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows a SummaryAnalyticsReportView", ->
      expect(@spy).toHaveBeenCalled()

  describe "threads_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp, "showReport")
      @reportsRouter.navigate "threads_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows a ThreadsReportView", ->
      expect(@spy).toHaveBeenCalled()

  describe "top_contacts", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp, "showReport")
      @reportsRouter.navigate "top_contacts", trigger: true

    afterEach ->
      @spy.restore()

    it "shows a ContactsReportView", ->
      expect(@spy).toHaveBeenCalled()

  describe "word_count_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp, "showReport")
      @reportsRouter.navigate "word_count_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows a WordCountReportView", ->
      expect(@spy).toHaveBeenCalled()
