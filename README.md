# RoboPuzzle
RoboPuzzle is a textual programming game based on the graphical programming game [*RoboZZle*](http://www.robozzle.com/beta/)© by Igor Ostrovsky. This version uses a text-based interface in the Julia programming language.

# Requirements
* [Julia](https://julialang.org/downloads/oldreleases.html) version 0.6.X (version 0.7 and above are not yet supported)

# Install
1. Download [Julia](https://julialang.org/downloads/oldreleases.html) (recommended 0.6.4)
2. Launch Julia
3. Run the commands:
```julia
Pkg.clone("https://github.com/scottiealexander/RoboPuzzle.jl.git")
Pkg.build("RoboPuzzle")
```

**Note**: Building RoboPuzzle with also download and install it's dependencies, so it may take a while. See [**Dependencies**](#dependencies) below for details.

# Getting started
Simply launch Julia and run:
```julia
import RoboPuzzle
RoboPuzzle.run()
```
Do not be alarmed if running `import RoboPuzzle` take a long time the first time it is run (it's dependencies - namely [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl) - need to be precompiled).

# Dependencies
Automatically downloaded and installed dependencies:
* [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl)
* [Acorn.jl](https://github.com/scottiealexander/Acorn.jl/tree/highlights) (specifically the *highlights* branch)
