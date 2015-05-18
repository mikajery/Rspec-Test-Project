describe "EmailThread", ->
  beforeEach ->
    emailThreadAttributes = FactoryGirl.create("EmailThread")
    @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes,
      app: TuringEmailApp
      emailThreadUID: emailThreadAttributes.uid
      demoMode: false
    )

    @emailThreads = FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE)

  it "uses uid as idAttribute", ->
    expect(@emailThread.idAttribute).toEqual("uid")

  describe "Validation", ->
    it "is required the uid true", ->
      expect( @emailThread.validation.uid.required ).toBeTruthy

    it "is required the emails true", ->
      expect( @emailThread.validation.emails.required ).toBeTruthy

  describe "Class Methods", ->
    beforeEach ->
      @server = sinon.fakeServer.create()

      @emailThreadUIDs = (emailThread.uid for emailThread in @emailThreads)
      @requestBody = "email_thread_uids%5B%5D=" + @emailThreadUIDs.join("&email_thread_uids%5B%5D=")

    afterEach ->
      @server.restore()

    describe "#SetThreadPropertiesFromJSON", ->
      describe "when the from address of any email is not same as the user email", ->
        beforeEach ->
          @threadJSON = @emailThread.toJSON()
          TuringEmailApp.models = user: new TuringEmailApp.Models.User(FactoryGirl.create("User"))

          TuringEmailApp.Models.EmailThread.SetThreadPropertiesFromJSON(@threadJSON, true)

        it "assigns the attributes of the email", ->
          expect(@threadJSON.loaded).toEqual(true)
          expect(@threadJSON.demoMode).toEqual(true)

          lastEmail = @threadJSON.emails[0]

          expect(@threadJSON.num_messages).toEqual(@threadJSON.emails.length)
          expect(@threadJSON.snippet).toEqual(lastEmail.snippet)

          expect(@threadJSON.from_name).toEqual(lastEmail.from_name)
          expect(@threadJSON.from_address).toEqual(lastEmail.from_address)
          expect(@threadJSON.date).toEqual(new Date(lastEmail.date))
          expect(@threadJSON.subject).toEqual(lastEmail.subject)

          folderIDs = []

          threadJSONExpected = @emailThread.toJSON()

          seen = true
          for email in threadJSONExpected.emails
            email.date = new Date(email.date)

            seen = false if !email.seen
            folderIDs = folderIDs.concat(email.folder_ids) if email.folder_ids?

          threadJSONExpected.emails.sort (a, b) => a.date - b.date

          threadJSONExpected.folder_ids = _.uniq(folderIDs)

          expect(@threadJSON.seen).toEqual(threadJSONExpected.seen)
          expect(@threadJSON.emails).toEqual(threadJSONExpected.emails)
          expect(@threadJSON.folder_ids).toEqual(threadJSONExpected.folder_ids)

      describe "when the from address of the each email is same as the user email", ->
        beforeEach ->
          @threadJSON = @emailThread.toJSON()
          TuringEmailApp.models = user: new TuringEmailApp.Models.User(FactoryGirl.create("User", email: "allan@turing.com"))

          TuringEmailApp.Models.EmailThread.SetThreadPropertiesFromJSON(@threadJSON, true)

        it "assigns the attributes of the first email", ->
          lastEmail = @threadJSON.emails[0]

          expect(@threadJSON.num_messages).toEqual(@threadJSON.emails.length)
          expect(@threadJSON.snippet).toEqual(lastEmail.snippet)

          expect(@threadJSON.from_name).toEqual(lastEmail.from_name)
          expect(@threadJSON.from_address).toEqual(lastEmail.from_address)
          expect(@threadJSON.date).toEqual(new Date(lastEmail.date))
          expect(@threadJSON.subject).toEqual(lastEmail.subject)

    describe "#setThreadParsedProperties", ->
      beforeEach ->
        @server.restore()
        @response = fixture.load("gmail_api/users.threads.get.fixture.json")[0]
        @threadMinParsed = fixture.load("gmail_api/users.thread.min.parsed.fixture.json")[0]
        @server = sinon.fakeServer.create()

        @threadInfo = @response.result
        @result = TuringEmailApp.Models.EmailThread.setThreadParsedProperties(uid: @threadInfo.id,
                                                                              @threadInfo.messages,
                                                                              @threadInfo.messages[0])

      it "sets the thread properties", ->
        expect(JSON.stringify(@result)).toEqual(JSON.stringify(@threadMinParsed))

    describe "#createGmailLabelRequest", ->

      beforeEach ->
        window.gapi = client: gmail: users: labels: create: ->

        @ret = {}
        @labelsCreateStub = sinon.stub(gapi.client.gmail.users.labels, "create", => return @ret)

        @params = userId: "me"

      afterEach ->
        @labelsCreateStub.restore()

      describe "when the labelListVisibility and the messageListVisibility are given", ->
        beforeEach ->
          @body =
            name: "label name"
            labelListVisibility: "labelListVisibility"
            messageListVisibility: "messageListVisibility"

          @returned =
            TuringEmailApp.Models.EmailThread.createGmailLabelRequest(@body.name,
                                                                      @body.labelListVisibility,
                                                                      @body.messageListVisibility)

        it "prepares and returns the Gmail API request", ->
          expect(@labelsCreateStub).toHaveBeenCalledWith(@params, @body)
          expect(@returned).toEqual(@ret)

      describe "when the labelListVisibility is null", ->
        beforeEach ->
          @body =
            name: "label name"
            labelListVisibility: "labelShow"
            messageListVisibility: "messageListVisibility"

          @returned =
            TuringEmailApp.Models.EmailThread.createGmailLabelRequest(@body.name,
                                                                      null,
                                                                      @body.messageListVisibility)

        it "fills the labelListVisibility 'labelShow'", ->
          expect(@labelsCreateStub).toHaveBeenCalledWith(@params, @body)

      describe "when the messageListVisibility is null", ->
        beforeEach ->
          @body =
            name: "label name"
            labelListVisibility: "labelListVisibility"
            messageListVisibility: "show"

          @returned =
            TuringEmailApp.Models.EmailThread.createGmailLabelRequest(@body.name,
                                                                      @body.labelListVisibility,
                                                                      null)

        it "fills the labelListVisibility 'labelShow'", ->
          expect(@labelsCreateStub).toHaveBeenCalledWith(@params, @body)

    describe "#removeGmailLabelRequest", ->
      beforeEach ->
        window.gapi = client: gmail: users: threads: modify: ->

        @ret = {}
        @threadsModifyStub = sinon.stub(gapi.client.gmail.users.threads, "modify", => return @ret)

        @params =
          userId: "me"
          id: "thread uid"

        @body =
          removeLabelIds: ["label id"]

        @returned = TuringEmailApp.Models.EmailThread.removeGmailLabelRequest(@params.id, @body.removeLabelIds[0])

      afterEach ->
        @threadsModifyStub.restore()

      it "prepares and returns the Gmail API request", ->
        expect(@threadsModifyStub).toHaveBeenCalledWith(@params, @body)
        expect(@returned).toEqual(@ret)

    describe "#removeFromFolder", ->
      beforeEach ->
        @emailFolderID = "INBOX"
        @success = sinon.stub()
        @error = sinon.stub()

      describe "demoMode=true", ->
        beforeEach ->
          @postSpy = sinon.spy($, "post")

          @url = "/api/v1/email_threads/remove_from_folder"
          @postData =
            email_thread_uids:  @emailThreadUIDs
            email_folder_id: @emailFolderID

        afterEach ->
          @postSpy.restore()

        it "posts", ->
          TuringEmailApp.Models.EmailThread.removeFromFolder(TuringEmailApp, @emailThreadUIDs, @emailFolderID,
                                                             @success, @error, true)
          expect(@postSpy).toHaveBeenCalledWith(@url, @postData)

        describe "success", ->
          describe "when the success is function", ->
            beforeEach ->
              TuringEmailApp.Models.EmailThread.removeFromFolder(TuringEmailApp, @emailThreadUIDs, @emailFolderID,
                                                               @success, @error, true)
              @server.respondWith("POST", @url, "")
              @server.respond()

            it "calls success", ->
              expect(@success).toHaveBeenCalled()
              expect(@error).not.toHaveBeenCalled()
          describe "when the success is not function", ->
            it "returns undefined", ->
              expect( TuringEmailApp.Models.EmailThread.removeFromFolder(TuringEmailApp, @emailThreadUIDs, @emailFolderID, true, @error, true) ).toBeUndefined

        describe "fail", ->
          describe "when the error is function", ->
            beforeEach ->
              TuringEmailApp.Models.EmailThread.removeFromFolder(TuringEmailApp, @emailThreadUIDs, @emailFolderID,
                                                               @success, @error, true)
              @server.respond()

            it "calls error", ->
              expect(@success).not.toHaveBeenCalled()
              expect(@error).toHaveBeenCalled()
          describe "when the error is not function", ->
            it "returns undefined", ->
              expect( TuringEmailApp.Models.EmailThread.removeFromFolder(TuringEmailApp, @emailThreadUIDs, @emailFolderID, @success, true, true) ).toBeUndefined

      describe "demoMode=false", ->
        describe "emailFolderID='SENT'", ->
          it 'returns undefined', ->
            expect(TuringEmailApp.Models.EmailThread.removeFromFolder(TuringEmailApp, @emailThreadUIDs, 'SENT', @success, @error, false)).toBeUndefined

          describe "when the error is function", ->
            it 'calls the error function', ->
              error = ->
                return
              spy = sinon.spy(error)
              TuringEmailApp.Models.EmailThread.removeFromFolder(TuringEmailApp, @emailThreadUIDs, 'SENT', @success, error, false)
              expect(spy).toHaveBeenCalled

        describe "emailFolderID != 'SENT'", ->
          beforeEach ->
            @googleRequestStub = sinon.stub(window, "googleRequest", ->)

            TuringEmailApp.Models.EmailThread.removeFromFolder(TuringEmailApp, @emailThreadUIDs, @emailFolderID, @success, @error, false)

          afterEach ->
            @googleRequestStub.restore()

          it "calls googleRequest", ->
            expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
            specCompareFunctions((=> @removeGmailLabelRequest(emailThreadUID, emailFolderID)), @googleRequestStub.args[0][1])
            expect(@googleRequestStub.args[0][2]).toEqual(@success)
            expect(@googleRequestStub.args[0][3]).toEqual(@error)

    describe "#trashRequest", ->
      beforeEach ->
        window.gapi = client: gmail: users: threads: trash: ->

        @ret = {}
        @threadsTrashStub = sinon.stub(gapi.client.gmail.users.threads, "trash", => return @ret)

        @params =
          userId: "me"
          id: "thread id"

        @returned = TuringEmailApp.Models.EmailThread.trashRequest(@params.id)

      afterEach ->
        @threadsTrashStub.restore()

      it "prepares and returns the Gmail API request", ->
        expect(@threadsTrashStub).toHaveBeenCalledWith(@params)
        expect(@returned).toEqual(@ret)

    describe "#trash", ->
      describe "demoMode=true", ->
        beforeEach ->
          @postSpy = sinon.spy($, "post")

          @url = "/api/v1/email_threads/trash"
          @postData = email_thread_uids:  @emailThreadUIDs

          TuringEmailApp.Models.EmailThread.trash(TuringEmailApp, @emailThreadUIDs, true)

        afterEach ->
          @postSpy.restore()

        it "posts", ->
          expect(@postSpy).toHaveBeenCalledWith(@url, @postData)

      describe "demoMode=false", ->
        beforeEach ->
          @googleRequestStub = sinon.stub(window, "googleRequest", ->)

          TuringEmailApp.Models.EmailThread.trash(TuringEmailApp, @emailThreadUIDs, false)

        afterEach ->
          @googleRequestStub.restore()

        it "calls googleRequest", ->
          expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
          specCompareFunctions((=> @trashRequest(emailThreadUID)), @googleRequestStub.args[0][1])

    describe "#snooze", ->
      beforeEach ->
        @postSpy = sinon.spy($, "post")
        @minutes = 60

        @url = "/api/v1/email_threads/snooze"
        @postData =
          email_thread_uids:  @emailThreadUIDs
          minutes: @minutes

        TuringEmailApp.Models.EmailThread.snooze(TuringEmailApp, @emailThreadUIDs, @minutes)

      afterEach ->
        @postSpy.restore()

      it "posts", ->
        expect(@postSpy).toHaveBeenCalledWith(@url, @postData)

    describe "#deleteDraftRequest", ->
      beforeEach ->
        window.gapi = client: gmail: users: drafts: delete: ->

        @ret = {}
        @threadsTrashStub = sinon.stub(gapi.client.gmail.users.drafts, "delete", => return @ret)

        @params =
          userId: "me"
          id: "draft id"

        @returned = TuringEmailApp.Models.EmailThread.deleteDraftRequest(@params.id)

      afterEach ->
        @threadsTrashStub.restore()

      it "prepares and returns the Gmail API request", ->
        expect(@threadsTrashStub).toHaveBeenCalledWith(@params)
        expect(@returned).toEqual(@ret)

    describe "#deleteDraft", ->
      beforeEach ->
        @draftIDs = @emailThreadUIDs

        @googleRequestStub = sinon.stub(window, "googleRequest", ->)

        TuringEmailApp.Models.EmailThread.deleteDraft(TuringEmailApp, @draftIDs)

      afterEach ->
        @googleRequestStub.restore()

      it "calls googleRequest", ->
        expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
        specCompareFunctions((=> @deleteDraftRequest(draftID)), @googleRequestStub.args[0][1])

    describe "#applyGmailLabelRequest", ->
      beforeEach ->
        window.gapi = client: gmail: users: threads: modify: ->

        @ret = {}
        @threadsModifyStub = sinon.stub(gapi.client.gmail.users.threads, "modify", => return @ret)

        @params =
          userId: "me"
          id: "thread id"

        @body = addLabelIds: ["label id"]

        @returned = TuringEmailApp.Models.EmailThread.applyGmailLabelRequest(@params.id, @body.addLabelIds[0])

      afterEach ->
        @threadsModifyStub.restore()

      it "prepares and returns the Gmail API request", ->
        expect(@threadsModifyStub).toHaveBeenCalledWith(@params, @body)
        expect(@returned).toEqual(@ret)

    describe "#applyGmailLabel", ->
      beforeEach ->
        @success = sinon.stub()
        @error = sinon.stub()

      describe "demoMode=true", ->
        beforeEach ->
          @postSpy = sinon.spy($, "post")
          @url = "/api/v1/email_threads/apply_gmail_label"

        afterEach ->
          @postSpy.restore()

        describe "with labelID", ->
          beforeEach ->
            @postData =
              email_thread_uids:  @emailThreadUIDs
              gmail_label_id: "label id"

          it "posts", ->
            TuringEmailApp.Models.EmailThread.applyGmailLabel(TuringEmailApp, @emailThreadUIDs,
                                                              @postData.gmail_label_id, undefined,
                                                              @success, @error, true)
            expect(@postSpy).toHaveBeenCalledWith(@url, @postData)

          describe "success", ->
            describe "when the success is function", ->
              beforeEach ->
                TuringEmailApp.Models.EmailThread.applyGmailLabel(TuringEmailApp, @emailThreadUIDs,
                                                              @postData.gmail_label_id, undefined,
                                                              @success, @error, true)
                @server.respondWith("POST", @url, "")
                @server.respond()

              it "calls success", ->
                expect(@success).toHaveBeenCalled()
                expect(@error).not.toHaveBeenCalled()
            describe "when the success is not function", ->
              it "returns undefined", ->
                expect( TuringEmailApp.Models.EmailThread.applyGmailLabel(TuringEmailApp, @emailThreadUIDs,
                                                              @postData.gmail_label_id, undefined,
                                                              true, @error, true) ).toBeUndefined

          describe "fail", ->
            describe "when the error is function", ->
              beforeEach ->
                TuringEmailApp.Models.EmailThread.applyGmailLabel(TuringEmailApp, @emailThreadUIDs,
                                                              @postData.gmail_label_id, undefined,
                                                              @success, @error, true)
                @server.respond()

              it "calls error", ->
                expect(@success).not.toHaveBeenCalled()
                expect(@error).toHaveBeenCalled()
            describe "when the error is not function", ->
              it "returns undefined", ->
                expect( TuringEmailApp.Models.EmailThread.applyGmailLabel(TuringEmailApp, @emailThreadUIDs,
                                                              @postData.gmail_label_id, undefined,
                                                              @success, true, true) ).toBeUndefined

        describe "without labelID", ->
          beforeEach ->
            @postData =
              email_thread_uids:  @emailThreadUIDs
              gmail_label_name: "label name"

          it "posts", ->
            TuringEmailApp.Models.EmailThread.applyGmailLabel(TuringEmailApp, @emailThreadUIDs,
                                                              undefined, @postData.gmail_label_name,
                                                              @success, @error, true)

            expect(@postSpy).toHaveBeenCalledWith(@url, @postData)

          describe "success", ->
            describe "when the success is function", ->
              beforeEach ->
                TuringEmailApp.Models.EmailThread.applyGmailLabel(TuringEmailApp, @emailThreadUIDs,
                                                              undefined, @postData.gmail_label_name,
                                                              @success, @error, true)
                @server.respondWith("POST", @url, "")
                @server.respond()

              it "calls success", ->
                expect(@success).toHaveBeenCalled()
                expect(@error).not.toHaveBeenCalled()
            describe "when the success is not function", ->
              it "returns undefined", ->
                expect( TuringEmailApp.Models.EmailThread.applyGmailLabel(TuringEmailApp, @emailThreadUIDs,
                                                              undefined, @postData.gmail_label_name,
                                                              true, @error, true) ).toBeUndefined

          describe "fail", ->
            describe "when the error is function", ->
              beforeEach ->
                TuringEmailApp.Models.EmailThread.applyGmailLabel(TuringEmailApp, @emailThreadUIDs,
                                                              undefined, @postData.gmail_label_name,
                                                              @success, @error, true)
                @server.respond()

              it "calls error", ->
                expect(@success).not.toHaveBeenCalled()
                expect(@error).toHaveBeenCalled()
            describe "when the error is not function", ->
              it "returns undefined", ->
                expect( TuringEmailApp.Models.EmailThread.applyGmailLabel(TuringEmailApp, @emailThreadUIDs,
                                                              undefined, @postData.gmail_label_name,
                                                              @success, true, true) ).toBeUndefined


      describe "demoMode=false", ->
        beforeEach ->
          @googleRequestStub = sinon.stub(window, "googleRequest", ->)

        afterEach ->
          @googleRequestStub.restore()

        describe "with labelID", ->
          beforeEach ->
            TuringEmailApp.Models.EmailThread.applyGmailLabel(TuringEmailApp, @emailThreadUIDs,
                                                              "label id", undefined,
                                                              @success, @error, false)

          it "calls googleRequest", ->
            expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
            specCompareFunctions((=> @applyGmailLabelRequest(emailThreadUID, labelID)), @googleRequestStub.args[0][1])
            expect(@googleRequestStub.args[0][2]).toEqual(@success)
            expect(@googleRequestStub.args[0][3]).toEqual(@error)

        describe "without labelID", ->
          beforeEach ->
            TuringEmailApp.Models.EmailThread.applyGmailLabel(TuringEmailApp, @emailThreadUIDs,
                                                              undefined, "name",
                                                              @success, @error, false)

          it "creates the label", ->
            expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
            specCompareFunctions((=> @createGmailLabelRequest(labelName)), @googleRequestStub.args[0][1])
            specCompareFunctions(((response) => run(response)), @googleRequestStub.args[0][2])
            expect(@googleRequestStub.args[0][3]).toEqual(@error)

          it "calls googleRequest", ->
            @googleRequestStub.args[0][2](result: id: "label id")

            expect(@googleRequestStub.args[1][0]).toEqual(TuringEmailApp)
            specCompareFunctions((=> @applyGmailLabelRequest(emailThreadUID, labelID)), @googleRequestStub.args[1][1])
            expect(@googleRequestStub.args[1][2]).toEqual(@success)
            expect(@googleRequestStub.args[1][3]).toEqual(@error)

    describe "#modifyGmailLabelsRequest", ->
      beforeEach ->
        window.gapi = client: gmail: users: threads: modify: ->

        @ret = {}
        @threadsModifyStub = sinon.stub(gapi.client.gmail.users.threads, "modify", => return @ret)

        @params =
          userId: "me"
          id: "thread id"

        @body =
          addLabelIds: ["add label id"]
          removeLabelIds: ["remove label id"]

        @removeLabelIDs = @body.removeLabelIds.concat("SENT")
        @returned = TuringEmailApp.Models.EmailThread.modifyGmailLabelsRequest(@params.id, @body.addLabelIds, @removeLabelIDs)

      afterEach ->
        @threadsModifyStub.restore()

      it "prepares and returns the Gmail API request", ->
        expect(@threadsModifyStub).toHaveBeenCalledWith(@params, @body)
        expect(@returned).toEqual(@ret)

    describe "#moveToFolder", ->
      beforeEach ->
        @success = sinon.stub()
        @error = sinon.stub()

      describe "demoMode=true", ->
        beforeEach ->
          @postSpy = sinon.spy($, "post")
          @url = "/api/v1/email_threads/move_to_folder"

        afterEach ->
          @postSpy.restore()

        describe "with labelID", ->
          beforeEach ->
            @postData =
              email_thread_uids:  @emailThreadUIDs
              email_folder_id: "label id"

          it "posts", ->
            TuringEmailApp.Models.EmailThread.moveToFolder(TuringEmailApp, @emailThreadUIDs,
                                                           @postData.email_folder_id, undefined, ["current id"],
                                                           @success, @error, true)
            expect(@postSpy).toHaveBeenCalledWith(@url, @postData)

          describe "success", ->
            describe "when the success is function", ->
              beforeEach ->
                TuringEmailApp.Models.EmailThread.moveToFolder(TuringEmailApp, @emailThreadUIDs,
                                                           @postData.email_folder_id, undefined, ["current id"],
                                                           @success, @error, true)
                @server.respondWith("POST", @url, "")
                @server.respond()

              it "calls success", ->
                expect(@success).toHaveBeenCalled()
                expect(@error).not.toHaveBeenCalled()
            describe "when the success is not function", ->
              it "returns undefined", ->
                expect( TuringEmailApp.Models.EmailThread.moveToFolder(TuringEmailApp, @emailThreadUIDs,
                                                           @postData.email_folder_id, undefined, ["current id"],
                                                           true, @error, true) ).toBeUndefined

          describe "fail", ->
            describe "when the error is function", ->
              beforeEach ->
                TuringEmailApp.Models.EmailThread.moveToFolder(TuringEmailApp, @emailThreadUIDs,
                                                           @postData.email_folder_id, undefined, ["current id"],
                                                           @success, @error, true)
                @server.respond()

              it "calls error", ->
                expect(@success).not.toHaveBeenCalled()
                expect(@error).toHaveBeenCalled()
            describe "when the error is not function", ->
              it "returns undefined", ->
                expect( TuringEmailApp.Models.EmailThread.moveToFolder(TuringEmailApp, @emailThreadUIDs,
                                                           @postData.email_folder_id, undefined, ["current id"],
                                                           @success, true, true) ).toBeUndefined


        describe "without labelID", ->
          beforeEach ->
            @postData =
              email_thread_uids:  @emailThreadUIDs
              email_folder_name: "label name"

            TuringEmailApp.Models.EmailThread.moveToFolder(TuringEmailApp, @emailThreadUIDs,
                                                           undefined, @postData.email_folder_name, ["current id"],
                                                           @success, @error, true)

          it "posts", ->
            expect(@postSpy).toHaveBeenCalledWith(@url, @postData)

          describe "success", ->
            beforeEach ->
              @server.respondWith("POST", @url, "")
              @server.respond()

            it "calls success", ->
              expect(@success).toHaveBeenCalled()
              expect(@error).not.toHaveBeenCalled()

          describe "fail", ->
            beforeEach ->
              @server.respond()

            it "calls error", ->
              expect(@success).not.toHaveBeenCalled()
              expect(@error).toHaveBeenCalled()

      describe "demoMode=false", ->
        beforeEach ->
          @googleRequestStub = sinon.stub(window, "googleRequest", ->)

        afterEach ->
          @googleRequestStub.restore()

        describe "with labelID", ->
          beforeEach ->
            TuringEmailApp.Models.EmailThread.moveToFolder(TuringEmailApp, @emailThreadUIDs,
                                                           "label id", undefined, ["current id"],
                                                           @success, @error, false)

          it "calls googleRequest", ->
            expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
            specCompareFunctions((=> @modifyGmailLabelsRequest(emailThreadUID, [folderID], currentFolderIDs)), @googleRequestStub.args[0][1])
            expect(@googleRequestStub.args[0][2]).toEqual(@success)
            expect(@googleRequestStub.args[0][3]).toEqual(@error)

        describe "without labelID", ->
          beforeEach ->
            TuringEmailApp.Models.EmailThread.moveToFolder(TuringEmailApp, @emailThreadUIDs,
                                                           undefined, "name", ["current id"],
                                                           @success, @error, false)

          it "creates the label", ->
            expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
            specCompareFunctions((=> @createGmailLabelRequest(folderName)), @googleRequestStub.args[0][1])
            specCompareFunctions(((response) => run(response)), @googleRequestStub.args[0][2])
            expect(@googleRequestStub.args[0][3]).toEqual(@error)

          it "calls googleRequest", ->
            @googleRequestStub.args[0][2](result: id: "label id")

            expect(@googleRequestStub.args[1][0]).toEqual(TuringEmailApp)
            specCompareFunctions((=> @modifyGmailLabelsRequest(emailThreadUID, [folderID], currentFolderIDs)), @googleRequestStub.args[1][1])
            expect(@googleRequestStub.args[1][2]).toEqual(@success)
            expect(@googleRequestStub.args[1][3]).toEqual(@error)

  describe "#initialize", ->
    beforeEach ->
      @emailThreadTemp = new TuringEmailApp.Models.EmailThread(undefined,
        app: TuringEmailApp
      )

    it "initializes the variables", ->
      expect(@emailThreadTemp.app).toEqual(TuringEmailApp)

    describe "demo mode defaults to true", ->
      beforeEach ->
        @emailThreadTemp = new TuringEmailApp.Models.EmailThread(undefined,
          app: TuringEmailApp
        )

      it "demoMode=true", ->
        expect(@emailThreadTemp.get("demoMode")).toEqual(true)

    describe "assigns demoMode from the attributes parameter", ->
      beforeEach ->
        @emailThreadTemp = new TuringEmailApp.Models.EmailThread(demoMode: false,
          app: TuringEmailApp
        )

      it "demoMode=false", ->
        expect(@emailThreadTemp.get("demoMode")).toEqual(false)

    describe "assigns demoMode from the options parameter", ->
      beforeEach ->
        @emailThreadTemp = new TuringEmailApp.Models.EmailThread(undefined,
          app: TuringEmailApp
          demoMode: false
        )

      it "demoMode=false", ->
        expect(@emailThreadTemp.get("demoMode")).toEqual(false)

    describe "emailThreadUID", ->
      describe "attributes", ->
        beforeEach ->
          @attributes = uid: "1"
          @emailThreadTemp = new TuringEmailApp.Models.EmailThread(@attributes,
            app: TuringEmailApp
          )

        it "assigns emailThreadUID", ->
          expect(@emailThreadTemp.emailThreadUID).toEqual(@attributes.uid)

        it "sets up the url", ->
          expect(@emailThreadTemp.url()).toEqual("/api/v1/email_threads/show/" + @attributes.uid + "?page=1")

      describe "options", ->
        beforeEach ->
          @options =
            app: TuringEmailApp
            emailThreadUID: "1"
          @emailThreadTemp = new TuringEmailApp.Models.EmailThread(undefined, @options)

        it "assigns emailThreadUID", ->
          expect(@emailThreadTemp.emailThreadUID).toEqual(@options.emailThreadUID)

        it "sets up the url", ->
          expect(@emailThreadTemp.url()).toEqual("/api/v1/email_threads/show/" + @options.emailThreadUID + "?page=1")

  describe "Network", ->
    describe "#load", ->
      beforeEach ->
        @success = sinon.stub()
        @error = sinon.stub()
        @options = success: @success, error: @error
        @fetchStub = sinon.stub(@emailThread, "fetch")

        @emailThread.set("emails", [uid: "message id"])

        draftInfo =
          id: "draft id"
          message:
            id: "message id"

        @emailThread.set("draftInfo", draftInfo)

        @checkFetch = =>
          expect(@emailThread.loading).toBeTruthy()
          expect(@emailThread.emailThreadUID).toEqual(@emailThread.get("uid"))
          expect(@fetchStub).toHaveBeenCalled()

        @checkSuccess = =>
          expect(@emailThread.get("loaded")).toBeTruthy()
          expect(@emailThread.loading).toBeFalsy()
          expect(@success).toHaveBeenCalled()
          expect(@error).not.toHaveBeenCalled()

          expect(@emailThread.get("emails")[0].draft_id).toEqual("draft id")

        @checkError = =>
          expect(@emailThread.get("loaded")).toBeFalsy()
          expect(@emailThread.loading).toBeFalsy()
          expect(@success).not.toHaveBeenCalled()
          expect(@error).toHaveBeenCalled()

      afterEach ->
        @fetchStub.restore()

      describe "loaded=true", ->
        beforeEach ->
          @emailThread.set("loaded", true)

        describe "force=false", ->

          describe "when the success is function", ->
            beforeEach ->
              @emailThread.load(@options)

            it "calls success", ->
              expect(@options.success).toHaveBeenCalled()

          describe "when the success is not function", ->
            beforeEach ->
              @options_func = success: true, error: @error

            it "returns undefined", ->
              expect( @emailThread.load(@options_func) ).toBeUndefined()

          it "does not fetch", ->
            @emailThread.load(@options)
            expect(@fetchStub).not.toHaveBeenCalled()

        describe "force=true", ->
          describe "loading=true", ->
            beforeEach ->
              @setTimeoutStub = sinon.stub(window, "setTimeout")

              @emailThread.loading = true
              @emailThread.load(@options, true)

            afterEach ->
              @setTimeoutStub.restore()

            it "queues a load call", ->
              expect(@setTimeoutStub).toHaveBeenCalled()
              specCompareFunctions((=> @load(options, force)), @setTimeoutStub.args[0][0])
              expect(@setTimeoutStub.args[0][1]).toEqual(250)

            it "returns", ->
              expect(@success).not.toHaveBeenCalled()
              expect(@error).not.toHaveBeenCalled()
              expect(@fetchStub).not.toHaveBeenCalled()

          describe "loading=false", ->
            beforeEach ->
              @emailThread.loading = false
              @emailThread.load(@options, true)

            it "fetches", ->
              @checkFetch()

            describe "on success", ->
              # describe "when the success is function", ->
              #   beforeEach ->
              #     @emailThread.load(@options)
              #     @fetchStub.args[0][0].success()

              #   it "loads", ->
              #     @checkSuccess()

              describe "when the success is not function", ->
                beforeEach ->
                  @options_func = success: true, error: @error

                it "returns undefined", ->
                  expect( @emailThread.load(@options_func) ).toBeUndefined()

            describe "on error", ->
              describe "when the error is function", ->
                beforeEach ->
                  @emailThread.loading = false
                  @emailThread.load(@options, true)

                  @emailThread.set("loaded", false)
                  @fetchStub.args[0][0].error()

                it "errors", ->
                  @checkError()

              describe "when the error is not function", ->
                beforeEach ->
                  @options_func = success: @success, error: true

                it "returns undefined", ->
                  expect( @emailThread.load(@options_func) ).toBeUndefined()

      describe "loaded=false", ->
        beforeEach ->
          @emailThread.set("loaded", false)

        describe "loading=true", ->
          beforeEach ->
            @setTimeoutStub = sinon.stub(window, "setTimeout")

            @emailThread.loading = true
            @emailThread.load(@options, true)

          afterEach ->
            @setTimeoutStub.restore()

          it "queues a load call", ->
            expect(@setTimeoutStub).toHaveBeenCalled()
            specCompareFunctions((=> @load(options, force)), @setTimeoutStub.args[0][0])
            expect(@setTimeoutStub.args[0][1]).toEqual(250)

          it "returns", ->
            expect(@success).not.toHaveBeenCalled()
            expect(@error).not.toHaveBeenCalled()
            expect(@fetchStub).not.toHaveBeenCalled()

        describe "loading=false", ->
          beforeEach ->
            @emailThread.loading = false

          it "fetches", ->
            @emailThread.load(@options)
            @checkFetch()

          describe "on success", ->
            # describe "when the success is function", ->
            #   beforeEach ->
            #     @emailThread.load(@options)
            #     @fetchStub.args[0][0].success()

            #   it "loads", ->
            #     @checkSuccess()

            describe "when the success is not function", ->
              beforeEach ->
                @options_func = success: true, error: @error

              it "returns undefined", ->
                expect( @emailThread.load(@options_func) ).toBeUndefined()

          describe "on error", ->
            describe "when the error is function", ->
              beforeEach ->
                @emailThread.load(@options)
                @emailThread.set("loaded", false)
                @fetchStub.args[0][0].error()

              it "errors", ->
                @checkError()

            describe "when the error is not function", ->
              beforeEach ->
                @options_func = success: @success, error: true

              it "returns undefined", ->
                expect( @emailThread.load(@options_func) ).toBeUndefined()

          describe "options=null", ->
            beforeEach ->
              @emailThread.loading = false
              @emailThread.load(null)

            it "fetches", ->
              @checkFetch()

    describe "#sync", ->
      beforeEach ->
        @superStub = sinon.stub(TuringEmailApp.Models.EmailThread.__super__, "sync")
        @googleRequestStub = sinon.stub(window, "googleRequest", ->)
        @triggerStub = sinon.stub(@emailThread, "trigger", ->)

      afterEach ->
        @triggerStub.restore()
        @googleRequestStub.restore()
        @superStub.restore()

      describe "write", ->
        beforeEach ->
          @method = "write"
          @model = {}
          @options = {}

          @emailThread.sync(@method, @model, @options)

        it "calls super", ->
          expect(@superStub).toHaveBeenCalledWith(@method, @model, @options)

        it "does NOT call googleRequest", ->
          expect(@googleRequestStub).not.toHaveBeenCalled()

        it "does not trigger the request event", ->
          expect(@triggerStub).not.toHaveBeenCalled()

      describe "read", ->
        beforeEach ->
          @method = "read"
          @model = {}
          @options = error: sinon.stub()

        describe "demoMode=true", ->
          beforeEach ->
            @triggerStub.restore()
            @emailThread.set("demoMode", true)
            @triggerStub = sinon.stub(@emailThread, "trigger", ->)

            @emailThread.sync(@method, @model, @options)

          it "calls super", ->
            expect(@superStub).toHaveBeenCalledWith(@method, @model, @options)

          it "does NOT call googleRequest", ->
            expect(@googleRequestStub).not.toHaveBeenCalled()

          it "does not trigger the request event", ->
            expect(@triggerStub).not.toHaveBeenCalled()

        describe "demoMode=false", ->
          beforeEach ->
            @emailThread.set("demoMode", false)

            @emailThread.sync(@method, @model, @options)

          it "does not call super", ->
            expect(@superStub).not.toHaveBeenCalled()

          it "calls googleRequest", ->
            expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
            specCompareFunctions((=> @threadsGetRequest()), @googleRequestStub.args[0][1])
            specCompareFunctions(((response) => @processThreadsGetRequest(response, options)), @googleRequestStub.args[0][2])
            expect(@googleRequestStub.args[0][3]).toEqual(@options.error)

          it "triggers the request event", ->
            expect(@triggerStub).toHaveBeenCalledWith("request", @model, null, @options)

    describe "#threadsGetRequest", ->
      beforeEach ->
        window.gapi = client: gmail: users: threads: get: ->

        @ret = {}
        @threadsGetStub = sinon.stub(gapi.client.gmail.users.threads, "get", => return @ret)

        @params =
          userId: "me"
          id: @emailThread.emailThreadUID

      afterEach ->
        @threadsGetStub.restore()

      it "prepares and returns the Gmail API request", ->
        @returned = @emailThread.threadsGetRequest()

        expect(@threadsGetStub).toHaveBeenCalledWith(@params)
        expect(@returned).toEqual(@ret)

    describe "#processThreadsGetRequest", ->
      beforeEach ->
        @response = fixture.load("gmail_api/users.threads.get.fixture.json")[0]
        @options = {success: sinon.stub()}

        @threadJSON = {}
        @parseThreadInfoStub = sinon.stub(@emailThread, "parseThreadInfo", => @threadJSON)

      afterEach ->
        @parseThreadInfoStub.restore()

      it "parse the response", ->
        @emailThread.processThreadsGetRequest(@response, @options)
        expect(@parseThreadInfoStub).toHaveBeenCalledWith(@response.result)

      describe "when the success is function", ->
        it "passes the result of parseThreadInfo to the success handler", ->
          @emailThread.processThreadsGetRequest(@response, @options)
          expect(@options.success).toHaveBeenCalledWith(@threadJSON)

      describe "when the success is not function", ->
        beforeEach ->
          @options_func = {success: true}

        it "returns undefined", ->
          expect( @emailThread.processThreadsGetRequest(@response, @options) ).toBeUndefined()

    describe "#parseThreadInfo", ->
      beforeEach ->
        @response = fixture.load("gmail_api/users.threads.get.fixture.json")[0]
        @threadInfo = @response.result

        @threadParsed = fixture.load("gmail_api/users.thread.parsed.fixture.json")[0]
        @result = @emailThread.parseThreadInfo(@threadInfo)

      it "parses the thread", ->
        expect(JSON.stringify(@result)).toEqual(JSON.stringify(@threadParsed))

  describe "Events", ->
    describe "#threadsModifyUnreadRequest", ->
      beforeEach ->
        window.gapi = client: gmail: users: threads: modify: ->

        @ret = {}
        @threadsModifyStub = sinon.stub(gapi.client.gmail.users.threads, "modify", => return @ret)

        @params =
          userId: "me"
          id: @emailThread.get("uid")

      afterEach ->
        @threadsModifyStub.restore()

      describe "seenValue=true", ->
        beforeEach ->
          @body = removeLabelIds: ["UNREAD"]
          @returned = @emailThread.threadsModifyUnreadRequest(true)

        it "prepares and returns the Gmail API request", ->
          expect(@threadsModifyStub).toHaveBeenCalledWith(@params, @body)
          expect(@returned).toEqual(@ret)

      describe "seenValue=false", ->
        beforeEach ->
          @body = addLabelIds: ["UNREAD"]
          @returned = @emailThread.threadsModifyUnreadRequest(false)

        it "prepares and returns the Gmail API request", ->
          expect(@threadsModifyStub).toHaveBeenCalledWith(@params, @body)
          expect(@returned).toEqual(@ret)

