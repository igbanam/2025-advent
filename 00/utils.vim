vim9script

def PathFormat(fname: string): string
  return $'{expand("%:h")}/{fname}.in'
enddef

export def LoadInput(inputName: string): list<string>
  return inputName->PathFormat()->readfile()
enddef

export def Visualize(grid: list<list<any>>, logfile: string = '')
  var topBar = '-'->repeat(grid[0]->len())
  if logfile->empty()
    echo topBar
  else
    writefile([topBar], logfile, "a")
  endif
  for line in grid
    var content = line->join('')
    if logfile->empty()
      echo content
    else
      writefile([content], logfile, "a")
    endif
  endfor
enddef

export def Blank2DGrid(ref: list<list<any>>, filler: any): list<list<any>>
    return ref
      ->len()
      ->range()
      ->mapnew((_, _) => [filler]->repeat(ref[0]->len()))
enddef

export const directions = [
  [0, 1],
  [0, -1],
  [1, 0],
  [-1, 0]
]

export const compass = {
  'r': [0, 1],
  'l': [0, -1],
  'd': [1, 0],
  'u': [-1, 0]
}

export class AbstractPoint
  public var x: number
  public var y: number
endclass

export def WithinMap(p: AbstractPoint, arr: list<list<any>>): bool
  return p.x >= 0 &&
    p.y >= 0 &&
    p.x < arr->len() &&
    p.y < arr[0]->len()
enddef

export def CoordsWithinMap(p: list<number>, arr: list<list<any>>): bool
  return AbstractPoint.new(p[0], p[1])->WithinMap(arr)
enddef

export def BFS(
    x: number,
    y: number,
    dim: list<number> = [0, 0],
    StepClause: func(number, number): bool = (_: number, _: number) => true,
    EndClause: func(number, number): bool = (_: number, _: number) => true): list<list<number>>
  var queue: list<list<any>> = [[x, y, [[x, y]]]] # Queue of [x, y, path]
  var visited: list<list<bool>> = dim[0]
    ->range()
    ->map((_, _) => [false]->repeat(dim[1]))

  while !queue->empty()
    var current = queue->remove(0)
    var cx = current[0]
    var cy = current[1]
    var path = current[2]

    if visited[cx][cy]
      continue
    endif
    visited[cx][cy] = true

    if EndClause(cx, cy)
      return path
    endif

    for direction in directions
      var dx = cx + direction[0]
      var dy = cy + direction[1]

      if StepClause(dx, dy)
        var new_path = path->copy()
        new_path->add([dx, dy])
        queue->add([dx, dy, new_path])
      endif
    endfor
  endwhile
  return [] # No path found
enddef

def GetNeighbors(grid: list<list<any>>, node: list<number>, wall: any): list<list<number>>
  var neighbors = []
  var dirs = [[0, 1], [1, 0], [0, -1], [-1, 0]]
  for dir in dirs
    var newX = node[0] + dir[0]
    var newY = node[1] + dir[1]
    if newX >= 0 && newX < len(grid) && newY >= 0 && newY < grid[0]->len()
      if grid[newX][newY] != wall  # Not a wall
        neighbors->add([newX, newY])
      endif
    endif
  endfor
  return neighbors
enddef

def Manhattan(a: list<number>, b: list<number>): number
  return (a[0] - b[0]) + abs(a[1] - b[1])->abs()
enddef

export def AStar(grid: list<list<any>>, start: list<number>, goal: list<number>, wall: any): list<list<number>>
  var openSet = [[start, 0]]
  var cameFrom = {}
  var gScore = {}
  var fScore = {}

  gScore[start->string()] = 0
  fScore[start->string()] = Manhattan(start, goal)

  while !openSet->empty()
    openSet->sort((a, b) => a[1] - b[1])
    var current = openSet[0][0]
    if current == goal
      var path = [current]
      var currentKey = current->string()
      while cameFrom->has_key(currentKey)
        current = cameFrom[currentKey]
        currentKey = current->string()
        path->insert(current, 0)
      endwhile
      return path
    endif

    openSet->remove(0)
    var currentKey = current->string()

    for neighbor in grid->GetNeighbors(current, wall)
      var neighborKey = neighbor->string()
      var tentativeGScore = gScore[currentKey] + 1

      if !gScore->has_key(neighborKey) || tentativeGScore < gScore[neighborKey]
        cameFrom[neighborKey] = current
        gScore[neighborKey] = tentativeGScore
        fScore[neighborKey] = tentativeGScore + Manhattan(neighbor, goal)
        var found = false
        for node in openSet
          if node[0] == neighbor
            found = true
            break
          endif
        endfor
        if !found
          openSet->add([neighbor, fScore[neighborKey]])
        endif
      endif
    endfor
  endwhile

  return []  # No path found
