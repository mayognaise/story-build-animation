BASE_TIME = 500
UP_TIME = 400
DOWN_TIME = 800
WING_ORIGIN = {x: 253, y: 253}
# ================================================
class Sun extends BaseView
  onLoadSVG: ->
    @outside = new SunOutside(@elem, @data)
    @core = new SunCore(@elem, @data)
    @group.show()

# ================================================
class SunCore
  constructor: (@elem, @data) ->
    @body = new PathView(@elem, @data, 'core')

class SunOutside
  constructor: (@elem, @data) ->
    @body = new PathView(@elem, @data, 'outside')
