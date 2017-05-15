module.exports =
  deny: (err) -> throw {guard: true, message: err}

#  insert_after: (text, where, newstr) ->
#    pre = text.slice(0, where)
#    post = text.slice(where)
#    "#{pre}#{newstr}#{post}"

  insert_to_buffer: (editor, where, newstr) ->
    buffer = editor.getBuffer()
    position = buffer.positionForCharacterIndex(where)
    buffer.insert(position, newstr)

  replace_in_buffer: (editor, start, end, str) ->
    buffer = editor.getBuffer()
    range = [buffer.positionForCharacterIndex(start), \
             buffer.positionForCharacterIndex(end)]
    editor.setTextInBufferRange(range, str)
