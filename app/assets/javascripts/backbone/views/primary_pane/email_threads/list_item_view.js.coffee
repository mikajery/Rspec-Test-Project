TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.EmailThreads ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailThreads.ListItemView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/primary_pane/email_threads/list_item"]
  tagName: "TR"

  initialize: (options) ->
    super(options)

    @app = options.app

    @listenTo(@model, "change", @render)
    @listenTo(@model, "removedFromCollection destroy", @remove)

  render: ->
    checked = @isChecked()

    modelJSON = {}
    modelJSON["viewMode"] = @app.models.userConfiguration.get("split_pane_mode")
    modelJSON["numEmails"] = @model.numEmails()
    modelJSON["fromPreview"] = @model.fromPreview()
    modelJSON["subjectPreview"] = escapeHTML(@model.subjectPreview())
    modelJSON["datePreview"] = @model.datePreview()
    modelJSON["hasAttachment"] = @model.hasAttachment()
    modelJSON["snippet"] = escapeHTML(@model.get("snippet"))
    @$el.html(@template(modelJSON))

    if @model.get("seen")
      @markRead(silent: true)
    else
      @markUnread(silent: true)

    @check(silent: true) if checked

    @setupClick()
    @setupCheckbox()

    @

  #######################
  ### Setup Functions ###
  #######################

  addedToDOM: ->
    @setupClick()
    @setupCheckbox()

  setupClick: ->
    tds = @$el.find('td')
    tds.off("click")
    tds.click =>
      @trigger("click", this)

  setupCheckbox: ->
    @$("div.icheckbox ins").off("click")

    @$(".i-checks").iCheck
      checkboxClass: "icheckbox"
      radioClass: "iradio"

    @diviCheck = @$("div.icheckbox")

    @$("div.icheckbox ins").click =>
      @updateCheckStyles()

      if @isChecked()
        @trigger("checked", this)
      else
        @trigger("unchecked", this)

  ###############
  ### Getters ###
  ###############

  isSelected: ->
    return @$el.hasClass "currently-being-read"

  isChecked: ->
    return @diviCheck?.hasClass "checked"

  ###############
  ### Actions ###
  ###############

  select: (options) ->
    return if @isSelected()

    @$el.addClass("currently-being-read")

    @trigger("selected", this) unless options?.silent?

  deselect: (options) ->
    return if not @isSelected()

    @$el.removeClass("currently-being-read")

    @trigger("deselected", this) unless options?.silent?

  updateCheckStyles: ->
    if @diviCheck.hasClass "checked"
      @$el.addClass("checked-email-thread")
    else
      @removeCheckStyles()

  removeCheckStyles: ->
    @$el.removeClass("checked-email-thread")

  toggleCheck: ->
    if @diviCheck.hasClass "checked" then @uncheck() else @check()

  check: (options) ->
    return if @isChecked()

    @diviCheck.iCheck("check")
    @updateCheckStyles()

    @trigger("checked", this) unless options?.silent?

  uncheck: (options) ->
    return if not @isChecked()

    @diviCheck.iCheck("uncheck")
    @updateCheckStyles()

    @trigger("unchecked", this) unless options?.silent?

  markRead: (options) ->
    @$el.removeClass("unread")
    @$el.addClass("read")

    @trigger("markRead", this) unless options?.silent?

  markUnread: (options) ->
    @$el.removeClass("read")
    @$el.addClass("unread")

    @trigger("markUnread", this) unless options?.silent?
