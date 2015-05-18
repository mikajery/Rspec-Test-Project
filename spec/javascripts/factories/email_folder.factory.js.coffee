FactoryGirl.define "EmailFolder", ->
  @sequence("id", "label_id") 
  @label_id = "Label_" + @label_id

  @label_list_visibility = "labelShow"
  @label_type = "user"
  @message_list_visibility = "hide"
  @name = @label_id + "_name"
  @num_threads = 5
  @num_unread_threads = 3

FactoryGirl.define "EmailFolder.Inbox", inherit: "EmailFolder", ->
  @label_id = "INBOX"
  @name = "INBOX"
