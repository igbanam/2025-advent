vim9script

import "../00/solution.vim"
import "../00/utils/enumerable.vim"
import "../00/utils.vim"

class TrashCompactor extends solution.AbstractSolution
  var rawFile: list<string>

  def new(inputfile: string, part: number)
    this.currentPart = part
    inputfile->this.ReadInput()
    this.ParseInput()
    this.parts = {
      1: (i) => this.PartOne(i),
      2: (i) => this.PartTwo(i),
    }
  enddef

  def ParseInput()
    this.rawFile = this.input
    this.input = this.input
      ->mapnew((_, v) => v->split(''))
      ->enumerable.Transpose2D()
  enddef

  def PartOne(problems: list<list<any>>)
    var result = problems->mapnew((_, v) => {
      var combinator = v->remove(-1)
      if combinator == '+'
        return v->mapnew((_, w) => w->str2nr())->enumerable.Sum()
      elseif combinator == '*'
        return v->mapnew((_, w) => w->str2nr())->reduce((a, b) => a * b, 1)
      endif
      return 0
    })
    echo result->enumerable.Sum()
  enddef

  def PartTwo(problems: list<list<any>>)
    var combinators = this.rawFile[-1]->split('')
    var problemIdx = 0
    var runningTotal = 0
    var total = 0
    var prepped = this.rawFile
      ->slice(0, -1)
      ->mapnew((_, v) => v->split('\zs'))
      ->enumerable.Transpose2D()
    prepped->foreach((i, v) => {
      if v->enumerable.All((w) => w ==# ' ')
        problemIdx += 1
        total += runningTotal
        runningTotal = 0
      else
        if combinators[problemIdx] == '+'
          runningTotal += v->join('')->str2nr()
        elseif combinators[problemIdx] == '*'
          if runningTotal == 0
            runningTotal = 1
          endif

          runningTotal = runningTotal * v->join('')->str2nr()
        endif
      endif
    })
    echo total + runningTotal
  enddef
endclass

TrashCompactor.new("input", 2).Solve()
