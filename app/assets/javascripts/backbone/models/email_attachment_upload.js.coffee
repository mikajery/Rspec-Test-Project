class TuringEmailApp.Models.EmailAttachmentUpload extends Backbone.Model
  @DownloadsInProgress: {}
  
  # TODO write tests
  @GetUploadAttachmentPost: ->
    url = "/api/v1/users/upload_attachment_post"
    
    $.get(url)
