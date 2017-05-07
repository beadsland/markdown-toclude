oCom = '<!--\\s'
cCom = '\\s-->'
ComTag = '(\\w+)'
oComTag = "#{ComTag}[\\w\\s\\:]*?"
cComTag = "/#{ComTag}"

note = atom.notifications

module.exports =
  find_tag_comments: (text, tag) ->
    pattern = oCom + tag + cCom
    if (RegExp(pattern).test(text))
      re = RegExp(pattern, 'g')
      while m = re.exec(text)
        {name: m[1], start: m.index, end: m.index + m[0].length - 1}
    else return null

  find_block_closers: (text) -> @find_tag_comments(text, cComTag)

  find_block_openers: (text) -> @find_tag_comments(text, oComTag)
