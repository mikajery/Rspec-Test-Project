sinon.backbone =
  spy: (object, event) ->
    spy = sinon.spy()
    object.on(event, spy)
    
    spy.restore = ->
      object.off(@event, spy)
    
    return spy
