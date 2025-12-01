vim9script

export def Sum(input: list<number>): number
  return input->reduce((a, v) => a + v, 0)
enddef

# ...because this is the poor man's Generics
def MapPred(input: list<any>, Pred: func(any): bool): list<bool>
  return input
    ->mapnew((_, icate) => Pred(icate))
    ->filter((_, j) => j)
enddef

export def All(input: list<any>, Pred: func(any): bool): bool
  return MapPred(input, Pred)
    ->len() == input->len()
enddef

export def Any(input: list<any>, Pred: func(any): bool): bool
  return MapPred(input, Pred)
    ->len() > 0
enddef

export def Contains(haystack: list<any>, needle: any): bool
  return haystack->index(needle) != -1
enddef

export def Transpose2D(matrix: list<list<any>>): list<list<any>>
  var result: list<list<any>>
  result = matrix[0]
    ->len()
    ->range()
    ->map((_, _) => []->repeat(matrix->len()))
  for i in matrix->len()->range()
    for j in matrix[0]->len()->range()
      result[j][i] = matrix[i][j]
    endfor
  endfor
  return result
enddef

export def Product(lols: list<list<any>>): list<list<any>>
  if lols->empty()
    return []
  endif
  var result = [[]]
  for lol in lols
    var tmp = []
    for x in result
      for y in lol
        tmp->add(x + [y])
      endfor
    endfor
    result = tmp
  endfor
  return result
enddef

defcompile
