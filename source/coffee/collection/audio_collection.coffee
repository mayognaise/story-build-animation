class AudioCollection
  constructor: ->
    @volume = 1
    @sounds = [
      @data('wind')
      @data('chan-chan')
      @data('hogaraka')
      # @data('horror')
    ]
    $.ionSound
      sounds: @sounds
      path: 'audio/'
      multiPlay: true
      volume: @volume

  data: (id) ->
    switch id
      when 'wind' then 'wind_medium_howling_with_wind_shutters_rattling'
      when 'chan-chan' then 'xylophone_open'
      when 'hogaraka' then 'cool_funny_bounce_music'
      when 'horror' then 'horror_music'

  play: (id, volume = @volume) ->
    @stop()
    if id
      $.ionSound.play("#{@data(id)}:#{volume}")

  stop: (id) ->
    if id
      $.ionSound.stop(@data(id))
    else
      $.ionSound.stop(id) for id in @sounds

  kill: (id) ->
    if id
      $.ionSound.kill(@data(id))

  destroy: ->
    $.ionSound.destroy()
