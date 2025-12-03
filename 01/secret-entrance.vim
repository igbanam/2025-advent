vim9script

import "../00/solution.vim"

class SecretEntrance extends solution.AbstractSolution
  var dialStart = 50

  def new(inputfile: string, part: number)
    this.parts = {
      1: (p) => this.Part1(p),
      2: (p) => this.Part2(p)
    }
    this.currentPart = part

    inputfile->this.ReadInput()
    this.ParseInput()
  enddef

  def ParseInput()
  enddef

  def Part1(rotations: list<string>): number
    var dial = this.dialStart
    var zeroes = 0

    for turn in rotations
      var direction = turn[0]
      var steps = str2nr(turn[1 : ])
      if direction ==# 'R'
        dial = (dial + steps) % 100
      else
        dial = (dial - steps) % 100
        if dial < 0
          dial += 100
        endif
      endif

      if dial == 0
        zeroes += 1
      endif
    endfor

    return zeroes
  enddef

  def Part2(rotations: list<string>): number
    var dial = this.dialStart
    var total = 0

    for turn in rotations
      if turn ==# ''
        continue
      endif

      var direction = turn[0]
      var steps = str2nr(turn[1 : ])

      var distance = 0
      if direction ==# 'R'
        distance = (100 - (dial % 100)) % 100
      else
        distance = dial % 100
      endif

      if distance == 0
        distance = 100
      endif

      if distance <= steps
        total += 1 + ((steps - distance) / 100)->float2nr()
      endif

      if direction ==# 'R'
        dial = (dial + steps) % 100
      else
        dial = (dial - steps) % 100
        if dial < 0
          dial += 100
        endif
      endif
    endfor

    return total
  enddef

endclass

echo SecretEntrance.new("input", 2).Solve()
