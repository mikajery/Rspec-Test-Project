describe "EmailAttachmentUpload", ->
  describe "#GetUploadAttachmentPost", ->
    beforeEach ->
      @server = sinon.fakeServer.create()
      @url = "/api/v1/users/upload_attachment_post"

      TuringEmailApp.Models.EmailAttachmentUpload.GetUploadAttachmentPost()

    afterEach ->
      @server.restore()

    it "gets the upload attachment post request", ->
      expect(@server.requests.length).toEqual 1

      request = @server.requests[0]
      expect(request.method).toEqual("GET")
      expect(request.url).toEqual(@url)
      expect(request.requestBody).toEqual(null)