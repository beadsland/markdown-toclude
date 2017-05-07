oCom = '<!--\\s'
cCom = '\\s-->'
ComTag = '(\\w+)'
oComTag = "#{ComTag}[\\w\\s\\:]*?"
cComTag = "#{ComTag}"

note = atom.notifications

module.exports =
  hello: "world",
  goodbye: "everyone",
  testfunc: (text) ->
    pattern = oCom + cComTag + cCom

    if (RegExp(pattern).test(text))
      re = RegExp(pattern, 'g')
      while (m = re.exec(text))
        note.addInfo("found: #{m[1]}")
        note.addInfo("start: #{m.index}")
        note.addInfo("end: #{m.index} + #{m[0].length} -1")
    else
      note.addWarning('no array')
