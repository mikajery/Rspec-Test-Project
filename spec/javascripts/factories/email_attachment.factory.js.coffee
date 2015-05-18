FactoryGirl.define "EmailAttachment", ->
  @sequence("id", "uid")
  
  @filename = "test" + @uid + ".txt"
