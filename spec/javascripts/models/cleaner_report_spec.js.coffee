describe "CleanerReport", ->
  describe "#Apply", ->
    beforeEach ->
      @server = sinon.fakeServer.create()

      TuringEmailApp.Models.CleanerReport.Apply()

    afterEach ->
      @server.restore()

    it "posts the install request", ->
      expect(@server.requests.length).toEqual 1

      request = @server.requests[0]
      expect(request.method).toEqual("POST")
      expect(request.url).toEqual("/api/v1/email_accounts/apply_cleaner")
      expect(request.requestBody).toEqual(null)

  beforeEach ->
    @cleanerReport = new TuringEmailApp.Models.CleanerReport()
  
  it "uses '/api/v1/email_accounts/cleaner_report' as url", ->
    expected = '/api/v1/email_accounts/cleaner_report'
    expect( @cleanerReport.url ).toEqual expected
