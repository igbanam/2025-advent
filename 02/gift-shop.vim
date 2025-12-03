vim9script

import "../00/solution.vim"

class GiftShop extends solution.AbstractSolution
  var validations: dict<func>
  def new(inputfile: string, part: number)
    this.parts = {
      1: (i) => this.Solution(i),
      2: (i) => this.Solution(i),
    }
    this.currentPart = part

    this.validations = {
      1: (i) => this.Mirrors(i),
      2: (i) => this.Repeats(i),
    }

    inputfile->this.ReadInput()
    this.ParseInput()
  enddef

  def ParseInput()
    this.input = this.input[0]
      ->split(',')
      ->deepcopy()
      ->map((_, v) => {
        return v->split('-')
                ->mapnew((_, q) => q->str2nr())
      })
  enddef

  def Mirrors(id: number): bool
    var sid = string(id)
    var len = strlen(sid)

    if (len % 2) == 1
      return false
    endif

    var mid = len / 2
    return sid[ : mid - 1] ==# sid[mid : ]
  enddef

  def Repeats(id: number): bool
    var sid = string(id)
    var len = strlen(sid)

    if len < 2
      return false
    endif

    for k in range(2, len)
      if (len % k) != 0
        continue
      endif

      var sublen = len / k
      var sub = sid[ : sublen - 1 ]

      var built = ''
      for _ in range(1, k)
        built ..= sub
      endfor

      if built ==# sid
        return true
      endif
    endfor

    return false
  enddef

  def Solution(ranges: list<list<number>>): number
    var sum = 0
    for range in ranges
      var first = range[0]
      var last = range[1]
      for id in range(first, last)
        if this.validations[this.currentPart](id)
          sum += id
        endif
      endfor
    endfor
    return sum
  enddef
endclass

echo GiftShop.new("input", 2).Solve()
