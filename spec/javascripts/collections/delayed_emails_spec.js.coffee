describe "DelayedEmailsCollection", ->
  beforeEach ->
    @delayedEmailsCollection = new TuringEmailApp.Collections.DelayedEmailsCollection()

  it "uses the DelayedEmail model", ->
    expect(@delayedEmailsCollection.model).toEqual(TuringEmailApp.Models.DelayedEmail)

  it "has the right URL", ->
    expect(@delayedEmailsCollection.url).toEqual("/api/v1/delayed_emails")

  describe "Persistence", ->
    beforeEach ->
      delayedEmails = FactoryGirl.createLists("DelayedEmail", FactoryGirl.SMALL_LIST_SIZE)
      @delayedEmailsCollection = new TuringEmailApp.Collections.DelayedEmailsCollection(delayedEmails)
      @ajaxStub = sinon.stub($, "ajax", ->)

    afterEach ->
      @ajaxStub.restore()

    it "should decrease count of objects when delayed model is destroyed", ->
      prev_count = @delayedEmailsCollection.length
      email = @delayedEmailsCollection.at(0)

      email.destroy()
      expect(@delayedEmailsCollection.length).toEqual(prev_count - 1)
      expect(@ajaxStub).toHaveBeenCalled()

  describe "Sort", ->
    beforeEach ->
      delayedEmails = FactoryGirl.createLists("DelayedEmail", FactoryGirl.SMALL_LIST_SIZE)
      @delayedEmailsCollection = new TuringEmailApp.Collections.DelayedEmailsCollection(delayedEmails)

    it "should sort the delayed emails by descending order of send_at", ->
      expect(DelayedEmailsCollectionHelper.isSortedBySendAt @delayedEmailsCollection).toBeTruthy()

  describe "Filters", ->
    beforeEach ->
      delayedEmails = FactoryGirl.createLists("DelayedEmail", FactoryGirl.LARGE_LIST_SIZE)
      @delayedEmailsCollection = new TuringEmailApp.Collections.DelayedEmailsCollection(delayedEmails)

    it "should filter delayed emails scheduled this week", ->
      expect(DelayedEmailsCollectionHelper.isThisWeek @delayedEmailsCollection.thisWeek()).toBeTruthy()

    it "should filter delayed emails by using days period", ->
      expect(DelayedEmailsCollectionHelper.isInPeriod @delayedEmailsCollection.filterByPeriod(0), 0).toBeTruthy()
      expect(DelayedEmailsCollectionHelper.isInPeriod @delayedEmailsCollection.filterByPeriod(1), 1).toBeTruthy()
      expect(DelayedEmailsCollectionHelper.isInPeriod @delayedEmailsCollection.filterByPeriod(7), 7).toBeTruthy()
      expect(DelayedEmailsCollectionHelper.isInPeriod @delayedEmailsCollection.filterByPeriod(14), 14).toBeTruthy()
      expect(DelayedEmailsCollectionHelper.isInPeriod @delayedEmailsCollection.filterByPeriod(30), 30).toBeTruthy()

  describe "Group", ->
    beforeEach ->
      delayedEmails = FactoryGirl.createLists("DelayedEmail", FactoryGirl.LARGE_LIST_SIZE)
      @delayedEmailsCollection = new TuringEmailApp.Collections.DelayedEmailsCollection(delayedEmails)

    it "should group delayed emails by month name", ->
      expect(DelayedEmailsCollectionHelper.groupedByMonth @delayedEmailsCollection.groupByMonth()).toBeTruthy()