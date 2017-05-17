oCom = '<!--\\s'
cCom = '\\s-->'
ComTag = '(\\w+)'
oComTag = "#{ComTag}[\\s\\S]*?"  # distinction between p & o meaningless
pComTag = "#{ComTag}: ?([\\s\\S]*?)"
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
      {name: m[1].toUpperCase(), \
       start: m.index, end: m.index + m[0].length - 1, \
       comment: m[0], paramstr: m[2], length: m[0].length}

  find_block_closers: (text) -> @find_tag_comments(text, cComTag)

  find_noncloser_comments: (text) -> @find_tag_comments(text, oComTag)

  find_parameter_comments: (text) -> @find_tag_comments(text, pComTag)

  find_tocludes_comments: (text) ->
    comments = @find_parameter_comments(text)
    tocludes = (item for item in comments \
                              when item.name.toUpperCase() is "TOCLUDE")
    for t in tocludes
      t.params = []
      re = RegExp("(\\w+): ?(\\S+)", 'g')
      while m = re.exec(t.paramstr)
        t.params[m[1].toLowerCase()] = m[2]
      t # next element in for list

  find_blocks_from_closers: (text, closers) ->
    dup = @duped(closers)
    if dup? then deny "Block close comment /#{dup.name} must be unique."

    blocks = for close in closers
      openers = @find_noncloser_comments(text.slice(close.end))
      openers = (item for item in openers when item.name is close.name)
      if (openers.length)
        deny "Block open comment #{close.name} must not trail \
              block close comment /#{close.name}."

      openers = @find_noncloser_comments(text.slice(0, close.start))
      openers = (item for item in openers when item.name is close.name)
      if (not openers.length)
        deny "Block close comment /#{close.name} must have a \
              matching block open comment."
      if (openers.length > 1)
        deny "Block open comment #{close.name} must be unique."

      close.cComment = close.comment
      close.oComment = openers[0].comment

      # need to give start even if no content -- hmm

      if openers[0].end + 1 is close.start
        close.content = {insert: close.start}
      else
        close.content = {start: openers[0].end + 1, end: close.start - 1}
        close.content.slice = text.slice(close.content.start, \
                                         close.content.end)
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

  start_sorter: (a, b) ->
    if a.start > b.start then       return 1
    else if a.start < b.start then  return -1
    else                            return 0

  find_nonblocks_from_blocks_and_nonclosers: (text, blocks, nonclosers) ->
    for n in nonclosers
      dup = false
      for b in blocks
        if n.start is b.start then dup = true
      if dup is false then blocks.push n
    blocks = blocks.sort(@start_sorter)

    nonblocks = []
    unless (blocks.length)
      nonblocks = [{start: 0, end: text.length - 1}]
    else
      nonblocks = for i in [0 .. blocks.length - 1]
        if i is 0 then {start: 0, end: blocks[0].start - 1}
        else
          {start: blocks[i-1].end + 1, end: blocks[i].start - 1}
      nonblocks.push {start: blocks[blocks.length - 1].end + 1, \
                       end: text.length}
    for i in [nonblocks.length - 1..0] by -1
      if nonblocks[i].end <= nonblocks[i].start
        nonblocks.splice(i, 1)
    for n in nonblocks
      n.slice = text.slice(n.start, n.end)
    return nonblocks

  find_first_bullet_from_nonblocks: (text, nonblocks) ->
    firsts = for n in nonblocks

      # back up to --> if only carriage returns
      # otherwise, drop in front of first bullet

      re = RegExp("^[-+*]\\s.*$", 'm')
      if m = re.exec(n.slice)
        {line: m[0], start: n.start + m.index}
    firsts = (item for item in firsts when item isnt undefined)
    if firsts.length then return firsts[0]

  insert_block_unless_found: (editor, name) ->
    text = editor.getText()
    closers = @find_block_closers(text)
    blocks = @find_blocks_from_closers(text, closers)
    seek = (item for item in blocks when item.name is name)[0]
    if not seek
      nonclosers = @find_noncloser_comments(text)
      seek = (item for item in nonclosers when item.name is name)[0]
      if seek
        note.addWarning("Block closing comment /#{name} was missing. \
                         Has been added.")
        Util.insert_to_buffer(editor, seek.end + 1, "<!-- /#{name} -->")
      else
        newstr = "<!-- #{name} --><!-- /#{name} -->"
        nonclosers = @find_noncloser_comments(text)
        nonblocks = @find_nonblocks_from_blocks_and_nonclosers(text, \
                                                               blocks, \
                                                               nonclosers)
        first = @find_first_bullet_from_nonblocks(text, nonblocks)
        if first
          Util.insert_to_buffer(editor, first.start, "#{newstr}\n\n")
          re = RegExp("-->\n+#{newstr}")  # tighten if before a comment
          editor.getBuffer().replace(re, "-->#{newstr}")
        else
          [..., last] = nonblocks
          Util.insert_to_buffer(editor, last.start, newstr)
