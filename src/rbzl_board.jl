# ============================================================================ #
mutable struct Board
    hf::PyPlot.Figure
    ax::PyCall.PyObject
    squares::PatchDict
    coins::PatchDict
    player::Player
    counter::Int
end

function Board(hf, ax)
    if !isassigned(BOARD, 1)
        p = Player(1, 1, East)
        b = Board(hf, ax, PatchDict(), PatchDict(), p, 0)
        BOARD[1] = b
    else
        b = BOARD[1]
        b.player = Player(1, 1, East)
        b.hf = hf
        b.ax = ax
    end
    return b
end

increment!(b::Board) = begin b.counter += 1 end

function set_color(b::Board, x::Integer, y::Integer, col::AbstractString)
    if haskey(b.squares, (x, y))
        b.squares[(x,y)][:set_facecolor](col)
    end
    return nothing
end

function get_color(b::Board, x::Integer, y::Integer)
    !haskey(b.squares, (x, y)) && error("Invalid patch corrdinates!")
    return colorname(b.squares[(x,y)][:get_facecolor]())
end

get_color(b::Board) = get_color(b, location(b.player)...)

function set_player(b::Board, x::Integer, y::Integer, facing::Bearing)
    set_to_face!(b.player, facing)
    moveto!(b.player, x, y)
    b.ax[:add_patch](b.player.h)
    return nothing
end

function set_square(b::Board, x::Integer, y::Integer, color::AbstractString="gray")
    p = matplotlib[:patches][:Rectangle]((x,y), 1, 1, color=color)
    b.squares[(x,y)] = p
    b.ax[:add_patch](p)
    return nothing
end

function set_coin(b::Board, x::Integer, y::Integer)
    p = matplotlib[:patches][:CirclePolygon]((x+.5,y+.5), .2, color="gold")
    b.coins[(x,y)] = p
    b.ax[:add_patch](p)
    return nothing
end

function turn(b::Board, d::Direction)
    game_over() && return nothing
    increment!(b)
    turn!(b.player, d)
    sleep(1/SPEED)
    return nothing
end

@inline left(b::Board) = turn(b, Left)
@inline right(b::Board) = turn(b, Right)

function forward(b::Board)
    game_over() && return nothing
    increment!(b)
    dst = Tuple{Int,Int}(destination(b.player))
    if haskey(b.squares, dst)
        moveto!(b.player, dst...)
        b.hf[:canvas][:draw]()

        if haskey(b.coins, dst)
            sleep(1/(SPEED*2))
            b.coins[dst][:remove]()
            delete!(b.coins, dst)
            if isempty(b.coins)
                message_box(b, "Final score: $(b.counter)!")
            end
        end
    end
    sleep(1/SPEED)
    return nothing
end

coins_remaining(b::Board) = length(b.coins)

@inline left() = isassigned(BOARD, 1) && left(BOARD[1])
@inline right() = isassigned(BOARD, 1) && right(BOARD[1])
@inline forward() = isassigned(BOARD, 1) && forward(BOARD[1])
@inline get_color() = isassigned(BOARD, 1) && get_color(BOARD[1])
@inline coins_remaining() = isassigned(BOARD, 1) && coins_remaining(BOARD[1])

@inline red() = get_color() == "red"
@inline green() = get_color() == "green"
@inline blue() = get_color() == "blue"
@inline gray() = get_color() == "gray"

function game_over()
    if isassigned(BOARD, 1)
        return isempty(BOARD[1].coins) || BOARD[1].counter > ceil(Int, length(BOARD[1].squares)* 1.5)
    else
        return true
    end
end

function refresh()
    if isassigned(RAW_STR, 1)
        make_board(RAW_STR[1])
    end
    return nothing
end

function clear!(b::Board)
    if plt[:fignum_exists](b.hf[:number])
        clear!(b.squares)
        clear!(b.coins)
        clear!(b.player)
    end
    b.counter = 0
    return b
end

# ============================================================================ #
