#= require view/baseview.coffee
#= require view/partsview.coffee
#= require view/pathview.coffee
#= require view/circleview.coffee
#= require view/polygonview.coffee
#= require view/groupview.coffee
#= require view/walking_bird.coffee
#= require view/tree.coffee

walkingBirdData = undefined
walkingBirdScale = .1
walkingBirds = []

openBirds = (svg) ->
  parent = svg.append('g')
  svg.selectAll('.walking_bird_group')
    .each( (d) ->
      group = new GroupView(parent, 'wbg')
      group.translate(d)
      wb = new WalkingBird(group.elem(), 'walking_bird', walkingBirdData)
      group.scale(walkingBirdScale).rotate(d.rotation)
      d.a = ~~(Math.random()*20) + 15
      d.el = wb
      d.group = group
      walkingBirds.push(d)
    )
    .remove()

  count = 0
  end = 100
  open = 20
  iid = setInterval ->
    for d, index in walkingBirds
      group = d.group
      pos = group.translate()
      if d.open
        pos.scale = walkingBirdScale + .03 * (count - open) / open
        pos.y += Math.pow(1.005,count)
        unless group.rotation() < 10
          pos.deg = (group.rotation() + d.a/2) % 360
      else
        pos.x += d.a / 4
        pos.y += Math.pow(1.04,count)
        pos.deg = (group.rotation() + d.a) % 360
      group.translate(pos)
      if count is open and index % 3 is 0
        d.openCount = open + ~~(Math.random()*30)
      if count is d.openCount
        d.el.open (el) ->
          el.flyFlag = true
          el.fly()
        d.open = true
    if ++count > end
      clearInterval(iid)
      for d, index in walkingBirds
        group = d.group
        if d.open
          deg = ~~(Math.random()*12) - 6
          group.rotate(deg, 1500)
        else
          group.remove()
  , 33


start = ->
  width = window.innerWidth
  height = window.innerHeight
  initX = 200
  force = undefined

  svg = d3.select('body').append('svg')
    .attr('width', width)
    .attr('height', height)
  
  group = svg.append('g').attr('id', 'tree')
  tree = new Tree(group, initX, height, walkingBirdData, walkingBirdScale)
  tree.createBranch ->
    count = 0
    end = 30
    iid = setInterval ->
      if Math.random() < .2
        tree.wind()
      if ++count > end
        tree.wind(50)
        openBirds(svg)
        clearInterval(iid)
        group.transition()
          .duration(2500)
          # .attr('transform', 'translate(0,0)')
          .attr('transform', 'translate(-'+(initX*3)+',0)')
          .each 'end', ->
            tree.stop()
            group.remove()
    , 100

loadSVG = (id, onComplete) ->
  d3.xml "svg/#{id}.svg", 'image/svg+xml', (data) ->
    walkingBirdData = data
    if onComplete then onComplete(data)

init = ->
  loadSVG('walking_bird', start)
init()