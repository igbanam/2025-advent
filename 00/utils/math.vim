vim9script

class Math
  static def Abs(x: number): number
    if x > 0
      return x
    endif
    return x * -1
  enddef
endclass

export def Abs(x: number): number
  return Math.Abs(x)
enddef

defcompile
