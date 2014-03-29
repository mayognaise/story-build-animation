class PartsView
  show: ->
    @elem().classed("hide", false)
    @

  hide: ->
    @elem().classed("hide", true)
    @

  id: (id) ->
    if id isnt undefined
      @_id = id
    @_id

  addType: (type) ->
    @elem().attr('type', type)

  remove: ->
    @elem().remove()

  rotation: ->
    if @origin
      @origin.deg or 0
    else
      0

  rotate: (deg, sec = 0) ->
    @origin ?= {}
    @origin.deg = deg
    @elem().transition()
      .duration(sec)
      .attr('transform', @transform(@origin))
    @

  translate: (dat, sec = 0) ->
    if dat
      @origin ?= {}
      @origin = _.extend(@origin, dat)
      @elem().transition()
        .duration(sec)
        .attr('transform', @transform(@origin))
      @
    else
      if @origin
        {x:@origin.x or 0,y:@origin.y or 0}
      else
        {x:0,y:0}

  scale: (scale, sec = 0) ->
    if scale
      @origin ?= {}
      @origin.scale = scale
      @elem().transition()
        .duration(sec)
        .attr('transform', @transform(@origin))
      @
    else
      if @origin
        @origin.scale or 1
      else
        1

  elem: (elem) ->
    if elem isnt undefined
      @_elem = elem
    @_elem

  path: ->
    unless @_path
      el = d3.select(@data).select("##{@klass}")
      @_path = el.select(el[0][0].firstElementChild.nodeName)
    @_path

  fill: (hex) ->
    if hex isnt undefined
      @_fill = hex
    unless @_fill
      @_fill = @path().attr('fill')
    @_fill

  transform: (dat) ->
    "translate(#{dat.x or 0},#{dat.y or 0}) rotate(#{dat.deg or 0}) scale(#{if dat.scale isnt undefined then dat.scale else 1})"


