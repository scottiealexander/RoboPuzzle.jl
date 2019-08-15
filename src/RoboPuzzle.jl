module RoboPuzzle

function __init__()
    # silence the old "QApplication: invalid style override passed, ignoring
    #  it." warning...
    Base.eval(Main, :(ENV["QT_STYLE_OVERRIDE"] = ""))
end

using PyCall, PyPlot, Printf, LinearAlgebra

include("./Acorn/Acorn.jl")

include("./rbzl_constants.jl")
include("./rbzl_player.jl")
include("./rbzl_board.jl")
include("./rbzl_factory.jl")
include("./rbzl_helpers.jl")
include("./rbzl_acorn.jl")

function run(k::Integer=1)
    PyDict(pyimport("matplotlib")."rcParams")["toolbar"] = "None"
    load_level(k)
    idir = joinpath(@__DIR__, "..", "programs")
    if !isdir(idir)
        mkdir(idir)
    end
    ifile = joinpath(idir, @sprintf("level_%02d.jl", k))
    acorn_init()
    Acorn.acorn(ifile)
    close("all")
end

# ============================================================================ #
# GLOBALS
const BOARD = Vector{Board}(undef, 1)
const RAW_STR = Vector{String}(undef, 1)
# ============================================================================ #
end
