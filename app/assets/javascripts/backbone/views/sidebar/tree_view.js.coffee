class TuringEmailApp.Views.TreeView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/sidebar/tree"]

  events:
    "click .tm_tree-bullet": "onTreeBullet"
    "click a:not(.default-functionality-sidebar-link)": "onLink"
    "click a.default-functionality-sidebar-link": "onDefaultFunctionalityLinkSelected"

  # TODO write test
  initialize: (options) ->
    super(options)

    @app = options.app

    @listenTo(options.app, "change:emailFolderUnreadCount", @emailFolderUnreadCountChanged)

    @listenTo(@collection, "add", @render)
    @listenTo(@collection, "remove", @render)
    @listenTo(@collection, "reset", @render)
    @listenTo(@collection, "destroy", @remove)

  render: ->
    startTime = Date.now()

    @generateTree()

    systemBadges =
      inbox: @collection.get("INBOX")?.badgeString()
      draft: @collection.get("DRAFT")?.badgeString()

    @$el.html(@template(nodeName: "", node: @tree, systemBadges: systemBadges))

    @select(@collection.get(@selectedItem().get("label_id")), silent: true) if @selectedItem()?

    @

  generateTree: ->
    @tree = {emailFolder: null, children: {}}

    for emailFolder in @collection.models
      emailFolderJSON = emailFolder.toJSON()
      emailFolderJSON.badgeString = emailFolder.badgeString()

      nameParts = emailFolderJSON.name.split("/")
      node = @tree

      for part in nameParts
        if not node.children[part]?
          node.children[part] = {emailFolder: null, children: {}}

        node = node.children[part]

      node.emailFolder = emailFolderJSON

  ######################
  ### Event Handlers ###
  ######################

  onTreeBullet: (evt) ->
    evt.preventDefault()
    evt.stopPropagation()
    evtTarget = $(evt.target)
    evtTarget.closest("li").children("ul").toggle()
    evtTarget.toggleClass("tm_tree-bullet-collapsed tm_tree-bullet-expanded")

  onLink: (evt) ->
    emailFolderID = $(evt.currentTarget).attr("href")
    emailFolder = @collection.get(emailFolderID)
    @select(emailFolder, force: true)

  onDefaultFunctionalityLinkSelected: (evt) ->
    @$("a").removeClass("tm_folder-selected")
    @$(evt.currentTarget).addClass("tm_folder-selected")

  ###############
  ### Getters ###
  ###############

  selectedItem: ->
    return @selectedEmailFolder

  ###############
  ### Actions ###
  ###############

  # TODO write test
  select: (emailFolder, options) ->
    return if @selectedItem() is emailFolder && options?.force != true

    if @selectedItem()?
      @$("a.default-functionality-sidebar-link").removeClass("tm_folder-selected")
      @$("#" + @selectedItem().get("label_id")).removeClass("tm_folder-selected")
      @trigger("emailFolderDeselected", this, @selectedItem())

    @selectedEmailFolder = emailFolder
    @$("#" + emailFolder?.get("label_id")).addClass("tm_folder-selected") if emailFolder?

    @trigger("emailFolderSelected", this, emailFolder) if (not options?.silent?) || options.silent is false

  updateBadgeCount: (emailFolder) ->
    emailFolderID = emailFolder.get("label_id")

    if emailFolderID is "INBOX"
      @$el.find('.tm_folder-inbox .tm_tree-badge').html(emailFolder.badgeString())
    else
      @$el.find('a[href="' + emailFolderID + '"]>.badge').html(emailFolder.badgeString())

  #############################
  ### TuringEmailApp Events ###
  #############################

  # TODO write test
  emailFolderUnreadCountChanged: (app, emailFolder) ->
    @updateBadgeCount(emailFolder)
