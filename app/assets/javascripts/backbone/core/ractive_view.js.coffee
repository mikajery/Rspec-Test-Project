class TuringEmailApp.Views.RactiveView extends TuringEmailApp.Views.BaseView
  render: ->
    super()

    data     = _.result(@, "data")
    computed = {}

    for k, v of data["computed"]
      parts = k.split "."
      item  = parts.pop()
      if item[0] == "_"
        parts.push(item[1..])
        orig = parts.join "."

        computed[k] =
          "get":
            if _.isString(v["get"])
              v["get"].replace("${_}", "${#{orig}}")
            else
              v["get"]
          "set":
            if _.isFunction(v["set"])
              ((orig, func) -> (val) -> @set(orig, func(val)))(orig, v["set"])
            else
              v["set"]
      else
        computed[k] = v

    @ractive = new Ractive
      "template": @template(data["static"])
      "el": @$el.get()
      "data": data["dynamic"]
      "computed": computed
      "adapt": ["Backbone"]

    @


  remove: ->
    super()

    @ractive.teardown()


  data: ->
    "static": {}
    "dynamic": {}
    "computed": {}
