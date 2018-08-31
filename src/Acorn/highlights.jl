function get_color_jl(t::TokenStream, x::AbstractString)
    if x[1] == '\'' || x[1] == '"'
        return :light_yellow
    elseif x[1] == '#'
        return :light_black
    elseif length(x) > 1 && x[1] == ':'
        return :light_cyan
    elseif peek(t) == "("
        return :light_cyan
    elseif occursin(r"^[\-\+]?\d+$|^[\-\+]?\d*\.\d+$|^true$|^false$|^const$|^nothing$", x)
        return :magenta
    elseif occursin(r"^if$|^elseif$|^else$|^end$|^for$|^while$|^function$|^continue$|^break$|^return$|^using$|^import$|^begin$|^do$|^let$|^module$|^using$|^import$|^mutable$|^struct$|^export$", x)
        return :red
    else
        return :default
    end
end

function get_color_pzl(t::TokenStream, x::AbstractString)
    if x[1] == '#'
        return :light_black
    elseif x == "red"
        return :light_red
    elseif x == "green"
        return :light_green
    elseif x == "blue"
        return :light_blue
    elseif x == "^"
        return :magenta
    elseif x == "*"
        return :yellow
    elseif x == "x"
        return :light_black
    elseif length(x) == 1 && occursin(r"[neswNESW]", x)
        return :light_yellow
    else
        return :default
    end
end

get_color_default(t::TokenStream, x::AbstractString) =  :default

function get_color_function(pth::String)
    ext = splitext(pth)[2]
    if ext == ".pzl"
        return get_color_pzl
    elseif ext == ".jl"
        return get_color_jl
    else
        return get_color_default
    end
end
