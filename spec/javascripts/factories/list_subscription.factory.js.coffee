FactoryGirl.define "ListSubscription", ->
  @sequence("id", "list_id")
  @list_name = "List " + @list_id
  @list_domain = "turinginc" + @list_id + ".com"
