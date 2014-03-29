class PathView extends PartsView
  constructor: (@parent, @data, @id, @origin) ->
    g = @parent.append('g')
      .attr('id', @id)

    if @origin
      g.attr('transform', @transform(@origin))
      tgt = g.append('g')
        .attr('transform', @transform(x:@origin.x*-1, y:@origin.y*-1))
    else
      tgt = g

    tgt.append('path')
      .attr('fill', @fill())
      .attr('d', @d())

    @elem(g)

  changeD: (d, sec = 0) ->
    @elem().select('path')
      .transition()
      .duration(sec)
      .attr('d', d)
    @

  d: (d) ->
    if d isnt undefined
      @_d = d
    unless @_d
      @_d = @path().attr('d')
    @_d