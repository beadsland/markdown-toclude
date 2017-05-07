module.exports =
  duped: (arr) ->
    if arr?
      saw = []
      for b in arr
        if saw[b.name] then return b else saw[b.name] = true
    return null
