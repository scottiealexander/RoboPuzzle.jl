import Base.==

@enum(Key,
    BACKSPACE = (@static Sys.iswindows() ? 8 : 127),
    ESCAPE = 27,
    ARROW_LEFT = 1000,
    ARROW_RIGHT,
    ARROW_UP,
    ARROW_DOWN,
    DEL_KEY,
    HOME_KEY,
    END_KEY,
    PAGE_UP,
    PAGE_DOWN,
    S_ARROW_UP,
    S_ARROW_DOWN,
    S_ARROW_LEFT,
    S_ARROW_RIGHT,
    C_ARROW_UP,
    C_ARROW_DOWN,
    C_ARROW_LEFT,
    C_ARROW_RIGHT
    )

==(c::UInt32, k::Key) = c == UInt32(k)
==(k::Key, c::UInt32) = c == UInt32(k)
==(c::Char, k::Key) = UInt32(c) == UInt32(k)
==(k::Key, c::Char) = UInt32(c) == UInt32(k)

ctrl_key(c::Char)::UInt32 = UInt32(c) & 0x1f

# For debugging
function printNextKey()
	term = REPL.Terminals.TTYTerminal(get(ENV, "TERM", @static Sys.iswindows() ? "" : "dumb"), stdin, stdout, stderr)
	REPL.Terminals.raw!(term, true)
	c = readNextChar()
	print("Code: $(UInt32(c)), Char: $(Char(c))\n")
	print("Buffer size: $(stdin.buffer.size)\n")
	for k in 1:stdin.buffer.size
	    c = readNextChar()
	    print("Code: $(UInt32(c)), Char: $(Char(c))\n")
	end
	REPL.Terminals.raw!(term, true)
	return c
end

readNextChar() = Char(read(stdin,1)[1])

function readKey()
    c = readNextChar()

    # Escape characters
    if c == '\x1b'
        ret = ESCAPE
        
        if stdin.buffer.size < 3
            return UInt32(ESCAPE)
        end
        
        esc_a = readNextChar()
        esc_b = readNextChar()

        if esc_a == '['
            if esc_b >= '0' && esc_b <= '9'
                if stdin.buffer.size < 4
                    return UInt32(ESCAPE)
                end
                esc_c = readNextChar()

                if esc_c == '~'
                    if esc_b == '1'
                        ret = HOME_KEY
                    elseif esc_b == '4'
                        ret = END_KEY
                    elseif esc_b == '3'
                        ret = DEL_KEY
                    elseif esc_b == '5'
                        ret = PAGE_UP
                    elseif esc_b == '6'
                        ret = PAGE_DOWN
                    elseif esc_b == '7'
                        ret = HOME_KEY
                    elseif esc_b == '8'
                        ret = END_KEY
                    else
                        ret = ESCAPE
                    end
                elseif esc_c == ';'
                    if stdin.buffer.size < 6
                        return UInt32(ESCAPE)
                    end

                    esc_d = readNextChar()
                    esc_e = readNextChar()

                    if esc_d == '2'
                        # shift + arrorw
                        if esc_e == 'A'
                            ret = S_ARROW_UP
                        elseif esc_e == 'B'
                            ret = S_ARROW_DOWN
                        elseif esc_e == 'C'
                            ret = S_ARROW_RIGHT
                        elseif esc_e == 'D'
                            ret = S_ARROW_LEFT
                        else
                            ret = ESCAPE
                        end
                    elseif esc_d == '3'
                        # alt + arrow
                        if esc_e == 'C'
                            ret = END_KEY
                        elseif esc_e == 'D'
                            ret = HOME_KEY
                        else
                            ret = ESCAPE
                        end
                    elseif esc_d == '5'
                        # Ctrl + arrow
                        if esc_e == 'A'
                            ret = C_ARROW_UP
                        elseif esc_e == 'B'
                            ret = C_ARROW_DOWN
                        elseif esc_e == 'C'
                            ret = C_ARROW_RIGHT
                        elseif esc_e == 'D'
                            ret = C_ARROW_LEFT
                        else
                            ret = ESCAPE
                        end
                    end
                end
            else
                # Arrow keys
                if esc_b == 'A'
                    ret = ARROW_UP
                elseif esc_b == 'B'
                    ret = ARROW_DOWN
                elseif esc_b == 'C'
                    ret = ARROW_RIGHT
                elseif esc_b == 'D'
                    ret = ARROW_LEFT
                elseif esc_b == 'H'
                    ret = HOME_KEY
                elseif esc_b == 'F'
                    ret = END_KEY
                else
                    ret = ESCAPE
                end
            end
        elseif esc_a == 'O'
            if esc_a == 'H'
                ret = HOME_KEY
            elseif esc_a == 'F'
                ret = END_KEY
            end
        else
            ret = ESCAPE
        end

        return UInt32(ret)
    else
        return UInt32(c)
    end
end
