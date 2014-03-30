class GroupView extends PartsView
  constructor: (@parent, @klass, @origin) ->
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

    @_target = tgt
    @elem(g)

  target: ->
    @_target