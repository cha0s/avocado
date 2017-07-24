
exports.insertionSort = (array, cmp) ->
  return if array.length < 2

  if not cmp?
    cmp = (l, r) -> l > r

  for i in [0...array.length]
    x = array[i]

    j = i - 1
    while (j > -1) and cmp array[j], x
      array[j + 1] = array[j]
      j -= 1

    array[j + 1] = x

  return

exports.randomElement = (array) ->
  array[Math.floor Math.random() * array.length]

exports.fastPushArray = (l, r) ->
  l.push e for e in r
  return
