module RoboPuzzle

using PyCall

PyDict(pyimport("matplotlib")["rcParams"])["toolbar"] = "None"

using PyPlot
import Acorn

# export forward, left, right, get_color, red, green, blue, gray
# export refresh, game_over, load_level

include("./rbzl_constants.jl")
include("./rbzl_player.jl")
include("./rbzl_board.jl")
include("./rbzl_factory.jl")
include("./rbzl_helpers.jl")
include("./rbzl_acorn.jl")

function run(k::Integer=1)
    load_level(k)
    ifile = joinpath(@__DIR__, "..", "programs", @sprintf("level_%02d.jl", k))
    Acorn.acorn(ifile)
    close("all")
end

# ============================================================================ #
# GLOBALS
const BOARD = Vector{Board}(1)
const RAW_STR = Vector{String}(1)
# ============================================================================ #
end
