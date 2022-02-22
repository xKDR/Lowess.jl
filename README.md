# Lowess

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ayushpatnaikgit.github.io/Lowess.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ayushpatnaikgit.github.io/Lowess.jl/dev)
[![Build Status](https://travis-ci.com/ayushpatnaikgit/Lowess.jl.svg?branch=main)](https://travis-ci.com/ayushpatnaikgit/Lowess.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/ayushpatnaikgit/Lowess.jl?svg=true)](https://ci.appveyor.com/project/ayushpatnaikgit/Lowess-jl)
[![Build Status](https://api.cirrus-ci.com/github/ayushpatnaikgit/Lowess.jl.svg)](https://cirrus-ci.com/github/ayushpatnaikgit/Lowess.jl)
[![Coverage](https://codecov.io/gh/ayushpatnaikgit/Lowess.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/ayushpatnaikgit/Lowess.jl)
[![Coverage](https://coveralls.io/repos/github/ayushpatnaikgit/Lowess.jl/badge.svg?branch=main)](https://coveralls.io/github/ayushpatnaikgit/Lowess.jl?branch=main)

This package is an alternative to https://github.com/JuliaStats/Loess.jl

## To install: 
```Julia
 add "git://github.com/xKDR/Lowess.jl.git"
```

This is a pure Julia lowess implementation. The lowess.c code from https://github.com/wch/r-source/blob/trunk/src/library/stats/src/lowess.c has been hand-translated to Julia. 

## Synopsis

`Lowess` exports two functions, `lowess` and `lowess_model`. The `lowess` function returns the predict y-values for the input x-values. The `lowess_model` function returns a function that can be used to predict the y value for any given x value (which lies within the extrema of input x-values).   
The amount of smoothing is mainly controlled by the `f` keyword argument. E.g.:


```julia
using Lowess, Plots

xs = 10 .* rand(100)
xs = sort(xs)
ys = sin.(xs) .+ 0.5 * rand(100)

model = lowess(xs, ys, 0.2)

us = range(extrema(xs)...; step = 0.1)
vs = model(us)

scatter(xs, ys)
plot!(us, vs, legend=false)
```

![Example Plot](lowess.svg)

## References in Loess.jl
[1] Cleveland, W. S. (1979). Robust locally weighted regression and smoothing scatterplots. Journal of the American statistical association, 74(368), 829-836. DOI: 10.1080/01621459.1979.10481038

[2] Cleveland, W. S., & Devlin, S. J. (1988). Locally weighted regression: an approach to regression analysis by local fitting. Journal of the American statistical association, 83(403), 596-610. DOI: 10.1080/01621459.1988.10478639

[3] Cleveland, W. S., & Grosse, E. (1991). Computational methods for local regression. Statistics and computing, 1(1), 47-62. DOI: 10.1007/BF01890836

