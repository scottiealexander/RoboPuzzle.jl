@enum Direction Left=1 Right=-1
@enum Bearing East=0 North=1 West=2 South=3

const Rectangle = matplotlib[:patches][:Rectangle]
const Coin = matplotlib[:patches][:CirclePolygon]

const PatchDict = Dict{Tuple{Int,Int},PyCall.PyObject}

const COLORS = Dict{NTuple{3,Float64}, String}(
    (1.0, 0.0, 0.0) => "red",
    (0.0, 1.0, 0.0) => "green",
    (0.0, 0.0, 1.0) => "blue",
    (0.5, 0.5, 0.5) => "gray"
)

const SPEED = 2.0
