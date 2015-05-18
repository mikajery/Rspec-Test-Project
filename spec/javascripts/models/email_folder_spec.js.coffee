describe "EmailFolder", ->
  describe "variables", ->
    beforeEach ->
      @emailFolder = new TuringEmailApp.Models.EmailFolder(FactoryGirl.create("EmailFolder"))

    it "uses label_id as idAttribute", ->
      expect(@emailFolder.idAttribute).toEqual("label_id")

    it "is required the label_id true", ->
      expect( @emailFolder.validation.label_id.required ).toBeTruthy

    it "is required the label_list_visibility true", ->
      expect( @emailFolder.validation.label_list_visibility.required ).toBeTruthy

    it "is required the label_type true", ->
      expect( @emailFolder.validation.label_type.required ).toBeTruthy

    it "is required the message_list_visibility true", ->
      expect( @emailFolder.validation.message_list_visibility.required ).toBeTruthy

    it "is required the name true", ->
      expect( @emailFolder.validation.name.required ).toBeTruthy

    it "is required the num_threads true", ->
      expect( @emailFolder.validation.num_threads.required ).toBeTruthy

    it "is required the num_unread_threads true", ->
      expect( @emailFolder.validation.num_unread_threads.required ).toBeTruthy

  describe "Instance Methods", ->
    describe "#badgeString", ->
      describe "when the label_id is SENT", -> 
        beforeEach ->
          @emailFolder = new TuringEmailApp.Models.EmailFolder(FactoryGirl.create("EmailFolder", label_id: "SENT"))       
        
        it "returns the empty", -> 
          expect( @emailFolder.badgeString() ).toEqual ""
      describe "when the label_id is TRASH", ->
        beforeEach ->
          @emailFolder = new TuringEmailApp.Models.EmailFolder(FactoryGirl.create("EmailFolder", label_id: "TRASH"))

        it "returns the empty", ->
          expect( @emailFolder.badgeString() ).toEqual ""

      describe "when the label_id is DRAFT", ->
        describe "when the num_threads is 0", ->
          beforeEach ->
            @emailFolder = new TuringEmailApp.Models.EmailFolder(FactoryGirl.create("EmailFolder", label_id: "DRAFT", num_threads: 0))
          
          it "returns the empty", ->
            expect( @emailFolder.badgeString() ).toEqual ""

        describe "when the num_threads is not 0", ->
          beforeEach ->
            @num_threads = 3
            @emailFolder = new TuringEmailApp.Models.EmailFolder(FactoryGirl.create("EmailFolder", label_id: "DRAFT", num_threads: @num_threads))
          
          it "returns the num_threads", ->
            expect( @emailFolder.badgeString() ).toEqual @num_threads.toString()
          
      describe "when the num_unread_threads is 0", ->
        beforeEach ->
          @emailFolder = new TuringEmailApp.Models.EmailFolder(FactoryGirl.create("EmailFolder", num_unread_threads: 0))
        
        it "returns the empty", ->
          expect( @emailFolder.badgeString() ).toEqual ""

      describe "when the num_unread_threads is not 0", ->
        beforeEach ->
          @num_unread_threads = 3
          @emailFolder = new TuringEmailApp.Models.EmailFolder(FactoryGirl.create("EmailFolder", num_unread_threads: @num_unread_threads))
        
        it "returns the num_unread_threads", ->
          expect( @emailFolder.badgeString() ).toEqual @num_unread_threads.toString()
