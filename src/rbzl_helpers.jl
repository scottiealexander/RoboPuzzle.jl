vline(x::AbstractVector{<:Real}; args...) = plot([x'; x'], ylim(); args...)
hline(y::AbstractVector{<:Real}; args...) = plot(xlim(), [y'; y']; args...)

function grid(ax; args...)
    x = UnitRange{Int}(ax[:get_xlim]()...)
    y = UnitRange{Int}(ax[:get_ylim]()...)
    vline(x; args...)
    hline(y; args...)
end


@inline colorname(rgb::NTuple{4, Float64}) = colorname(rgb[1:3])
function colorname(rgb::NTuple{3, Float64})
    if haskey(COLORS, rgb)
        return COLORS[rgb]
    else
        rgbs = collect(keys(COLORS))
        (mn, k) = findmin(map(x->vecnorm(x .- rgb), rgbs))
        return mn < 1.0 ? COLORS[rgbs[k]] : ""
    end
end

function decomment(x::Vector{<:AbstractString})
    filter!(a->a[1] != '#', x)
    return x
end

function clear!(x::PatchDict)
    for k in keys(x)
        x[k][:remove]()
        delete!(x, k)
    end
    return x
end

function message_box(b::Board, str::String, color::String="orange")
    ht = b.ax[:text](0.5, 0.5, str, fontsize=36, horizontalalignment="center",
        verticalalignment="center", transform=b.ax[:transAxes],
        bbox=Dict{String,Any}("facecolor"=>color, "alpha"=>0.8))
    return ht
end

function blank_figure(hf::PyPlot.Figure)
    if plt[:fignum_exists](hf[:number])
        h = hf
    else
        h = figure(num="Robo-puzzle")
    end

    for ax in h[:axes]
        h[:delaxes](ax)
    end

    ax = h[:add_axes]([0, 0, 1, 1])

    ax[:set_frame_on](false)
    ax[:set_xticks]([])
    ax[:set_yticks]([])
    return h, ax
end

function init_board(ncol::Integer, nrow::Integer)
    if isassigned(BOARD, 1)
        clear!(BOARD[1])
        h, ax = blank_figure(BOARD[1].hf)
    else
        h, ax = blank_figure(figure(num="Robo-puzzle"))
    end

    h[:set_size_inches](ncol, nrow)

    ax[:set_xlim](1, ncol+1)
    ax[:set_ylim](1, nrow+1)

    grid(ax; color="black")

    return Board(h, ax)
end

function load_level(n::Integer)
    name = @sprintf("%02d.pzl", n)
    pth = joinpath(@__DIR__, "..", "levels", name)
    return load_level(pth)
end

function load_level(pth::AbstractString)
    if isfile(pth)
        make_board(pth)
    end
    return nothing
end
