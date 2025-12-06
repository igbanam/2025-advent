vim9script

import "../00/solution.vim"

class Cafeteria extends solution.AbstractSolution
  var ingredients: list<number>
  var fresh_list: list<tuple<number, number>>

  def new(inputfile: string, part: number)
    inputfile->this.ReadInput()
    this.ParseInput()
    this.parts = {
      1: (i) => this.PartOne(i),
      2: (i) => this.PartTwo(i)
    }
    this.currentPart = part
  enddef

  def ParseInput()
    var flag = false
    for line in this.input
      if line ==# ""
        flag = true
        continue
      endif

      if flag
        this.ingredients->add(line->str2nr())
      else
        this.fresh_list->add(line->split('-')->mapnew((_, v) => v->str2nr())->list2tuple())
      endif
    endfor
  enddef

  def FlattenRanges(): list<tuple<number, number>>
    var flattened: list<tuple<number, number>>
    echo this.fresh_list
    var ranges = this.fresh_list->copy()->sort((a, b) => a[0] - b[0])
    var cursor = ranges[0]->tuple2list()
    for r in ranges[1 : ]
      if r[0] <= cursor[1]
        cursor[1] = [cursor[1], r[1]]->max()
      else
        flattened->add(cursor->list2tuple())
        cursor = r->tuple2list()
      endif
    endfor
    flattened->add(cursor->list2tuple())
    return flattened
  enddef

  def PartOne(in: any)
    var count = 0
    for ingredient in this.ingredients
      for fresh_range in this.fresh_list
        # ...because I'm a brute crood
        if ingredient >= fresh_range[0] && ingredient <= fresh_range[1]
          count += 1
          break
        endif
      endfor
    endfor
    echo count
  enddef

  def PartTwo(in: any)
    var total = 0
    var flattenedRanges = this.FlattenRanges()
    echo flattenedRanges
    for r in flattenedRanges
      total += (r[1] - r[0] + 1)
    endfor
    echo total
  enddef
endclass

Cafeteria.new("input", 2).Solve()
