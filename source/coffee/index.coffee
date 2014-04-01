#= require view/base_view.coffee
#= require view/parts_view.coffee
#= require view/path_view.coffee
#= require view/circle_view.coffee
#= require view/polygon_view.coffee
#= require view/group_view.coffee
#= require view/walking_bird_view.coffee
#= require view/tree_view.coffee
#= require view/sun_view.coffee

#= require collection/audio_collection.coffee

width = window.innerWidth
height = window.innerHeight

audio = undefined

initX = width / 2
initScale = .1 / 600 * height

svg = undefined
svgData = {}

endFlag = false

tree = undefined
treeGroup = undefined

sun = undefined
sunGroup = undefined

sky = undefined

walkingBirdId = 'walking_bird'
sunId = 'sun'

# =============================
flyBird = (d) ->
  el = d.el
  el.flyFlag = true
  el.fly()
  iid = setInterval ->
    if endFlag
      clearInterval(iid)
      return
    group = d.group
    pos = group.translate()
    bottom = d.el.bodyHeight() * group.scale()
    bodyWidth = d.el.bodyWidth() * group.scale()
    y = bottom + pos.y
    up = 50
    if y > height or pos.x > width + bodyWidth
      clearInterval(iid)
      el.flyFlag = false
      group.remove()
    else if y >= height - up
      el.fly(true)
      el.flyFlag = false
      group.rotate(0)
      pos.y += up
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
    if endFlag
      clearInterval(iid)
      return
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
      d.el = new WalkingBird group.elem(), walkingBirdId,
        type: d.type
        data: svgData[walkingBirdId]
      arr.push(d)
    )
    .remove()

  if arr.length > 0
    count = 0
    open = 60
    end = open + 80
    iid = setInterval ->
      if endFlag
        clearInterval(iid)
        return
      newArr = []
      for d, index in arr
        group = d.group
        pos = group.translate()
        if count is open
          if index % 7 is 0
            d.openCount = open + ~~(Math.random()*30)
          else
            d.pow = 1.03
        if count is d.openCount
          openBird(d, count, open)
        else
          newArr.push(d)
        pos.x -= d.a / 8
        pos.y += Math.pow(d.pow or 1.0001,count)
        pos.deg = (group.rotation() + d.a) % 360
        group.translate(pos)
      arr = newArr
      if count is open + 30
        audio.fadeOut('wind')
        audio.play('open')
        sky.transition()
          .duration(1000)
          .style('opacity', '0')
          .each('end', -> sky.remove())
        setTimeout ->
          audio.fadeIn('hogaraka')
        , 5000
      if ++count > end
        clearInterval(iid)
        for d, index in arr
          group = d.group
          group.remove() 
    , 33
  else
    console.log('no bird')

  # audio.play('horror')
  audio.stop()

# =============================
wind = ->
  count = 0
  end = 8000
  interval = 600
  iid = setInterval ->
    if endFlag
      clearInterval(iid)
      return
    num = count * 10
    if ++count > end / interval
      tree.wind(num)
      animateBirds()
      clearInterval(iid)
      treeGroup.transition()
        .duration(2500)
        .attr('transform', 'translate(-'+(initX*3)+',0)')
        .each 'end', ->
          tree.stop()
          treeGroup.remove()
    else
      ran = Math.random() * num * 2 - num
      tree.wind(ran, interval)
  , interval

  audio.play('wind')
  
# =============================
cloudy = ->
  time = 3000
  sun.translate({x: width + 100}, time)
  sky.transition()
    .duration(time)
    .attr('transform', 'translate(0,0)')
    # .each('end', wind)

# =============================
createDarkSky = ->
  gradient = svg.append('svg:defs')
    .append('svg:linearGradient')
    .attr('id', 'gradient')
    .attr('x1', '0%')
    .attr('y1', '0%')
    .attr('x2', '0%')
    .attr('y2', '80%')
    .attr('spreadMethod', 'pad')

  gradient.append('svg:stop')
    .attr('offset', '0%')
    .attr('stop-color', '#909fa3')
    .attr('stop-opacity', 1)

  gradient.append('svg:stop')
    .attr('offset', '100%')
    .attr('stop-color', '#f2ede2')
    .attr('stop-opacity', 1)

  sky = svg.append('svg:rect')
    .attr('width', width)
    .attr('height', height)
    .attr('transform', "translate(0,#{-height})")
    .style('fill', 'url(#gradient)')

creatTree = ->
  leafData =
    klass: WalkingBird
    id: walkingBirdId
    data: svgData[walkingBirdId]
    scale: initScale
  
  treeGroup = svg.append('g').attr('id', 'tree')
  tree = new Tree(treeGroup, initX, height, leafData)

creatSun = ->
  sunGroup = svg.append('g').attr('id', 'sun')
  sun = new Sun sunGroup, sunId,
    data: svgData[sunId]
    scale: initScale
    x: width * 2 / 3
    y: height * 1 / 15

start = ->
  svg = d3.select('body').append('svg')
    .attr('width', width)
    .attr('height', height)

  createDarkSky()
  creatSun()
  creatTree()

  sun.play()

  audio = new AudioCollection ['wind', 'open', 'hogaraka'], ->
    audio.play 'hogaraka', ->
      tempo = 3150
      setTimeout ->
        tree.march(tempo)
        setTimeout ->
          tree.clear()
          cloudy()
          wind()
          audio.fadeOut('hogaraka')
        , 5000
      , tempo
      tree.createBranch()



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
  loadSVGs([walkingBirdId, sunId], start)
  # queue()
  #   .defer(fs.stat, __dirname + "/../package.json")
  #   .defer(fs.stat, __dirname + "/../package2.json")
  #   .await (error, file1, file2) -> console.log(file1, file2)

kill = ->
  endFlag = true
  if svg then svg.remove()

init()