module.exports =
  deny: (err) -> throw {guard: true, message: err}
