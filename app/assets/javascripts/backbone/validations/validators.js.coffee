_.extend Backbone.Validation.validators,
  isArray: (value, attr, customValue, model) ->
    if not _.isArray(value)
      return "{0} should be an array"

  isDate: (value, attr, customValue, model) ->
    if isNaN(Date.parse(value))
      return "{0} should be datetime string"