enddef

def BuildPath(current: list<number>, cameFrom: dict<list<list<number>>>): list<list<list<number>>>
    if cameFrom[current->string()]->empty()
        return [[current]]
    endif

    var paths = []
    for prev in cameFrom[current->string()]
        for subpath in BuildPath(prev, cameFrom)
            subpath->add(current)
            paths->add(subpath)
        endfor
    endfor
    return paths
enddef

export def FindAllPaths(grid: list<list<any>>, start: list<number>, goal: list<number>, wall: string): list<list<list<number>>>
    var paths = []
    var stack = [[start]]
    var visited_paths = {}

    while !stack->empty()
        var current_path = stack[-1]->deepcopy()
        stack->remove(-1)
        var current = current_path[-1]

        if current == goal
            paths->add(current_path)
            continue
        endif

        var path_visited = {}
        for point in current_path
            path_visited[point->string()] = true
        endfor

        for neighbor in grid->GetNeighbors(current, wall)
            var neighborKey = neighbor->string()
            # Only avoid revisiting points in current path
            if !path_visited->has_key(neighborKey)
                var new_path = current_path->deepcopy()
                new_path->add(neighbor)
                var path_key = new_path->string()
                if !visited_paths->has_key(path_key)
                    visited_paths[path_key] = true
                    stack->add(new_path)
                endif
            endif
        endfor
    endwhile

    return paths
enddef

const UP = 0
const RIGHT = 1
const DOWN = 2
const LEFT = 3

def GetRotationCost(current_dir: number, next_dir: number): number
    if current_dir == next_dir
        return 0
    endif
    # Calculate minimum rotations needed (clockwise or counterclockwise)
    var diff = (current_dir - next_dir)->abs()
    return [diff, 4 - diff]->min() * 1000
enddef

def GetDirection(from: list<number>, to: list<number>): number
    if from[0] < to[0]
        return DOWN
    elseif from[0] > to[0]
        return UP
    elseif from[1] < to[1]
        return RIGHT
    else
        return LEFT
    endif
enddef

export def FindCheapestPath(grid: list<list<string>>, start: list<number>, goal: list<number>, wall: string): dict<any>
    var pq = []  # Priority queue: [cost, pos, direction, path]
    var visited = {}

    # Initialize with all 4 directions
    for dir in 4->range()
        pq->add([0, start, dir, [start]])
    endfor

    while !pq->empty()
        # Sort by cost (maintain priority queue)
        pq->sort((a, b) => a[0] - b[0])
        var [current_cost, current_pos, current_dir, current_path] = pq[0]
        pq->remove(0)

        if current_pos == goal
            return {'cost': current_cost, 'path': current_path, 'final_dir': current_dir}
        endif

        var state_key = [current_pos, current_dir]->string()
        if visited->has_key(state_key)
            continue
        endif
        visited[state_key] = true

        for neighbor in grid->GetNeighbors(current_pos, wall)
            var next_dir = current_pos->GetDirection(neighbor)
            var rotation_cost = current_dir->GetRotationCost(next_dir)
            var step_cost = 1  # Basic movement cost
            var new_cost = current_cost + rotation_cost + step_cost

            var next_path = current_path->deepcopy()
            next_path->add(neighbor)

            pq->add([new_cost, neighbor, next_dir, next_path])
        endfor
    endwhile

    return {'cost': -1, 'path': [], 'final_dir': -1}  # No path found
enddef

defcompile
