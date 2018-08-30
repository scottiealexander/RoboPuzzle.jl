# RoboPuzzle
RoboPuzzle is a textual programming game based on the graphical programming game [*RoboZZle*](http://www.robozzle.com/beta/)© by Igor Ostrovsky. This version uses a text-based interface in the Julia programming language.

# Requirements
* [Julia](https://julialang.org/downloads/) version 0.7 or higher

# Install
1. Download and install [Julia](https://julialang.org/downloads/) (recommended 1.0)
2. Launch Julia
3. Run the commands:
```julia
using Pkg
Pkg.add(PackageSpec(url="https://github.com/scottiealexander/RoboPuzzle.jl.git", rev="0.7"))
Pkg.build("RoboPuzzle")
```

**Note**: Building RoboPuzzle will also download and install it's dependencies, so it may take a while. See [**Dependencies**](#dependencies) below for details.

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
* [Acorn.jl](https://github.com/scottiealexander/Acorn.jl/tree/highlights-1.0) (specifically the *highlights-1.0* branch)
