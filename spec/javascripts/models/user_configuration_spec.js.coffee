describe "UserConfiguration", ->
  beforeEach ->
    @userConfiguration = new TuringEmailApp.Models.UserConfiguration()
    
  describe "Class Variables", ->
    describe "#EmailThreadsPerPage", ->
      it "returns 50", ->
        expect( TuringEmailApp.Models.UserConfiguration.EmailThreadsPerPage ).toEqual 25

  describe "Instance Variables", ->
    describe "#url", ->
      it "returns '/api/v1/user_configurations'", ->
        expect(@userConfiguration.url).toEqual("/api/v1/user_configurations")      
  
  describe "Validation", ->
    it "is required the genie_enabled true", ->
      expect( @userConfiguration.validation.genie_enabled.required ).toBeTruthy
    it "is required the split_pane_mode true", ->
      expect( @userConfiguration.validation.split_pane_mode.required ).toBeTruthy


