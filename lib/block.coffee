oCom = '<!--\\s'
cCom = '\\s-->'
ComTag = '(\\w+)'
oComTag = "#{ComTag}[\\w\\s\\:]*?"
cComTag = "/#{ComTag}"

note = atom.notifications

module.exports =
  find_block_closers: (text) ->
    pattern = oCom + cComTag + cCom

    if (RegExp(pattern).test(text))
      re = RegExp(pattern, 'g')
      while (m = re.exec(text); m?)
        {name: m[1], start: m.index, end: m.index + m[0].length - 1}
    else return null
