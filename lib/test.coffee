module.exports =
  hello: "world",
  goodbye: "everyone",
  testfunc: () ->
    editor = atom.workspace.getActiveTextEditor()
    if (editor)
      text = editor.getBuffer().getText()

      # <!-- TOCLUDE: name:X cmd:Y --> */

      # eslint no-unused-vars: "warn" */
      oCom = '<!--\\s'
      cCom = '\\s-->'
      ComTag = '(\\w+)'
      oComTag = "#{ComTag}[\\w\\s\\:]*?"
      cComTag = "#{ComTag}"
      pattern = oCom + cComTag + cCom

      log = atom.notifications

      if (RegExp(pattern).test(text))
        re = RegExp(pattern, 'g')
        while (m = re.exec(text))
          log.addInfo("found: #{m[1]}")
          log.addInfo("start: #{m.index}")
          log.addInfo("end: #{m.index} + #{m[0].length} -1")
      else
        log.addWarning('no array')
