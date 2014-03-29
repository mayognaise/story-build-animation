class PolygonView extends PartsView
  constructor: (@parent, @data, @klass, @origin) ->
    @id("#{@klass}_#{(new Date).getTime()}")
    g = @parent.append('g')
      .attr('id', @id())
      .attr('class', @klass)

    if @origin
      g.attr('transform', @transform(@origin))
      tgt = g.append('g')
        .attr('transform', @transform(x:@origin.x*-1, y:@origin.y*-1))
    else
      tgt = g

    @_polygon = tgt.append('polygon')
      .attr('fill', @fill())
      .attr('points', @points())

    @elem(g)    

  points: (points) ->
    if points isnt undefined
      @_points = points
    unless @_points
      @_points = @path().attr('points')
    @_points