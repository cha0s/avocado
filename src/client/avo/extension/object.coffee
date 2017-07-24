
module.exports = class ObjectExt

  @deepCopy: (O) -> JSON.parse JSON.stringify O
