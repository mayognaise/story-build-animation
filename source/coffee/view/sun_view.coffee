SUN_PLAY_TIME = 2000
# ================================================
class Sun extends BaseView
  onLoadSVG: ->
    @outside = new SunOutside(@elem, @data)
    @core = new SunCore(@elem, @data)
    @group.show()

  play: ->
    fn = =>
      @outside.play()      
      @core.play()      
    @iid = setInterval =>
      fn()
    , SUN_PLAY_TIME
    fn()

  stop: ->
    @clear()
    @outside.stop()      
    @core.stop()

# ================================================
class SunCore
  constructor: (@elem, @data) ->
    @body = new PathView(@elem, @data, 'core', {x:315, y:315})
  play: ->
    rotation = @body.rotation()
    @body.rotate(@body.rotation()+90, SUN_PLAY_TIME, 'linear')
  stop: ->


class SunOutside
  constructor: (@elem, @data) ->
    @body = new PathView(@elem, @data, 'outside', {x:315, y:315})
    @stop()
  play: ->
    @playFlag = !@playFlag
    scale = if @playFlag then .9 else 1.1
    @body.scale(scale, SUN_PLAY_TIME)
  stop: ->
    @playFlag = false
    @body.scale(1, 500)


