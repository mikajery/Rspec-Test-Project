##########################
# These are speed tests. #
##########################

describe "TuringEmailApp", ->

  it "should load the inbox page in less than 0.5 seconds", ->
    maximumInboxLoadTimeInSeconds = 0.5

  it "should switch to a new folder page in less than 0.1 seconds", ->
    maximumNewFolderLoadTimeInSeconds = 0.5

  it "should load a new email in less than 0.1 seconds", ->
    maximumNewEmailLoadTimeInSeconds = 0.1

  it "should load a report in less than 0.5 seconds", ->
    maximumNewEmailLoadTimeInSeconds = 0.5
