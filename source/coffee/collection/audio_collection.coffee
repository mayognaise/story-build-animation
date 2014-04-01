class AudioCollection
  constructor: (soundData = [], onLoad) ->
    @volume = 1
    @fadeTime = 500
    @path = 'audio'
    @soundData = []
    for data in soundData
      audio = @add(data)
      @soundData.push(audio)
    if onLoad
      iid = setInterval =>
        flag = true
        for data in @soundData
          if data.status is 'init'
            flag = false
        if flag is true
          clearInterval(iid)
          onLoad()
      , 2000

  add: (obj) ->
    if _.isString(obj)
      obj = {id: obj}
    data =
      id: obj.id
      status: 'init'
      audio: new Howl
        urls: ["#{@path}/#{@src(obj.id)}.mp3"]
        autoplay: false
        loop: false
        volume: obj.volume or @volume
        onload: -> data.status = 'onload'
        onplay: -> 
          if _.isFunction(data.onplay) then data.onplay()
          data.onplay = undefined
        onend: ->
          if _.isFunction(data.onend) then data.onend()
          data.onend = undefined

  play: (id, onPlay, onEnd) ->
    if id
      audio = @audio(id)
      @data(id).onplay = onPlay
      @data(id).onend = onEnd
      audio.play()

  fadeIn: (id) ->
    if id
      @audio(id).fadeIn(@volume, @fadeTime)

  fadeOut: (id) ->
    if id
      @audio(id).fadeOut(0, @fadeTime)

  pause: (id) ->
    if id
      @audio(id).pause()
    else
      @audio(data.id).pause() for data in @soundData

  stop: (id) ->
    if id
      @audio(id).stop()
    else
      @audio(data.id).stop() for data in @soundData

  data: (id) ->
    for data in @soundData
      if data.id is id
        return data

  audio: (id) ->
    @data(id).audio

  src: (id) ->
    switch id
      when 'wind' then 'wind_medium_howling_with_wind_shutters_rattling'
      when 'open' then 'xylophone_open'
      when 'hogaraka' then 'cool_funny_bounce_music'
