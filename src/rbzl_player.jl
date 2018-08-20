# ============================================================================ #
mutable struct Player
    h::PyCall.PyObject
    loc::Vector{Float64} # the actaul x,y location of the player
    facing::Bearing
end

function Player(x::Integer, y::Integer, facing::Bearing=East)
    pts = [
        -0.2 -0.2;
        -0.2 +0.2;
        +0.2 +0.0;
    ]
    loc = [x+.5 y+.5]
    h = plt[:Polygon](pts .+ loc, facecolor="black")
    p = Player(h, vec(loc), facing)

    return set_to_face!(p, facing)
end

# get the x,y location of the player in board corrdinates (i.e. which grid square)
location(p::Player) = (Int(p.loc[1]-.5), Int(p.loc[2]-.5))
clear!(p::Player) = p.h[:remove]()

moveto!(p::Player, x::Real, y::Real) = moveto!(p, [x, y])
function moveto!(p::Player, xy::Vector{<:Real})
    df = xy .+ .5 .- p.loc
    p.h[:set_xy](p.h[:get_xy]() .+ df')
    p.loc = xy .+ .5
    return p
end

function set_to_face!(p::Player, facing::Bearing)
    if facing != p.facing
        df = rem(Int(facing) - Int(p.facing), 4)
        for k = 1:abs(df)
            turn!(p, Direction(sign(df)))
        end
    end
    return p
end

forward!(p::Player) = moveto!(p, destination(p))

function destination(p::Player)
    if p.facing == North
        return p.loc .+ [-.5, .5]
    elseif p.facing == East
        return p.loc .+ [.5, -.5]
    elseif p.facing == South
        return p.loc .+ [-.5, -1.5]
    elseif p.facing == West
        return p.loc .+ [-1.5, -.5]
    end
end

function turn!(p::Player, d::Direction)
    if d == Left
        xfm = [0 -1; 1 0]
    elseif d == Right
        xfm = [0 1; -1 0]
    else
        # we only accept relative turns (i.e. LEFT and RIGHT)
        xfm = [1 0; 0 1]
    end
    pts = (permutedims(p.h[:get_xy](), (2, 1)) .- p.loc)
    p.h[:set_xy](permutedims(xfm * pts .+ p.loc, (2, 1)))

    p.facing = Bearing(mod(Int(p.facing) + Int(d), 4))

    return p
end
