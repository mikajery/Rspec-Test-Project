class TuringEmailApp.Collections.EmailFoldersCollection extends TuringEmailApp.Collections.BaseCollection
  model: TuringEmailApp.Models.EmailFolder
  url: "/api/v1/email_folders"

  initialize: (models, options) ->
    super(models, options)

    @app = options.app
    @demoMode = if options.demoMode? then options.demoMode else true

  ###############
  ### Network ###
  ###############

  sync: (method, collection, options) ->
    if method != "read" || @demoMode
      super(method, collection, options)
    else
      googleRequest(
        @app
        => @labelsListRequest()
        (response) => @loadLabels(response.result.labels, options)
        options.error
      )

      @trigger("request", collection, null, options)

  labelsListRequest: ->
    gapi.client.gmail.users.labels.list(userId: "me", fields: "labels/id")

  loadLabels: (labelsListInfo, options) ->
    googleRequest(
      @app
      => @labelsGetBatch(labelsListInfo)
      (response) => @processLabelsGetBatch(response, options)
      options.error
    )

  labelsGetBatch: (labelsListInfo) ->
    batch = gapi.client.newBatch()

    for labelInfo in labelsListInfo
      request = gapi.client.gmail.users.labels.get(
        userId: "me"
        id: labelInfo.id
      )
      batch.add(request)

    return batch

  processLabelsGetBatch: (response, options) ->
    labelsResults = _.values(response.result)
    labelsInfo = _.pluck(labelsResults, "result")
    options.success(labelsInfo)

  parse: (labelsInfo, options) ->
    return labelsInfo if @demoMode

    labelsParsed = []
    for label in labelsInfo
      continue if label.error?

      labelParsed = {}
      labelParsed.label_id = label.id
      labelParsed.name = label.name
      labelParsed.message_list_visibility = label.messageListVisibility
      labelParsed.label_list_visibility = label.labelListVisibility
      labelParsed.label_type = label.type
      labelParsed.num_threads = label.threadsTotal
      labelParsed.num_unread_threads = label.threadsUnread

      labelsParsed.push(labelParsed)

    return labelsParsed
