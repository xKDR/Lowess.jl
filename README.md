# Lowess

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://xKDR.github.io/Lowess.jl/dev)
![Build Status](https://github.com/xKDR/Lowess.jl/actions/workflows/ci.yml/badge.svg)
![Build Status](https://github.com/xKDR/Lowess.jl/actions/workflows/documentation.yml/badge.svg)
[![codecov](https://codecov.io/gh/xKDR/Lowess.jl/branch/main/graph/badge.svg?token=b32DWzrvAH)](https://codecov.io/gh/xKDR/Lowess.jl)

This package is an alternative to https://github.com/JuliaStats/Loess.jl

## To install: 
```Julia
 add "https://github.com/xKDR/Lowess.jl.git"
```

This is a pure Julia lowess implementation. The lowess.c code from https://github.com/carlohamalainen/cl-lowess/blob/master/lowess.c has been hand-translated to Julia. 

## Synopsis

`Lowess` exports two functions, `lowess` and `lowess_model`. The `lowess` function returns the predict y-values for the input x-values. The `lowess_model` function returns a function that can be used to predict the y value for any given x value (which lies within the extrema of input x-values).   
The amount of smoothing is mainly controlled by the `f` keyword argument. E.g.:


```julia
using Lowess, Plots

xs = 10 .* rand(100)
xs = sort(xs)
ys = sin.(xs) .+ 0.5 * rand(100)

model = lowess_model(xs, ys, 0.2)

us = range(extrema(xs)...; step = 0.1)
vs = model(us)

scatter(xs, ys)
plot!(us, vs, legend=false)
```

# Benchmarks

```julia
using BenchmarkTools, Loess, Lowess
xs = 10 .* rand(100)
xs = sort(xs)
ys = sin.(xs) .+ 0.5 * rand(100)

@benchmark begin
model = loess(xs, ys, span=0.5)
us = range(extrema(xs)...; step = 0.1)
vs = predict(model, us)
end 
```
```
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  172.354 μs …   1.783 ms  ┊ GC (min … max):  0.00% … 86.02%
 Time  (median):     186.823 μs               ┊ GC (median):     0.00%
 Time  (mean ± σ):   215.683 μs ± 176.942 μs  ┊ GC (mean ± σ):  11.76% ± 12.18%
```

```julia
@benchmark begin
model = lowess_model(xs, ys, 0.2)
us = range(extrema(xs)...; step = 0.1)
vs = model(us)
end
```
```
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  47.797 μs …  1.420 ms  ┊ GC (min … max): 0.00% … 95.55%
 Time  (median):     58.236 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   58.842 μs ± 15.965 μs  ┊ GC (mean ± σ):  0.23% ±  0.96%
```
```julia
@benchmark lowess(xs, ys, 0.2)
```
```
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  46.183 μs … 316.997 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     56.525 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   57.325 μs ±   7.577 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%
```

# Example Plot

This example plot is generated using the following code. 

    using Lowess, Plots
    RAND_MAX = 2147483647
    n = 200
    xs = 1:200
    xs = (i -> i*2*pi/n).(xs)
    ys = sin.(xs) .+ rand(0:RAND_MAX - 1, 200)/(RAND_MAX + 1)
    f = 0.25
    nsteps = 3
    delta = 0.3

    zs = lowess(xs, ys, f, nsteps, delta)

    scatter(xs, ys)
    plot!(xs, zs)

![Example Plot](lowess.svg)

## References in Loess.jl
[1] Cleveland, W. S. (1979). Robust locally weighted regression and smoothing scatterplots. Journal of the American statistical association, 74(368), 829-836. DOI: 10.1080/01621459.1979.10481038

[2] Cleveland, W. S., & Devlin, S. J. (1988). Locally weighted regression: an approach to regression analysis by local fitting. Journal of the American statistical association, 83(403), 596-610. DOI: 10.1080/01621459.1988.10478639

[3] Cleveland, W. S., & Grosse, E. (1991). Computational methods for local regression. Statistics and computing, 1(1), 47-62. DOI: 10.1007/BF01890836

# Support

We gratefully acknowledge the JuliaLab at MIT for financial support for this project.
