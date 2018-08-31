module SimpleParser

export printrow, TokenStream, peek

mutable struct TokenStream{T<:AbstractString}
    src::T
    ptr::Int
end
TokenStream(src::AbstractString) = TokenStream(src, 1)

function peek(t::TokenStream)
    ptr = t.ptr
    next = iterate(t, ptr)
    
    if next == nothing
        # return an empty substring
        nel = length(t.src)
        tkn = SubString{String}(t.src, nel, nel-1)
    else
        tkn = next[1]
    end
    
    t.ptr = ptr
    
    return tkn
end

function Base.collect(t::TokenStream)
    x = Vector{SubString{String}}()
    while (next = iterate(t)) != nothing
        push!(x, next[1])
    end
    return x
end

# Base.done(t::TokenStream, state::Integer=1) = t.ptr > length(t.src)
# Base.start(t::TokenStream) = 1

Base.IteratorSize(t::TokenStream) = Base.SizeUnknown()
Base.IteratorEltype(t::TokenStream) = Base.HasEltype()
Base.eltype(t::TokenStream) = SubString{String}

function Base.iterate(t::TokenStream, state::Integer=1)
    t.ptr > length(t.src) && return nothing

    x = t.src[t.ptr:t.ptr]

    if occursin(r"\w|\.", x)
        k = findnext_nonmatch(t, r"\w|\.", t.ptr)
        
    elseif x[1] == '\'' || x[1] == '"'
        k = findnext(t, x[1], t.ptr+1)
        
    elseif occursin(r"[^\w\s]", x)
        if x == "#"
            k = findnext_nonmatch(t, r"[^\n\r]{1,2}", t.ptr)
        elseif x[1] == ':' && t.ptr < length(t.src)
            if occursin(r"[A-Za-z_\:]", t.src[t.ptr+1:t.ptr+1])
                k = findnext_nonmatch(t, r"\w", t.ptr+1)
            else
                k = t.ptr
            end
        else
            k = t.ptr
        end
        
    elseif isspace(x[1])
        k = findnext_nonmatch(t, r"\s", t.ptr)
    end

    tkn = SubString(t.src, t.ptr, k)
    t.ptr = k + 1

    return tkn, t.ptr
end

# TODO: findnext and findnext_nonmatch are using difference call conventions
# this should be made consistent
function findnext_nonmatch(t::TokenStream, r::Regex, start::Integer)
    k = start
    while k < length(t.src) && occursin(r, t.src[k+1:k+1])
        k += 1
    end
    return k
end

function findnext(t::TokenStream, chr::Char, start::Integer)
    start >= length(t.src) && return length(t.src)

    k = start
    while k <= length(t.src)
        if t.src[k] == chr && t.src[k-1] != '\\'
            break
        end
        k += 1
    end
    return k > length(t.src) ? length(t.src) : k
end

function printrow(io::IO, x::AbstractString, colorfun::Function)
    ts = TokenStream(x)
    iocolored = IOContext(io, :color => true)
    
    next = Base.iterate(ts)
    while next != nothing
        tkn, k = next
        
        printstyled(iocolored, tkn, color=colorfun(ts, tkn))
        
        next = iterate(ts)
    end

    return io
end

# function Base.show(io::IO, t::TokenStream)
#     while !done(t)
#         tkn = next(t)[1]
#         print_with_color(get_color_pzl(t, tkn), io, tkn)
#     end
#     return io
# end
#
# function test()
#     src = """
#     #this is a comment
#     x = 0
#     while x < 10
#         println("hello world")
#         x += 1 #set x to be 1
#         yield()
#     end
#     """
#     # return TokenStream(src)
#     return TokenStream(src)
# end

end
