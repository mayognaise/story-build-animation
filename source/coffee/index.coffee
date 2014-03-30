#= require view/base_view.coffee
#= require view/parts_view.coffee
#= require view/path_view.coffee
#= require view/circle_view.coffee
#= require view/polygon_view.coffee
#= require view/group_view.coffee
#= require view/walking_bird_view.coffee
#= require view/tree_view.coffee

width = window.innerWidth
height = window.innerHeight

initX = width / 2
initScale = .1

svg = undefined
svgData = {}

tree = undefined
treeGroup = undefined

walkingBirdId = 'walking_bird'

# =============================
flyBird = (d) ->
  el = d.el
  el.flyFlag = true
  el.fly()
  iid = setInterval ->
    group = d.group
    pos = group.translate()
    bottom = d.el.bottom() * group.scale()
    y = bottom + pos.y
    up = 30
    if y >= height - up
      el.fly(true)
      el.flyFlag = false
      group.rotate(0)
      pos.y = y - bottom + up
      group.translate(pos, 500)
      clearInterval(iid)
    else
      pos.x += d.a / 35 * 1.1
      pos.y += 2
      unless group.rotation() < 10
        deg = group.rotation() + d.a/2
        if deg >= 360
          pos.deg = (Math.random()*9)
        else
          pos.deg = deg % 360
      group.translate(pos)
  , 33

openBird = (d, count, open) ->
  el = d.el

  iid = setInterval ->
    group = d.group
    pos = group.translate()
    pos.x += d.a / 35 * 2
    pos.scale = initScale + .075 * (count - open) / open
    pos.y += Math.pow(1.005,count)
    pos.deg = (group.rotation() + d.a) % 360
    group.translate(pos)
  , 33

  el.open (el) ->
    flyBird(d)
    clearInterval(iid)

# =============================
animateBirds = ->
  arr = []
  parent = svg.append('g')
  svg.selectAll(".#{walkingBirdId}_group") 
    .each((d) ->
      group = new GroupView(parent, 'wbg')
      group.translate(d)
      group.scale(initScale).rotate(d.rotation)
      d.group = group
      d.a = ~~(Math.random()*20) + 15
      d.el = new WalkingBird(group.elem(), walkingBirdId, d.type, svgData[walkingBirdId])
      arr.push(d)
    )
    .remove()

  if arr.length > 0
    count = 0
    end = 120
    open = 20
    iid = setInterval ->
      newArr = []
      for d, index in arr
        group = d.group
        pos = group.translate()
        if count is open and index % 3 is 0
          d.openCount = open + ~~(Math.random()*30)
        if count is d.openCount
          openBird(d, count, open)
        else
          newArr.push(d)
        pos.x -= d.a / 4
        pos.y += Math.pow(1.04,count)
        pos.deg = (group.rotation() + d.a) % 360
        group.translate(pos)
      arr = newArr
      if ++count > end
        clearInterval(iid)
        for d, index in arr
          group = d.group
          group.remove()
    , 33
  else
    console.log('no bird')

# =============================
wind = ->
  count = 0
  end = 5000
  interval = 600
  iid = setInterval ->
    if ++count > end / interval
      tree.wind(50)
      animateBirds()
      clearInterval(iid)
      treeGroup.transition()
        .duration(2500)
        .attr('transform', 'translate(-'+(initX*3)+',0)')
        .each 'end', ->
          tree.stop()
          treeGroup.remove()
    else
      ran = Math.random()*60 - 30
      tree.wind(ran, ran * -2)
  , interval

# =============================
start = ->
  svg = d3.select('body').append('svg')
    .attr('width', width)
    .attr('height', height)
  
  leafData =
    klass: WalkingBird
    data: svgData[walkingBirdId]
    scale: initScale
    id: walkingBirdId
  
  treeGroup = svg.append('g').attr('id', 'tree')
  tree = new Tree(treeGroup, initX, height, leafData)
  tree.createBranch(setTimeout(wind, 5000))

# =============================
loadSVG = (id, onComplete) ->
  d3.xml "svg/#{id}.svg", 'image/svg+xml', (data) -> if onComplete then onComplete(data)

loadSVGs = (arr, onComplete) ->
  id = arr.shift()
  loadSVG id, (data) ->
    svgData[id] = data
    if arr.length is 0
      if onComplete then onComplete(svgData)
    else
      loadSVGs(arr, onComplete)

init = ->
  loadSVG([walkingBirdId], start)
  # queue()
  #   .defer(fs.stat, __dirname + "/../package.json")
  #   .defer(fs.stat, __dirname + "/../package2.json")
  #   .await (error, file1, file2) -> console.log(file1, file2)
init()