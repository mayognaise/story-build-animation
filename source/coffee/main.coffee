#= require view/baseview.coffee
#= require view/partsview.coffee
#= require view/pathview.coffee
#= require view/circleview.coffee
#= require view/polygonview.coffee
#= require view/groupview.coffee
#= require view/walking_bird.coffee
#= require view/tree.coffee

width = window.innerWidth
height = window.innerHeight

walkingBirdData = undefined
walkingBirdScale = .1
walkingBirds = []
# =============================
fly = ->
  # for d, index in walkingBirds
    # console.log(d.a)
  iid = setInterval ->
    arr = []
    for d, index in walkingBirds
      el = d.el
      if el.flyFlag is true
        group = d.group
        pos = group.translate()
        bottom = d.el.bottom() * group.scale()
        y = bottom + pos.y
        up = 30
        if y >= height - up
          arr.push(d)
          el.fly(true)
          el.flyFlag = false
          group.rotate(0)
          pos.y = y - bottom + up
          group.translate(pos, 500)
        else
          pos.x += d.a / 35 * 1.2
          pos.y += 2
          group.translate(pos)
      else
        arr.push(d)

    if arr.length is walkingBirds.length
      clearInterval(iid)
      # console.log('done')
  , 33

# =============================
openBirds = (svg) ->
  parent = svg.append('g')
  svg.selectAll('.walking_bird_group')
    .each( (d) ->
      group = new GroupView(parent, 'wbg')
      group.translate(d)
      wb = new WalkingBird(group.elem(), 'walking_bird', d.type, walkingBirdData)
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
        if count < d.openCount + 40
          pos.scale = walkingBirdScale + .03 * (count - open) / open
          pos.y += Math.pow(1.005,count)
        unless group.rotation() < 30
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
      arr = []
      for d, index in walkingBirds
        group = d.group
        if d.open
          deg = ~~(Math.random()*12) - 6
          group.rotate(deg, 1500)
          arr.push(d)
        else
          group.remove()
      walkingBirds = arr
      fly()
  , 33

# =============================
start = ->
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