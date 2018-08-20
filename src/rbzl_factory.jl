# ============================================================================ #
function make_board(str::String)
    if isfile(str)
        raw = read(str, String)
    else
        raw = str
    end

    RAW_STR[1] = raw

    lines = map(x->split(x, r"\s+"), decomment(split(strip(raw), r"\r|\r\n|\n")))

    nrow = length(lines)
    ncol = mapreduce(length, max, lines)
    nel = sum(length, lines)

    brd = init_board(ncol, nrow)

    player_location = [0, 0]
    facing = East

    for r = 1:nrow
        for c = 1:length(lines[r])
            if !isempty(lines[r][c]) && (strip(lines[r][c]) != "x")
                m = match(r"^(\w+)((?:\*?|\^\w?))$", lines[r][c])
                if m == nothing
                    warn("Invalid square definition at [$(c), $(r)]: $(lines[r][c])")
                else
                    set_square(brd, c, nrow - r + 1, m[1])
                    if m[2] == "*"
                        set_coin(brd, c, nrow - r + 1)
                    elseif !isempty(m[2]) && m[2][1] == '^'
                        player_location .= [c, nrow - r + 1]
                        if c == ncol
                            # change default if we're in the last column
                            facing = West
                        end
                        if length(m[2]) > 1
                            if m[2][2] == 'n'
                                facing = North
                            elseif m[2][2] == 'e'
                                facing = East
                            elseif m[2][2] == 's'
                                facing = South
                            elseif m[2][2] == 'w'
                                facing = West
                            end
                        end
                    end
                end
            end
        end
    end

    # player not specified, put them in the first valid square
    if sum(player_location) < 1
        player_location = [first(keys(brd.squares))...]
    end

    set_player(brd, player_location..., facing)

    return brd
end
# ============================================================================ #
