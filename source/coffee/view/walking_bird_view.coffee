BASE_TIME = 500
UP_TIME = 400
DOWN_TIME = 800
WING_ORIGIN = {x: 253, y: 253}
# ================================================
class WalkingBird extends BaseView
  constructor: (@parent, @id, @type, @data) ->
    @y = 0
    @group = new GroupView(@parent, @id, _.clone(WING_ORIGIN))
    @group.addType(@type)
    @group.hide()
    @elem = @group.target()
    super(@parent, @id, @type, @data)
  onLoadSVG: ->
    @back = new WalkingBirdBack(@elem, @data)
    @legs = new WalkingBirdLegs(@elem, @data)
    @body = new WalkingBirdBody(@elem, @data)
    @wings = new WalkingBirdWings(@elem, @data)
    @dot = new PathView(@elem, @data, 'dot')
    @dot.hide()
    @mouth = new PolygonView(@elem, @data, 'mouth')
    @mouth.hide()
    @eye = new WalkingBirdEye(@elem, @data)

    @resize()
    @group.show()
    # @loop()

  bodyHeight: ->
    180

  bodyWidth: ->
    505

  loop: ->
    @open =>
      @flyFlag = true
      @fly()
      setTimeout =>
        @close =>
          # @loop()
      , 6 * 1000

  resize: (sec = 0) ->
    # @group.translate({x:@width/2,y:@height/2+@y}, sec)
    @group.translate({x:0,y:@y}, sec)
    @

  open: (onComplete) ->
    setTimeout =>
      @dot.show()
      @wings.open()
      setTimeout =>
        @wings.showBelow()
        setTimeout =>
          @body.show()
          @eye.show()
          @legs.show()
          setTimeout =>
            @back.show()
            @mouth.show()
            if onComplete then onComplete(@)
          , BASE_TIME/2
        , 100
      , BASE_TIME
    , BASE_TIME
    @

  close: (onComplete) ->
    @fly(true)
    @flyFlag = false
    @body.hide()
    @eye.hide()
    @mouth.hide()
    @legs.hide()
    setTimeout =>
      @back.hide()
      @wings.close()
      @dot.hide()
      if onComplete
        setTimeout ->
          onComplete()
        , BASE_TIME/2
    , 100
    @

  fly: (up) ->
    return unless @flyFlag
    if up
      @wings.up()
      @body.up()
      @legs.up()
      @back.up()
      @y = 0
      up = false
      duration = UP_TIME
    else
      @wings.down()
      @body.down()
      @legs.down()
      @back.down()
      @y = 100 + ~~(Math.random()*200)
      up = true
      duration = DOWN_TIME
    @resize(duration)
    @iid = setTimeout =>
      if @flyFlag then @fly(up)
    , duration
    @

# ================================================
class WalkingBirdBack
  constructor: (@elem, @data) ->
    @back = new PolygonView(@elem, @data, 'back', {x:252, y:262})
    @hide()
  show: ->
    @back.show().scale(0.1)
  hide: ->
    @back.hide().scale(0.1)
  up: ->
    @back.scale(0.1, UP_TIME)
  down: ->
    @back.scale(1, DOWN_TIME)

# ================================================
class WalkingBirdBody
  constructor: (@elem, @data) ->
    @body = new PathView(@elem, @data, 'body')
    @body.hide()
    @body_after = new PathView(@elem, @data, 'body_after')
    @body_after.hide()
    @body_fly = new PathView(@elem, @data, 'body_fly')
    @body_fly.hide()
  up: ->
    @body.show().changeD(@body_after.d(), UP_TIME)
  down: ->
    @body.show().changeD(@body_fly.d(), DOWN_TIME)
  show: ->
    @body.show().changeD(@body_after.d(), BASE_TIME/2)
  hide: ->
    @body.show().changeD(@body.d(), BASE_TIME/2)
    setTimeout =>
      @body.hide()
    , 100

