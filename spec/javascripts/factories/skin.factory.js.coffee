FactoryGirl.define "Skin", ->
  @sequence("id", "uid")
  @name = "Skin " + @uid
