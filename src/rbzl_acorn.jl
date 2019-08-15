function safe_eval(ex::Expr, ed::Acorn.Editor)
    wait_limit = 15.0

    success = false
    expr = :(try catch err return err end)
    expr.args[1] = ex
    inject_yield!(expr)

    try
        t = @async eval(expr)

        tend = time() + wait_limit
        while !istaskdone(t) && (time() <= tend)
            sleep(0.2)
            yield()
        end

        if !istaskdone(t)
            killt = @task try
                Base.throwto(t, InterruptException())
            catch
            end
            try
                schedule(killt, InterruptException(), error = false)
                Acorn.setStatusMessage(ed, "Task killed!")
            catch
            end
        else
            if isa(t.result, Exception)
                throw(t.result)
            else
                success = true
            end
        end

    catch err
        bt = catch_backtrace()
        msg = sprint(showerror, err, bt)
        Acorn.setStatusMessage(ed, msg)
    end

    return success
end

function inject_yield!(ex::Expr)
    if ex.head == :while || ex.head == :for
        # the loop body is a block, so make sure the block ends with a yield
        # i think there *should* ever only be one block, but just to be sure...
        for k in eachindex(ex.args)
            if isa(ex.args[k], Expr) && ex.args[k].head == :block
                push!(ex.args[k].args, :(yield()))
            end
        end
    else
        for k in eachindex(ex.args)
            if isa(ex.args[k], Expr)
                inject_yield!(ex.args[k])
            end
        end
    end
    return ex
end

function evalCommand(str::AbstractString, ed::Acorn.Editor)
    src = "let\n" * str * "\nend"
    exprs = Vector{Expr}()
    k = 1
    while k <= length(src)
        ex, k = Meta.parse(src, k, greedy=true, raise=false)
        ex != nothing && push!(exprs, ex)
    end

    bcontinue = true
    tend = time() + 20
    while !game_over() && bcontinue
        for k in eachindex(exprs)
            bcontinue = safe_eval(exprs[k], ed)
            if !bcontinue
                break
            end
            sleep(0.002)
        end
        bcontinue = bcontinue ? time() <= tend : false
        yield()
    end
end

function commandRun(ed::Acorn.Editor, args::String)
    refresh()
    evalCommand(Acorn.rowsToString(ed.rows), ed)
end

function commandReload(ed::Acorn.Editor, args::String)
    # safe_eval(:(Test.refresh()), ed)
    refresh()
end

function commandLoadLevel(ed::Acorn.Editor, args::String)
    level = ""
    loadLevelCB(ed::Acorn.Editor, buf::String, key::Char) = begin
        level = strip(buf)
    end

    Acorn.editorPrompt(ed, "Level to load: ", callback=loadLevelCB, buf="",
        showcursor=true)

    try
        if occursin(r"\d+", level)
            k = parse(Int, level)
            load_level(k)
            ifile = joinpath(@__DIR__, "..", "programs", @sprintf("level_%02d.jl", k))
        else
            # load an existing level
            if !endswith(level, ".pzl")
                level *= ".pzl"
            end
            pzlfile = joinpath(@__DIR__, "..", "levels", level)
            if isfile(pzlfile)
                ifile = joinfile(@__DIR__, "..", "programs",
                    splitext(level)[1] * ".jl")

                load_level(pzlfile)
            else
                Acorn.setStatusMessage(ed, "[ERROR]: invalid level $(level)")
                return nothing
            end

        end

        Acorn.editorOpen(ed, ifile)
    catch
        Acorn.setStatusMessage(ed, "[ERROR]: invalid level $(level)")
    end
    return nothing
end

function commandLoadPuzzle(ed::Acorn.Editor, args::String)
    level = ""
    loadLevelCB(ed::Acorn.Editor, buf::String, key::Char) = begin
        level = strip(buf)
    end

    Acorn.editorPrompt(ed, "Name of puzzle to load: ", callback=loadLevelCB, buf="",
        showcursor=true)

    if occursin(r"\d+", level)
        k = parse(Int, level)
        ifile = joinpath(@__DIR__, "..", "levels", @sprintf("%02d.pzl", k))
    elseif occursin(r"^[\w\-]+$", level)
        level *= ".pzl"
        ifile = joinpath(@__DIR__, "..", "levels", levl)
    else
        Acorn.setStatusMessage(ed, "[ERROR]: invalid level $(level)")
        return
    end

    Acorn.editorOpen(ed, ifile)
end

function acorn_init()
    Acorn.addCommand(:run, commandRun,
               help="run: run the current script (crtl-x)")

    Acorn.setKeyBinding('x', "run")

    Acorn.addCommand(:reload, commandReload,
               help="reload: reload the current board (crtl-r)")

    Acorn.setKeyBinding('r', "reload")

    Acorn.addCommand(:level, commandLoadLevel,
               help="level: load a level (ctrl-l)")

    Acorn.setKeyBinding('l', "level")

    Acorn.addCommand(:load, commandLoadPuzzle,
               help="load: load a puzzle (ctrl-o)")

    Acorn.rmKeyBinding('o')
    Acorn.setKeyBinding('o', "load")
end
