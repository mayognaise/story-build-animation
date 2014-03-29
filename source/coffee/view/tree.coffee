class Tree
  constructor: (@elem, @width, @height, @walkingBirdData, @walkingBirdScale) ->
    @_force = d3.layout.force()
      .size([@width*2, @height*2/4])
      .nodes([{x:@width,y:@height,fixed:true}])
      .linkDistance(20) # 20
      .linkStrength(0.5) # 0-1, 1
      .charge(@height / -20) # -30
      .on('tick', => @tick())
    @restart()

  restart: ->
    walkingBirdData = @walkingBirdData
    walkingBirdScale = @walkingBirdScale
    link = @link().data(@links())
    link.enter().insert('line', '.node')
      .attr('class', 'link')

    node = @node().data(@nodes())
    node.enter().insert('g', '.cursor')
      .attr('class', 'node')
      .each (d) ->
        el = d3.select(@)
        if d.last is true and Math.random() < .05
          el.classed('walking_bird_group', true)
          wbg = new GroupView(el, 'wbg')
          wb = new WalkingBird(wbg.elem(), 'walking_bird', d.type, walkingBirdData)
          wbg.scale(walkingBirdScale).rotate(d.rotation)
          d.wbg = wbg
        else
          el.append('circle').attr('r', 1)
    @start()

  createBranch: (onComplete) ->
    count = 0
    arr = []
    max = 4
    iid = setInterval =>
      if ++count <= max
        amount = 1
        for index in [1..count]
          amount *= index
        nodes = @nodes()
        arr = []
        nodes.forEach (node, index) ->
          if index >= nodes.length - amount
            for num in [0..Math.min(8,amount)]
              arr.push([
                {
                  x:(node.x+(num-amount/2)*10)
                  y:node.y
                  last: count is max
                  rotation:(~~(Math.random()*80)+5)
                  type:(~~(Math.random()*3) + 1)
                },
                nodes[index]
              ])
        for dat in arr
          @add(dat[0], dat[1])
      else
        clearInterval(iid)
        if onComplete then onComplete()
    , 400

    target = @nodes()[0]
    @add({x:@width,y:target.y-20}, target)

  wind: (ran = 20) ->
    nodes = @nodes()
    nodes.forEach (node) ->
      node.x += Math.random() * ran
      if node.wbg
        node.rotation = ~~(Math.random()*160)-80
        node.wbg.rotate(node.rotation)

    @restart()

  add: (node, target) ->
    nodes = @nodes()
    links = @links()
    nodes.push(node)
    if target
      x = target.x - node.x
      y = target.y - node.y
      links.push(source: node, target: target)
    @restart()

  tick: ->
    @link()
      .attr('x1', (d) -> d.source.x)
      .attr('y1', (d) -> d.source.y)
      .attr('x2', (d) -> d.target.x)
      .attr('y2', (d) -> d.target.y)

    @node()
      .attr('transform', (d) -> 'translate('+d.x+','+d.y+')')

  nodes: ->
    @_force.nodes()

  links: ->
    @_force.links()

  node: ->
    @elem.selectAll('.node')

  link: ->
    @elem.selectAll('.link')

  start: ->
    @_force.start()
  stop: ->
    @_force.stop()


