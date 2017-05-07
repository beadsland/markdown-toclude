oCom = '<!--\\s'
cCom = '\\s-->'
ComTag = '(\\w+)'
oComTag = "#{ComTag}[\\w\\s\\:]*?"
cComTag = "/#{ComTag}"

note = atom.notifications
Util = require './util'
deny = Util.deny

module.exports =
  duped: (arr) ->
    unless arr? then return null
    saw = []
    for b in arr
      if saw[b.name] then return b else saw[b.name] = true

  find_tag_comments: (text, tag) ->
    pattern = oCom + tag + cCom
    if (RegExp(pattern).test(text))
      re = RegExp(pattern, 'g')
      while m = re.exec(text)
        {name: m[1], start: m.index, end: m.index + m[0].length - 1}
    else return []

  find_block_closers: (text) -> @find_tag_comments(text, cComTag)

  find_block_openers: (text) -> @find_tag_comments(text, oComTag)

  find_blocks_from_closers: (text, closers) ->
    dup = @duped(closers)
    if dup? then deny "Block close comment /#{dup.name} must be unique."
    note.addInfo("no dups found")

    blocks = for close in closers
      openers = @find_block_openers(text.slice(close.end+1))
      openers = (item for item in openers when item.name is close.name)
      if (openers.length)
        deny "Block open comment #{close.name} must not trail \
              block close comment /#{close.name}."

      openers = @find_block_openers(text.slice(0, close.start-1))
      openers = (item for item in openers when item.name is close.name)
      if (not openers.length)
        deny "Block close comment /#{close.name} must have a \
              matching block open comment."
      if (openers.length > 1)
        deny "Block open comment #{close.name} must be unique."

      close # next element in for array

    for b in blocks
      close.start = openers[0].start
      for t in blocks
        unless b is t
          if (t.start > b.start and t.start < b.end) \
              or (t.end > b.start and t.end < b.end)
            deny "Block #{t.name} must not overlap with block #{b.name}."

    return blocks # find_blocks_from_closers
