class TuringEmailApp.Models.EmailAttachment extends Backbone.Model
  @DownloadsInProgress: {}

  # TODO write tests
  @Download: (app, s3Key) ->
    url = "/api/v1/email_attachments/download/" + s3Key
    return if TuringEmailApp.Models.EmailAttachment.DownloadsInProgress[url]
    TuringEmailApp.Models.EmailAttachment.DownloadsInProgress[url] = true

    $.get(url).done(
      (data, statusText, xhr) ->
        app.downloadFile(data.url)
        delete TuringEmailApp.Models.EmailAttachment.DownloadsInProgress[url]
    ).fail(
      (xhr) ->
        delete TuringEmailApp.Models.EmailAttachment.DownloadsInProgress[url]

        switch xhr.status
          when 690
            setTimeout(
              -> TuringEmailApp.Models.EmailAttachment.Download(app, s3Key)
              1000
            )

          when 691
            app.showAlert("Attachment Not Found", "alert-error", 5000)

          else
            app.showAlert("Attachment Download Error - " + statusText, "alert-error", 5000)
    )
