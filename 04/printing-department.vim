vim9script

import "../00/solution.vim"

class PrintingDepartment extends solution.AbstractSolution
  var rows: number
  var cols: number
  var removesAccessed: dict<bool>

  def new(inputfile: string, part: number)
    inputfile->this.ReadInput()
    this.ParseInput()
    this.parts = {
      1: (i) => this.PartOne(i),
      2: (i) => this.PartTwo(i),
    }
    this.currentPart = part
    this.removesAccessed = {
      1: false,
      2: true,
    }
  enddef

  def ParseInput()
    this.input = this.input->mapnew((_, v) => v->split('\zs'))

    # initialize problem
    this.rows = this.input->len()
    this.cols = this.input[0]->len()
  enddef

  def Accessible(grid: list<list<string>>): number
    var accessible = 0
    var accessedLocations: list<tuple<number, number>>

    for row in 0->range(this.rows - 1)
      for col in 0->range(this.cols - 1)
        if grid[row][col] !=# '@'
          continue
        endif

        var neighbours = 0
        for dr in range(-1, 1)
          for dc in range(-1, 1)
            if dr == 0 && dc == 0
              # @ the point
              continue
            endif
            var newRow = row + dr
            var newCol = col + dc
            if newRow < 0 || newRow >= this.rows || newCol < 0 || newCol >= this.cols
              # @ boundary
              continue
            endif
            if grid[newRow][newCol] ==# '@'
              neighbours += 1
            endif
          endfor
        endfor

        if neighbours < 4
          accessible += 1
          accessedLocations->add((row, col))
        endif
      endfor
    endfor

    if this.removesAccessed[this.currentPart]
      accessedLocations->foreach((_, point) => {
        grid[point[0]][point[1]] = '.'
      })
    endif
    return accessible
  enddef

  def PartOne(grid: list<list<string>>)
    echo this.Accessible(grid)
  enddef

  def PartTwo(grid: list<list<string>>)
    var totalAccessible = 0
    var currentAccessible = this.Accessible(grid)
    while currentAccessible != 0
      totalAccessible += currentAccessible
      currentAccessible = this.Accessible(grid)
    endwhile
    echo totalAccessible
  enddef
endclass

PrintingDepartment.new("input", 2).Solve()
