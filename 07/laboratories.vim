vim9script

import "../00/solution.vim"
import "../00/utils/enumerable.vim"

class Laboratories extends solution.AbstractSolution
  var updater: dict<func>

  def new(inputfile: string, part: number)
    inputfile->this.ReadInput()
    this.ParseInput()
    this.currentPart = part
    this.parts = {
      1: (i) => this.PartOne(i),
      2: (i) => this.PartTwo(i),
    }
  enddef

  def ParseInput()
    this.input = this.input->mapnew((_, v) => v->split('\zs'))
  enddef

  def PartOne(manifold: any)
    var start = manifold[0]->indexof((_, v) => v == 'S')
    var beams: dict<number>
    beams[start] = 1
    var splits: number = 0
    var timelines: number
    manifold->foreach((ridx, row) => {
      if row->index('S') != -1
        return
      endif
      var splitBeams: dict<number>
      beams->foreach((bidx, num_beams) => {
        var cidx = bidx->str2nr()
        if cidx < 0 || cidx >= manifold[0]->len()
          return
        endif

        var cell = row[cidx]
        if cell ==# '^'
          splits += 1
          if cidx - 1 >= 0
            splitBeams[cidx - 1] = 1
          endif
          if cidx + 1 < manifold[0]->len()
            splitBeams[cidx + 1] = 1
          endif
        else
          splitBeams[cidx] = 1
        endif
      })

      timelines += splitBeams->keys()->len()

      beams = splitBeams
    })

    echo splits
  enddef

  def PartTwo(manifold: any)
    var start = manifold[0]->indexof((_, v) => v == 'S')
    var beams: dict<number>
    beams[start] = 1
    manifold->foreach((ridx, row) => {
      if row->index('S') != -1
        return
      endif
      var splitBeams: dict<number>
      beams->foreach((bidx, num_beams) => {
        var cidx = bidx->str2nr()
        if cidx < 0 || cidx >= manifold[0]->len()
          return
        endif

        var cell = row[cidx]
        if cell ==# '^'
          var l = cidx - 1
          var r = cidx + 1
          if l >= 0
            splitBeams[l] = splitBeams->get(l, 0) + num_beams
          endif
          if r < manifold[0]->len()
            splitBeams[r] = splitBeams->get(r, 0) + num_beams
          endif
        else
          splitBeams[cidx] = splitBeams->get(cidx, 0) + num_beams
        endif
      })
      beams = splitBeams
    })

    echo beams->values()->enumerable.Sum()
  enddef
endclass

Laboratories.new('input', 2).Solve()
