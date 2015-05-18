describe "EmailVolumeReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @emailVolumeReport = new TuringEmailApp.Models.Reports.EmailVolumeReport()

    @emailVolumeReportView = new TuringEmailApp.Views.PrimaryPane.Analytics.Reports.EmailVolumeReportView(
      model: @emailVolumeReport
    )

    emailVolumeReportFixtures = fixture.load("reports/email_volume_report.fixture.json", true);
    @emailVolumeReportFixture = emailVolumeReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.Reports.EmailVolumeReport().url, JSON.stringify(@emailVolumeReportFixture)

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@emailVolumeReportView.template).toEqual JST["backbone/templates/primary_pane/analytics/reports/email_volume_report"]

  describe "#render", ->
    beforeEach ->
      @emailVolumeReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@emailVolumeReportView.$el).toContainHtml("Email Volume")

      divSelectors = [".emails-per-day-chart", ".emails-per-week-chart", ".emails-per-month-chart"]

      for divSelector in divSelectors
        div = @emailVolumeReportView.$el.find(divSelector)
        expect(div.length).toEqual(1)

  describe "#getChartData", ->
    beforeEach ->
      @emailVolumeReport.fetch()
      @server.respond()

      @expectedChartData = JSON.parse('{"emailsPerDayGChartData":[["Day","Received","Sent"],["8/27/2014",10,2],["8/28/2014",2,0],["8/29/2014",11,0],["8/30/2014",11,0],["8/31/2014",1,0],["9/1/2014",12,2],["9/2/2014",6,1],["9/3/2014",17,0],["9/4/2014",28,1],["9/5/2014",18,0],["9/6/2014",11,1],["9/7/2014",7,0],["9/8/2014",11,0],["9/9/2014",10,0],["9/10/2014",7,0],["9/11/2014",12,0],["9/12/2014",10,0],["9/13/2014",4,0],["9/14/2014",21,0],["9/15/2014",7,0],["9/16/2014",47,1],["9/17/2014",20,3],["9/18/2014",0,0],["9/19/2014",0,0],["9/20/2014",0,0],["9/21/2014",0,0],["9/22/2014",0,0],["9/23/2014",0,0],["9/24/2014",0,0],["9/25/2014",0,0],["9/26/2014",0,0]],"emailsPerWeekGChartData":[["Week","Received","Sent"],["7/7/2014",0,0],["7/14/2014",0,0],["7/21/2014",7,0],["7/28/2014",111,0],["8/4/2014",203,0],["8/11/2014",131,7],["8/18/2014",106,6],["8/25/2014",72,6],["9/1/2014",99,5],["9/8/2014",75,0],["9/15/2014",74,4],["9/22/2014",0,0]],"emailsPerMonthGChartData":[["Month","Received","Sent"],["10/1/2013",0,0],["11/1/2013",0,0],["12/1/2013",0,0],["1/1/2014",0,0],["2/1/2014",0,0],["3/1/2014",0,0],["4/1/2014",0,0],["5/1/2014",0,0],["6/1/2014",0,0],["7/1/2014",77,0],["8/1/2014",553,19],["9/1/2014",248,9]]}')

    it "converts the model into Google Chart data format", ->
      # TODO not sure how to test because what it renders is dependent on the current date
      #expect(@emailVolumeReportView.getGoogleChartData()).toEqual(@expectedGoogleChartData)

  describe "#getDailyEmailData", ->
    # TODO write tests

  describe "#getWeeklyEmailData", ->
    # TODO write tests

  describe "#getEmailVolumeDataPerDay", ->
    # TODO write tests

  describe "#getEmailVolumeDataPerMonth", ->
    # TODO write tests
