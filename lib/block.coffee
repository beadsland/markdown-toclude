oCom = '<!--\\s'
cCom = '\\s-->'
ComTag = '(\\w+)'
oComTag = "#{ComTag}[\\w\\s\\:]*?"
pComTag = "#{ComTag}: ([\\w\\s\\:]*?) "
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
    re = RegExp(oCom + tag + cCom, 'g')
    while m = re.exec(text)
      {name: m[1], start: m.index, end: m.index + m[0].length, \
        comment: m[0], paramstr: m[2]}

  find_block_closers: (text) -> @find_tag_comments(text, cComTag)

  find_noncloser_comments: (text) -> @find_tag_comments(text, oComTag)

  find_tocludes_comments: (text) ->
    comments = @find_tag_comments(text, pComTag)
    tocludes = (item for item in comments when item.name is "TOCLUDE")
    tocludes = for t in tocludes
      t.params = []
      re = RegExp("(\\w+): (\\w+)", 'g')
      while m = re.exec(t.paramstr)
        t.params[m[1]] = m[2]
      t # next element in for list

  find_blocks_from_closers: (text, closers) ->
    dup = @duped(closers)
    if dup? then deny "Block close comment /#{dup.name} must be unique."

    blocks = for close in closers
      openers = @find_noncloser_comments(text.slice(close.end+1))
      openers = (item for item in openers when item.name is close.name)
      if (openers.length)
        deny "Block open comment #{close.name} must not trail \
              block close comment /#{close.name}."

      openers = @find_noncloser_comments(text.slice(0, close.start-1))
      openers = (item for item in openers when item.name is close.name)
      if (not openers.length)
        deny "Block close comment /#{close.name} must have a \
              matching block open comment."
      if (openers.length > 1)
        deny "Block open comment #{close.name} must be unique."

      close.cComment = close.comment
      close.oComment = openers[0].comment
      close.start = openers[0].start
      close.slice = text.slice(close.start, close.end)
      close # next element in for array

    for b in blocks
      for t in blocks
        unless b is t
          if (t.start > b.start and t.start < b.end) \
              or (t.end > b.start and t.end < b.end)
            deny "Block #{t.name} must not overlap with block #{b.name}."

    return blocks # find_blocks_from_closers

  find_nonblocks_from_blocks: (text, blocks) ->
    nonblocks = []
    unless (blocks.length)
      nonblocks = [{start: 0, end: text.length - 1}]
    else
      nonblocks = for i in [0 .. blocks.length - 1]
        if i is 0 then {start: 0, end: blocks[0].start - 1}
        else
          {start: blocks[i-1].end + 1, end: blocks[i].start - 1}
      nonblocks.push {start: blocks[blocks.length - 1].end, \
                       end: text.length}
    for n in nonblocks
      n.slice = text.slice(n.start, n.end)
      n # next element in for array