#    describe "#seenChanged", ->
#      beforeEach ->
#        @googleRequestStub = sinon.stub(window, "googleRequest", ->)
#
#      afterEach ->
#        @googleRequestStub.restore()
#
#      describe "demoMode=true", ->
#        describe "when the emails exist", ->
#          beforeEach ->
#            @emailThread.set("demoMode", true)
#
#            @postStub = sinon.stub($, "post")
#
#            @postData = {}
#            @postData.email_uids = (email.uid for email in @emailThread.get("emails"))
#            @postData.seen = !@emailThread.get("seen")
#
#            @emailThread.set("seen", !@emailThread.get("seen"))
#
#          afterEach ->
#            @postStub.restore()
#
#          it "does NOT call googleRequest", ->
#            expect(@googleRequestStub).not.toHaveBeenCalled()
#
#          it "posts", ->
#            expect(@postStub).toHaveBeenCalledWith("/api/v1/emails/set_seen", @postData)
#
#        describe "when the emails do not exist", ->
#          beforeEach ->
#            @emailThread.set("demoMode", true)
#            @emailThread.set("emails", [])
#
#          it 'returns the itself', ->
#            expect( @emailThread.set("seen", !@emailThread.get("seen")) ).toEqual(@emailThread)
#
#      describe "demoMode=false", ->
#        beforeEach ->
#          @emailThread.set("demoMode", false)
#          @emailThread.set("seen", !@emailThread.get("seen"))
#
#        it "calls googleRequest", ->
#          expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
#          specCompareFunctions((=> @threadsModifyUnreadRequest(seenValue)), @googleRequestStub.args[0][1])

  describe "Actions", ->
    describe "#removeFromFolder", ->
      beforeEach ->
        emailFolder = FactoryGirl.create("EmailFolder")
        @folderID = emailFolder.label_id

        @removeFromFolderStub = sinon.stub(TuringEmailApp.Models.EmailThread, "removeFromFolder", ->)

        @emailThread.removeFromFolder(@folderID)

      afterEach ->
        @removeFromFolderStub.restore()

      it "calls the remove from folder class method", ->
        expect(@removeFromFolderStub).toHaveBeenCalledWith(TuringEmailApp, [@emailThread.get("uid")], @folderID,
                                                           undefined, undefined, @emailThread.get("demoMode"))

    describe "#trash", ->
      beforeEach ->
        @stub = sinon.stub(TuringEmailApp.Models.EmailThread, "trash")

      afterEach ->
        @stub.restore()

      it "calls the trash class method", ->
        @emailThread.trash()

        expect(@stub).toHaveBeenCalledWith(TuringEmailApp, [@emailThread.get("uid")], @emailThread.get("demoMode"))

    describe "#snooze", ->
      beforeEach ->
        @stub = sinon.stub(TuringEmailApp.Models.EmailThread, "snooze")

        @minutes = 60
        @emailThread.snooze(@minutes)

      afterEach ->
        @stub.restore()

      it "calls the snooze class method", ->
        expect(@stub).toHaveBeenCalledWith(TuringEmailApp, [@emailThread.get("uid")], @minutes)

    describe "#deleteDraft", ->
      beforeEach ->
        @stub = sinon.stub(TuringEmailApp.Models.EmailThread, "deleteDraft")

      afterEach ->
        @stub.restore()

      it "calls the delete draft class method", ->
        @emailThread.deleteDraft()

        expect(@stub).toHaveBeenCalledWith(TuringEmailApp, [@emailThread.get("draft_id")])

    describe "#applyGmailLabel", ->
      beforeEach ->
        emailFolder = FactoryGirl.create("EmailFolder")
        @labelID = emailFolder.label_id
        @labelName = emailFolder.name

        @stub = sinon.stub(TuringEmailApp.Models.EmailThread, "applyGmailLabel", ->)

        @emailThread.applyGmailLabel @labelID, @labelName

      afterEach ->
        @stub.restore()

      it "calls the apply gmail label class method", ->
        expect(@stub).toHaveBeenCalledWith(TuringEmailApp, [@emailThread.get("uid")], @labelID, @labelName)
        specCompareFunctions(((data) => @trigger("change:folder", this, data)), @stub.args[0][4])
        expect(@stub.args[0][5]).toEqual(undefined)
        expect(@stub.args[0][6]).toEqual(@emailThread.get("demoMode"))

    describe "#moveToFolder", ->
      beforeEach ->
        emailFolder = FactoryGirl.create("EmailFolder")
        @folderID = emailFolder.label_id
        @folderName = emailFolder.name

        @stub = sinon.stub(TuringEmailApp.Models.EmailThread, "moveToFolder", ->)

        @emailThread.moveToFolder(@folderID, @folderName)

      afterEach ->
        @stub.restore()

      it "calls the move to folder class method", ->
        expect(@stub).toHaveBeenCalledWith(TuringEmailApp, [@emailThread.get("uid")], @folderID, @folderName)
        specCompareFunctions(((data) => @trigger("change:folder", this, data)), @stub.args[0][5])
        expect(@stub.args[0][6]).toEqual(undefined)
        expect(@stub.args[0][7]).toEqual(@emailThread.get("demoMode"))

  describe "Formatters", ->
    beforeEach ->
      specStartTuringEmailApp()

      TuringEmailApp.models.user = new TuringEmailApp.Models.User(FactoryGirl.create("User"))

    afterEach ->
      specStopTuringEmailApp()

    describe "#numEmailsText", ->
      describe "with emails", ->
        describe "with 1 email", ->
          beforeEach ->
            @emailThread.set("emails_count", 1)

          it "returns an empty string", ->
            expect(@emailThread.numEmailsText()).toEqual ""

        describe "more than 1 email", ->
          beforeEach ->
            @emailThread.set("emails_count", 2)

          it "returns the preview text", ->
            expect(@emailThread.numEmailsText()).toEqual "(2)"

      describe "without emails", ->
        beforeEach ->
          @emailThread.set("emails", null)

        describe "with 1 email", ->
          beforeEach ->
            @emailThread.set("emails_count", 1)

          it "returns an empty string", ->
            expect(@emailThread.numEmailsText()).toEqual ""

        describe "more than 1 email", ->
          beforeEach ->
            @emailThread.set("emails_count", 2)

          it "returns the preview text", ->
            expect(@emailThread.numEmailsText()).toEqual "(2)"

    describe "#fromPreview", ->
      describe "from_address is the user's email", ->
        beforeEach ->
          @oldFromAddress = @emailThread.get("from_address")
          @emailThread.set("from_address", TuringEmailApp.models.user.get("email"))

        afterEach ->
          @emailThread.set("from_address", @oldFromAddress)

        it "returns the correct preview", ->
          expect(@emailThread.fromPreview() + " " + @emailThread.numEmailsText()).toEqual("me " + @emailThread.numEmailsText())

      describe "from_address is NOT the user's email", ->
        describe "with from_name", ->
          it "returns the correct preview", ->
            expect(@emailThread.fromPreview() + " " + @emailThread.numEmailsText()).toEqual(@emailThread.get("from_name") + " " + @emailThread.numEmailsText())

        describe "with from_name=blank", ->
          beforeEach ->
            @oldFromName = @emailThread.get("from_name")
            @emailThread.set("from_name", "")

          afterEach ->
            @emailThread.set("from_name", @oldFromName)

          it "returns the correct preview", ->
            expect(@emailThread.fromPreview() + " " + @emailThread.numEmailsText()).toEqual(@emailThread.get("from_address") + " " + @emailThread.numEmailsText())

        describe "with from_name=null", ->
          beforeEach ->
            @oldFromName = @emailThread.get("from_name")
            @emailThread.set("from_name", null)

          afterEach ->
            @emailThread.set("from_name", @oldFromName)

          it "returns the correct preview", ->
            expect(@emailThread.fromPreview() + " " + @emailThread.numEmailsText()).toEqual(@emailThread.get("from_address") + " " + @emailThread.numEmailsText())

    describe "#subjectPreview", ->
      describe "has a subject", ->
        it "returns the correct subject preview", ->
          expect(@emailThread.subjectPreview()).toEqual(@emailThread.get("subject"))

      describe "no subject", ->
        beforeEach ->
          @oldSubject = @emailThread.get("subject")
          @emailThread.set("subject", "")

        afterEach ->
          @emailThread.set("subject", @oldSubject)

        it "returns the correct subject preview", ->
          expect(@emailThread.subjectPreview()).toEqual("(no subject)")

    describe "#datePreview", ->
      it "returns the localized date string", ->
        expect(@emailThread.datePreview()).toEqual(TuringEmailApp.Models.Email.localDateString(@emailThread.get("date")))

    describe "#hasAttachment", ->
      describe "when the email thread does have attachments", ->

        it "returns true", ->
          expect(@emailThread.hasAttachment()).toBeTruthy()

      describe "when the email thread does not have attachments", ->
        beforeEach ->
          for email in @emailThread.get("emails")
            email.email_attachments = []

        it "returns false", ->
          expect(@emailThread.hasAttachment()).toBeFalsy()

    describe "#numEmails", ->
      describe "has emails", ->
        beforeEach ->
          @oldEmailsCount = @emailThread.get("emails_count")
          @emailThread.set("emails_count", 10)

        afterEach ->
          @emailThread.set("emails_count", @oldEmailsCount)

        it "returns the length of the emails", ->
          expect(@emailThread.numEmails()).toEqual 10

      describe "no emails", ->
        beforeEach ->
          @oldEmails = @emailThread.get("emails")
          @emailThread.set("emails", undefined)

        afterEach ->
          @emailThread.set("emails", @oldEmails)

        it "returns the num_messages", ->
          console.log @emailThread.numEmails()
          console.log @emailThread.get("num_messages")
