FactoryGirl.define "EmailThread", ->
  @sequence("id", "uid")

  @num_messages = FactoryGirl.SMALL_LIST_SIZE
  @snippet = "Snippet"

  @from_name = "Allan"
  @from_address = "allan@turing.com"
  @date = new Date()
  @subject = "Subject"

  @emails = FactoryGirl.createLists("Email", @num_messages)
  @emails_count = @emails.length
  @loaded = true

  @folderIDs = []

  @seen = true
  for email in @emails
    @folderIDs = @folderIDs.concat(email.folder_ids)
    @seen = false if not email.seen

  @folder_ids = _.uniq(@folderIDs)
