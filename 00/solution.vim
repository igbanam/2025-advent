vim9script

import "./utils.vim"

export interface ISolution
  var input: any
  var parts: dict<func>
  def ReadInput(filename: string)
  def ParseInput()
  def Solve(part: number): any
endinterface

export abstract class AbstractSolution implements ISolution
  var input: any
  var parts: dict<func>

  def ReadInput(filename: string)
    this.input = utils.LoadInput(filename)
  enddef

  def ParseInput()
    throw "Unimplemented"
  enddef

  def Solve(part: number): any
    return this.input->this.parts[part]()
  enddef
endclass

export abstract class MazeSolution extends AbstractSolution
  var grid: list<list<string>>

  var startPoint: list<number>
  var startChar: string
  var endPoint: list<number>
  var endChar: string

  def ParseInput()
    this.grid = this.input->filter((_, line) => line != '')
  enddef

  def MoveDir(dir: number): list<number>
    var dirs = [[0, -1], [1, 0], [0, 1], [-1, 0]]
    return dirs[dir]
  enddef

  def InBounds(pos: list<number>): bool
    return pos[0] >= 0 &&
      pos[0] < this.grid[0]->len() &&
      pos[1] >= 0 &&
      pos[1] < this.grid->len()
  enddef

  def _FindSpot(id: string): list<number>
    var y = 0
    while y < this.input->len()
      var x = this.input[y]->stridx(id)
      if x >= 0
        return [x, y]
      endif
      y += 1
    endwhile
    return [0, 0]
  enddef

  def FindStart(): list<number>
    return this._FindSpot(this.startChar)
  enddef

  def FindEnd(): list<number>
    return this._FindSpot(this.endChar)
  enddef
endclass

defcompile
