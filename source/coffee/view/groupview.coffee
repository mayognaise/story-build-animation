class GroupView extends PartsView
  constructor: (@parent, id, @origin) ->
    @id("#{id}_#{(new Date).getTime()}")
    g = @parent.append('g')
      .attr('id', @id())
      .attr('class', id)

    if @origin
      g.attr('transform', @transform(@origin))
      tgt = g.append('g')
        .attr('transform', @transform(x:@origin.x*-1, y:@origin.y*-1))
    else
      tgt = g

    @_target = tgt
    @elem(g)

  id: (id) ->
    if id isnt undefined
      @_id = id
    @_id

  target: ->
    @_target