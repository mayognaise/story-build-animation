class BaseView
  constructor: (@parent, @id, @data) ->
    @width = window.innerWidth
    @height = window.innerHeight
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
    d3.xml "svg/#{@id}.svg", 'image/svg+xml', (@data) => @onLoadSVG()

  resize: ->
    console.log(@width, @height)