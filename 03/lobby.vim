vim9script

import "../00/solution.vim"

class Digit
  var value: string
  var position: number
endclass

class Lobby extends solution.AbstractSolution
  var window: dict<number>

  def new(inputfile: string, part: number)
    this.parts = {
      1: (i) => this.Solution(i),
      2: (i) => this.Solution(i),
    }
    this.currentPart = part
    this.window = {
      1: 2,
      2: 12
    }
    inputfile->this.ReadInput()
    this.ParseInput()
  enddef

  def ParseInput()
    # do nothing
  enddef

  def SubsequenceBuilder(s: string, iterations: number): string
    var len = strlen(s)
    if len < iterations
      return ''
    endif

    var start = 0
    var result = ''

    for pick in range(1, iterations)
      var last = len - (iterations - pick) - 1
      if last < start
        break
      endif

      var best_pos = start
      var best_d = s[best_pos]->str2nr()

      if start + 1 <= last
        for i in range(start + 1, last)
          var d = s[i]->str2nr()
          if d > best_d
            best_d = d
            best_pos = i
            if best_d == 9
              break
            endif
          endif
        endfor
      endif

      result ..= s[best_pos]
      start = best_pos + 1
    endfor

    return result
  enddef

  def Solution(banks: any)
    var sum = 0
    for line in banks
      var best = line
        ->this.SubsequenceBuilder(this.window[this.currentPart])
        ->str2nr()
      sum += best
    endfor

    echo sum
  enddef
endclass

Lobby.new("input", 2).Solve()