# ================================================
class WalkingBirdEye
  constructor: (@elem, @data) ->
    @white_eye = new CircleView(@elem, @data, 'white_eye', 30, {x: 307, y: 270})
    @white_eye.hide().circleScale(0.3)
    @black_eye = new CircleView(@elem, @data, 'black_eye', 17, {x: 307, y: 270})
    @black_eye.hide().circleScale(0.3)
  show: ->
    @white_eye.show().circleScale(1, BASE_TIME/2)
    @black_eye.show().circleScale(1, BASE_TIME/2)
  hide: ->
    @white_eye.show().circleScale(0.3, BASE_TIME/2)
    @black_eye.show().circleScale(0.3, BASE_TIME/2)
    setTimeout =>
      @white_eye.hide()
      @black_eye.hide()
    , 100



# ================================================
class WalkingBirdLegs
  constructor: (@elem, @data) ->
    @leftLeg = new WalkingBirdLeg(@elem, @data, 'left',{x:248,y:337})
    @rightLeg = new WalkingBirdLeg(@elem, @data, 'right',{x:260,y:337})
  show: ->
    @leftLeg.show()
    @rightLeg.show()
  hide: ->
    @leftLeg.hide()
    @rightLeg.hide()
  up: ->
    @leftLeg.up()
    @rightLeg.up()
  down: ->
    @leftLeg.down()
    @rightLeg.down()
# ================================================
class WalkingBirdLeg
  constructor: (@elem, @data, @side, origin) ->
    @leg = new PathView(@elem, @data, "#{@side}_leg", origin)
    @hide()
  show: ->
    @leg.show().scale(1,BASE_TIME/2)
  hide: ->
    @leg.hide().scale(0)
  up: ->
    @leg.rotate(0, UP_TIME)
  down: ->
    @leg.rotate((if @side is 'left' then 30 else -30), DOWN_TIME)


# ================================================
class WalkingBirdWings
  constructor: (@elem, @data) ->
    @leftWing = new WalkingBirdWing(@elem, @data, 'left')
    @rightWing = new WalkingBirdWing(@elem, @data, 'right')
  open: ->
    @leftWing.open()
    @rightWing.open()
    setTimeout =>
      @showBelow()
    , BASE_TIME
  close: ->
    @hideBelow()
    setTimeout =>
      @leftWing.close()
      @rightWing.close()
    , BASE_TIME/2
  hideBelow: ->
    @leftWing.hideBelow()
    @rightWing.hideBelow()  
  showBelow: ->
    @leftWing.showBelow()
    @rightWing.showBelow()
  up: ->
    @leftWing.up()
    @rightWing.up()
  down: ->
    @leftWing.down()
    @rightWing.down()

# ================================================
class WalkingBirdWing
  constructor: (@elem, @data, @side) ->
    gap = 40
    origin = if @side is 'left' then {x: WING_ORIGIN.x - gap, y: WING_ORIGIN.y - gap} else {x: WING_ORIGIN.x + gap, y: WING_ORIGIN.y - gap}
    @group = new GroupView(@elem, "#{@side}_wing_group", origin)
    # @group = new GroupView(@elem, "#{@side}_wing_group", _.clone(WING_ORIGIN))
    target = @group.target()

    @wing = new PathView(target, @data, "#{@side}_wing")
    @wingAfter = new PathView(target, @data, "#{@side}_wing_after")
    @wing.hide()
    @wingAfter.hide()

    @leaf = new PathView(target, @data, "#{@side}_leaf", _.clone(WING_ORIGIN))
    @leaf.rotate(@rotation(),0)

  rotation: ->
    if @side is 'left' then -135 else 135
  open: ->
    @leaf.rotate(0,BASE_TIME)
  close: ->
    @leaf.rotate(@rotation(),BASE_TIME/2)
  showBelow: ->
    @wing.show().changeD(@wingAfter.d(), BASE_TIME/2)
  hideBelow: ->
    @wing.show().changeD(@wing.d(), BASE_TIME/2)
    setTimeout =>
      @wing.hide()
    , BASE_TIME/2
  up: ->
    @group.rotate(0, UP_TIME)
  down: ->
    @group.rotate((if @side is 'left' then 22.5 else -22.5), DOWN_TIME)