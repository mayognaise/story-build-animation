class Tree
  constructor: (@elem, @width, @height, @alternateObj) ->
    @_force = d3.layout.force()
      .size([@width*2, @height*2/3])
      .nodes([{x:@width,y:@height,fixed:true}])
      .linkDistance(20) # 20
      .linkStrength(0.5) # 0-1, 1
      .charge(@height / -20) # -30
      .on('tick', => @tick())
    @restart()

  # typeCount: 0
  restart: ->
    # typeCount = @typeCount
    alternateObj = @alternateObj
    link = @link().data(@links())
    link.enter().insert('line', '.node')
      .attr('class', 'link')

    node = @node().data(@nodes())
    node.enter().insert('g', '.cursor')
      .attr('class', 'node')
      .each (d) ->
        el = d3.select(@)
        if alternateObj and d.last is true and Math.random() < .05
          # d.type = (typeCount++ % 4) + 1
          el.classed(alternateObj.group or "#{alternateObj.id}_group", true)
          group = new GroupView(el, 'group')
          group.scale(alternateObj.scale or 1).rotate(d.rotation)
          option =
            type: d.type or 1
            data: alternateObj.data
          obj = new alternateObj.klass(group.elem(), alternateObj.id, option)
          d.group = group
          d.el = obj
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

  wind: (ran = 1, sec = 0) ->
    nodes = @nodes()
    nodes.forEach (node) ->
      node.x += ran
      if node.group
        node.group.rotate((Math.random() + 1) * -2 * ran, sec, 'bounce')

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


