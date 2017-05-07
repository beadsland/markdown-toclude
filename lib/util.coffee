module.exports =
  duped: (arr) ->
    if arr? then saw = []; for b in arr
      if saw[b.name] is true then return b else saw[b.name] = true
    return null
