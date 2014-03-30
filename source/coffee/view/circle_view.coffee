class CircleView extends PartsView
  constructor: (@parent, @data, @klass, @r, @origin) ->
    @id("#{@klass}_#{(new Date).getTime()}")
    g = @parent.append('g')
      .attr('id', @id())
      .attr('class', @klass)

    if @origin
      g.attr('transform', @transform(@origin))
      tgt = g.append('g')
    else
      tgt = g

    @_circle = tgt.append('circle')
      .attr('fill', @fill())
      .attr('r', @r)

    @elem(g)

  circle: ->
    @_circle

  circleScale: (scale, sec = 0) ->
    @origin ?= {}
    @origin.scale = scale
    @circle().transition()
      .duration(sec)
      .attr('transform', @transform(scale:scale))
    @