class Force
  constructor: (@svg, @width = window.innerWidth, @height = window.innerHeight) ->
    @_force = d3.layout.force()
      .size([@width, @height/2])
      # .size([@width, @height])
      # .size([100, 100])
      .nodes([{x:@width/2,y:@height,fixed:true}])
      .linkDistance(20) # 20
      # .linkStrength(.2) # 0-1, 1
      .charge(-300) # -30
      .on('tick', => @tick())

  tick: ->
    @svg.selectAll('.link')
      .attr('x1', (d) -> d.source.x)
      .attr('y1', (d) -> d.source.y)
      .attr('x2', (d) -> d.target.x)
      .attr('y2', (d) -> d.target.y)

    @svg.selectAll('.node')
      .attr('cx', (d) -> d.x)
      .attr('cy', (d) -> d.y)

  nodes: ->
    @_force.nodes()

  links: ->
    @_force.links()

  node: ->
    @svg.selectAll('.node').data(@nodes())

  link: ->
    @svg.selectAll('.link').data(@links())

  start: ->
    @_force.start()

  drag: ->
    @_force.drag

  size: (w,h) ->
    @_force.size([w, h])


restart = (force) ->
  link = force.link()
  link.enter().insert('line', '.node')
    .attr('class', 'link')

  node = force.node()
  node.enter().insert('circle', '.cursor')
    .attr('class', 'node')
    .attr('r', 5)
    .call(force.drag())
  force.start()

init = ->
  width = 960
  height = 500

  svg = d3.select('body').append('svg')
    .attr('width', width)
    .attr('height', height)
    .on('mousedown', ->
      point = d3.mouse(this)
      node = {x: point[0],y: point[1]}
      # if Math.random() > .5 then node.fixed = true
      nodes = force.nodes()
      links = force.links()
      nodes.push(node)
      nodes.forEach (target) ->
        x = target.x - node.x
        y = target.y - node.y
        if Math.sqrt(x * x + y * y) < 10
          links.push(source: node, target: target)
      restart(force)
    )

  force = new Force(svg, width, height)
  restart(force)
  window.force = force

init()

