Block = require './block'

note = atom.notifications

module.exports =
  find_trash_comment: (text) ->
    comments = Block.find_garbage_comments(text)
    trash = (can for can in comments when can.name is "TRASH")
    if trash.length
      trash[0].content = trash[0].paramstr
      return trash[0]
    else return null

  clear_trash_comment: (text) ->
    trash = @find_trash_comment(text)
    if trash? then text = text.slice(0, trash.start - 1) \
                          + text.slice(trash.end)
    text

  append_trash_comment: (text, content) ->
    content.replace(RegExp("-->", 'g'), "- - >")
    top25 = content.split("\n").slice(0, 25).join("\n")
    text = text + "\n<!-- TRASH:\n#{top25}\n -->"

  get_trash: (text) ->
    trash = @find_trash_comment(text)
    unless trash
      text = @append_trash_comment(text, "")
      trash = @find_trash_comment(text)
    trash.content

  compact_trash: (trash, topper) ->
    seen = {}
    if topper then for t in topper.split("\n")
      seen[t] = true

    results = []
    for l in trash.split("\n")
      if not seen[l] then results.push(l)
      seen[l] = true
    results.join("\n")

  put_trash: (text, trash) ->
    text = @clear_trash_comment(text)
    @append_trash_comment(text, @compact_trash(trash))
