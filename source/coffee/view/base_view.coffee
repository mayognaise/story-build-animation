class BaseView
  constructor: (@parent, @id, option = {}) ->
    @width = window.innerWidth
    @height = window.innerHeight
    @type = option.type or 1
    if option.data then @data = option.data
    @group = new GroupView(@parent, @id, option.origin)
    @group.addType(@type)
    @group.translate(_.clone(option))
    @group.hide()
    @elem = @group.target()
    unless @data
      if @id then @loadSVG()
    else
      @onLoadSVG()
    window.onresize = =>
      @width = window.innerWidth
      @height = window.innerHeight
      @resize()

  onLoadSVG: ->
    console.log(@data)

  loadSVG: ->
    d3.xml("svg/#{@id}.svg", 'image/svg+xml', (@data) => @onLoadSVG())

  resize: ->
    # console.log(@width, @height)

  remove: ->
    clearTimeout(@tid)
    clearInterval(@iid)
    @group.remove()

  bodyWidth: ->
    Number(d3.select(@data).select('svg').attr('width'))

  bodyHeight: ->
    Number(d3.select(@data).select('svg').attr('height'))