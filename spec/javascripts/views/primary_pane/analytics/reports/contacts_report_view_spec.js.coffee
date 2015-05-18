describe "ContactsReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @contactsReport = new TuringEmailApp.Models.Reports.ContactsReport()

    @contactsReportView = new TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ContactsReportView(
      model: @contactsReport
    )

    contactsReportFixtures = fixture.load("reports/contacts_report.fixture.json", true);
    @contactsReportFixture = contactsReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.Reports.ContactsReport().url, JSON.stringify(@contactsReportFixture)

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@contactsReportView.template).toEqual JST["backbone/templates/primary_pane/analytics/reports/contacts_report"]

  describe "#render", ->
    beforeEach ->
      @contactsReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@contactsReportView.$el).toContainHtml("Top Contacts")

      divSelectors = [".incoming-emails-container", ".outgoing-emails-container"]

      for divSelector in divSelectors
        div = @contactsReportView.$el.find(divSelector)
        expect(div.length).toEqual(1)

  describe "#getChartData", ->
    beforeEach ->
      @contactsReport.fetch()
      @server.respond()

      @expectedChartData = JSON.parse('{"topSenders":[["access@interactive.wsj.com",136],["calendar-notification@google.com",72],["account@seekingalpha.com",57],["notifications@github.com",28],["noreply@r.groupon.com",27],["onlinealerts@morganstanleysmithbarney.com",18],["member@linkedin.com",15],["noreply-278e909a@plus.google.com",14],["noreply@medium.com",14],["portfolio@wsj.com",10]],"topRecipients":[["alexkennedyusa@gmail.com",5],["jmdliving@gmail.com",3],["carol@draperuniversity.com",3],["kirstymacgregor@mac.com",3],["ernestine.fu@gmail.com",2],["herman.a.bates@morganstanley.com",2],["finances@turinginc.com",2],["vicki.bones@wolterskluwer.com",2],["dgobaud@gmail.com",2],["david@turinginc.com",2]]}')

    it "converts the model into Google Chart data format", ->
      expect(@contactsReportView.getChartData()).toEqual(@expectedChartData)
