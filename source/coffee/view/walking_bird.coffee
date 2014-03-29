time = 500
upTime = 400
downTime = 800
wingOrigin = {x: 253, y: 253}
# ================================================
class WalkingBird extends BaseView
  constructor: (@parent, @id, @width, @height) ->
    @y = 0
    @group = new GroupView(@parent, @id, _.clone(wingOrigin))
    @group.hide()
    @elem = @group.target()
    super(@parent, @id, @width, @height)
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
          , time/2
        , 100
      , time
    , time
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
        , time/2
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
      duration = upTime
    else
      @wings.down()
      @body.down()
      @legs.down()
      @back.down()
      @y = 100
      up = true
      duration = downTime
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
    @back.show().scale(0)
  hide: ->
    @back.hide().scale(0)
  up: ->
    @back.scale(0, upTime)
  down: ->
    @back.scale(1, downTime)

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
    @body.show().changeD(@body_after.d(), upTime)
  down: ->
    @body.show().changeD(@body_fly.d(), downTime)
  show: ->
    @body.show().changeD(@body_after.d(), time/2)
  hide: ->
    @body.show().changeD(@body.d(), time/2)
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
    @white_eye.show().circleScale(1, time/2)
    @black_eye.show().circleScale(1, time/2)
  hide: ->
    @white_eye.show().circleScale(0.3, time/2)
    @black_eye.show().circleScale(0.3, time/2)
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
    @leg.show().scale(1,time/2)
  hide: ->
    @leg.hide().scale(0)
  up: ->
    @leg.rotate(0, upTime)
  down: ->
    @leg.rotate((if @side is 'left' then 30 else -30), downTime)


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
    , time
  close: ->
    @hideBelow()
    setTimeout =>
      @leftWing.close()
      @rightWing.close()
    , time/2
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
    origin = if @side is 'left' then {x: wingOrigin.x - gap, y: wingOrigin.y - gap} else {x: wingOrigin.x + gap, y: wingOrigin.y - gap}
    @group = new GroupView(@elem, "#{@side}_wing_group", origin)
    # @group = new GroupView(@elem, "#{@side}_wing_group", _.clone(wingOrigin))
    target = @group.target()

    @wing = new PathView(target, @data, "#{@side}_wing")
    @wingAfter = new PathView(target, @data, "#{@side}_wing_after")
    @wing.hide()
    @wingAfter.hide()

    @leaf = new PathView(target, @data, "#{@side}_leaf", _.clone(wingOrigin))
    @leaf.rotate(@rotation(),0)

  rotation: ->
    if @side is 'left' then -135 else 135
  open: ->
    @leaf.rotate(0,time)
  close: ->
    @leaf.rotate(@rotation(),time/2)
  showBelow: ->
    @wing.show().changeD(@wingAfter.d(), time/2)
  hideBelow: ->
    @wing.show().changeD(@wing.d(), time/2)
    setTimeout =>
      @wing.hide()
    , time/2
  up: ->
    @group.rotate(0, upTime)
  down: ->
    @group.rotate((if @side is 'left' then 20 else -20), downTime)