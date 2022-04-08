module Lowess
using Interpolations

export lowess, lowess_model

function rcmp(x::T, y::T, nalast::Int)::Int where T <: AbstractFloat
    if (x < y)
        return -1
    end 
    if (x > y)
        return 1
    end 
    return 0
end

function rPsort2(x::Vector{T}, lo::Int, hi::Int, k::Int) where T <: AbstractFloat
    v::T = 0.0
    w::T = 0.0
    nalast::Int = 1
    L::Int = 0
    R::Int = 0
    i::Int = 0
    j::Int = 0

    L = lo
    R = hi
    while (L < R)
        v = x[k]
        
        i = L
        j = R
        while (i <= j)
            while (rcmp(x[i], v, nalast) < 0) 
                i = i + 1
            end 
            while (rcmp(v, x[j], nalast) < 0)
                j = j - 1
            end 
            if (i <= j)
                w = x[i]
                x[i] = x[j]
                i = i + 1
                x[j] = w
                j = j - 1
            end
        end
        if (j < k)
            L = i
        end
        if (k < i)
            R = j
        end  
    end 
end 

function rPsort(x::Vector{T}, n::Int, k::Int) where T <: AbstractFloat
    rPsort2(x, 1, n, k)
end 

function lowest(
    x::AbstractVector{T},
    y::AbstractVector{T},
    n::Integer, 
    xs::T,
    ys::AbstractVector{T},
    ys_pos::Integer, 
    nleft::Integer,
    nright::Integer,
    w::AbstractVector{T},
    userw::Bool, 
    rw::AbstractVector{T},
    ok::Vector{Int}
) where T <: AbstractFloat
    b::T = 0.0
    c::T = 0.0
    r::T = 0.0
    nrt::Int = 0

    # Julia indexing starts at 1, so add 1 to all indexes
    range::T = x[n] - x[1]
    h::T = max(xs - x[nleft], x[nright] - xs)
    h9::T = 0.999 * h
    h1::T = 0.001 * h

    # compute weights (pick up all ties on right)
    a::T = 0.0     # sum of weights
    j::Int = nleft   # initialize j
    
    for i in nleft:n  # i = j at all times
        w[j] = 0.0
        r = abs(x[j] - xs)      # replaced fabs with abs
        if (r <= h9)       # small enough for non-zero weight
            if (r <= h1)
                w[j] = 1.0
            else 
                w[j] = (1 - (r / h)^3)^3
            end 
            
            if (userw)
                w[j] = w[j] * rw[j]
            end

            a += w[j]
        elseif (x[j] > xs)      # get out at first zero wt on right
            break
        end
        
        # increment j 
        j = j + 1
    end
    
    nrt = j - 1     # rightmost pt (may be greater than nright because of ties)
    if (a <= 0.0)
        ok[1] = 0   # ok is a 1 length vector
    else   # weighted least squares
        ok[1] = 1

        # make sum of w[j + 1] == 1
        j = nleft
        for i in nleft:nrt      # i = j at all times
            w[j] = w[j] / a

            # increment j
            j = j + 1
        end

        if (h > 0.0)    # use linear fit
            # find weighted center of x values
            j = nleft
            a = 0.0
            for i in nleft:nrt  # i = j at all times
                a += w[j] * x[j]
                
                # increment j
                j = j + 1
            end
            
            b = xs - a

            j = nleft
            c = 0.0
            for i in nleft:nrt  # i = j at all times
                c += w[j] * (x[j] - a) * (x[j] - a)

                # increment j 
                j = j + 1
            end

            if (sqrt(c) > 0.001 * range)
                # points are spread out enough to compute slope
                b = b/c

                j = nleft
                for i in nleft:nrt  # i = j at all times
                    w[j] = w[j] * (1.0 + b*(x[j] - a))

                    # increment 
                    j = j + 1
                end 
            end 
        end

        j = nleft
        ys[ys_pos] = 0.0
        for i in nleft:nrt  # i = j at all times
            ys[ys_pos] += w[j] * y[j]

            # increment j
            j = j + 1
        end
    end 
end 

"""
```julia
lowess(x, y, f = 2/3, nsteps = 3, delta = 0.01*(maximum(x) - minimum(x)))
```

Compute the smooth of a scatterplot of `y` against `x` using robust locally weighted regression. Input vectors `x` and `y` must contain either integers or floats. Parameters `f` and `delta` must be of type `T`, where `T <: AbstractFloat`. Returns a vector `ys`; `ys[i]` is the fitted value at `x[i]`. To get the smooth plot, `ys` must be plotted against `x`. 

# Arguments
- `x::Vector`: Abscissas of the points on the scatterplot. `x` must be ordered.
- `y::Vector`: Ordinates of the points in the scatterplot. 
- `f::T`: The amount of smoothing. 
- `nsteps::Integer`: Number of iterations in the robust fit.
- `delta::T`: A nonnegative parameter which may be used to save computations.

# Example
```julia
using Lowess, Plots
x = sort(10 .* rand(100))
y = sin.(x) .+ 0.5 * rand(100)
ys = lowess(x, y, 0.2)
scatter(x, y)
plot!(x, ys)
```
"""
function lowess(
    x::AbstractVector{T},
    y::AbstractVector{T},
    f::T = 2/3,
    nsteps::Integer = 3,
    delta::T = 0.01*(maximum(x) - minimum(x)),
) where T <: AbstractFloat
    # defining needed variables
    n::Int = length(x)
    ys::Vector{T} = Vector{T}(undef, n)
    rw::Vector{T} = Vector{T}(undef, n)
    res::Vector{T} = Vector{T}(undef, n)

    iter::Int = 0
    ok::Vector{Int} = Vector{Int}(undef, 1)
    # for safety, initialize ok to 0
    ok[1] = 0

    i::Int = 0
    j::Int = 0
    last::Int = 0
    m1::Int = 0
    m2::Int = 0
    nleft::Int = 0
    nright::Int = 0
    ns::Int = 0
    d1::T = 0.0
    d2::T = 0.0
    denom::T = 0.0
    alpha::T = 0.0
    cut::T = 0.0
    cmad::T = 0.0
    c9::T = 0.0
    c1::T = 0.0
    r::T = 0.0
    sc::T = 0.0

    if (n < 2)
        ys[1] = y[1]
        return ys
    end 

    ns = max(min(floor(Int, f*n + 0.0000001), n), 2)  # at least two, at most n points
    
    iter = 1
    while (iter <= nsteps + 1)  # robustness iterations
        nleft = 1
        nright = ns
        last = 0   # index of prev estimated point
        i = 1   # index of current point

        while true 
            if (nright < n)
                # move nleft, nright to right if radius decreases
                d1 = x[i] - x[nleft]
                d2 = x[nright + 1] - x[i]

                # if d1 <= d2 with x[nright + 1] == x[nright], lowest fixes
                if (d1 > d2)
                    # radius will not decrease by move right
                    nleft = nleft + 1;
                    nright = nright + 1;
                    continue
                end
            end

            # fitted value at x[i]
            lowest(x, y, n, x[i], ys, i, nleft, nright, res, (iter > 1), rw, ok)
            if (ok[1] == 0)
                ys[i] = y[i]
            end 

            # all weights zero - copy over value (all rw==0)
            if (last < i - 1)   # skipped points -- interpolate
                denom = x[i] - x[last]  # non-zero - proof?
                j = last + 1
                for t in (last + 1):(i - 1) # t = j at all times
                    alpha = (x[j] - x[last]) / denom
                    ys[j] = alpha * ys[i] + (1.0 - alpha) * ys[last]

                    # increment j
                    j = j + 1
                end 
            end 

            last = i    # last point actually estimated
            cut = x[last] + delta   # x coord of close points

            # find close points
            i = last + 1
            for t in (last + 1):n # t = i at all times
                if (x[i] > cut) # i one beyond last pt within cut
                    break
                end 
                
                if (x[i] == x[last])
                    ys[i] = ys[last]
                    last = i
                end 

                # increment i
                i = i + 1
            end
            i = max(last + 1,i - 1)
            
            # back 1 point so interpolation within delta, but always go forward
            # check do while loop condition
            if (last >= n)
                break
            end
        end
        
        # residuals
        for i in 0:(n - 1) 
            res[i + 1] = y[i + 1] - ys[i + 1]
        end

        # overall scale estimate
        sc = 0.0
        for i in 0:(n - 1)
            sc = sc + abs(res[i + 1])
        end
        sc /= n
        
        if (iter > nsteps)  # compute robustness weights except last time
            break
        end

        for i in 0:(n - 1)
            rw[i + 1] = abs(res[i + 1])
        end
        
        m1 = floor(n/2)
        # partial sort, for m1 and m2
        rPsort(rw, n, m1 + 1)
        println(rw)
        if (n % 2 == 0)
            m2 = n - m1 - 1
            rPsort(rw, n, m2 + 1)
            cmad = 3.0 * (rw[m1 + 1] + rw[m2 + 1])
        else
            cmad = 6.0 * rw[m1 + 1]
        end

        if (cmad < 1e-7 * sc)   # effectively zero
            break
        end

        c9 = 0.999 * cmad
        c1 = 0.001 * cmad

        for i in 0:(n - 1)
            r = abs(res[i + 1])

            if (r <= c1)
                rw[i + 1] = 1.0
            elseif (r <= c9)
                rw[i + 1] = (1.0 - (r / cmad)^2)^2
            else
                rw[i + 1] = 0.0
            end
        end

        # m1 = floor(1 + n/2)
        # m2 = n - m1 + 1
        # cmad = 3.0 * (rw[m1 + 1] + rw[m2 + 1])  # 6 median abs resid
        # c9 = 0.999 * cmad
        # c1 = 0.001 * cmad
        # for i in 0:(n - 1)
        #     r = abs(res[i + 1])
        #     if (r <= c1)    # near 0, avoid underflow
        #         rw[i + 1] = 1.0
        #     elseif (r > c9) # near 1, avoid underflow
        #         rw[i + 1] = 0.0
        #     else 
        #         rw[i + 1] = (1.0 - (r / cmad)^2)^2
        #     end
        # end 

        # increment iter
        iter = iter + 1
    end
    return ys
end

"""
```julia
lowess_model(xs, ys, f = 2/3, nsteps = 3, delta = 0.01*(maximum(xs) - minimum(xs)))
```

Return a lowess model which can be used to predict the ordinate corresponding to a new abscissa. Has the same arguments as `lowess`.

# Example
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
"""
function  lowess_model(xs, ys, f = 2/3, nsteps = 3, delta = 0.01*(maximum(xs) - minimum(xs)))
    model = lowess(xs, ys, f, nsteps, delta)
    prediction_model = interpolate(model, BSpline(Linear()))
    prediction_model = scale(prediction_model, range(minimum(xs), stop = maximum(xs), length = length(xs)))    
    return prediction_model
end

function lowess(x::AbstractVector{Int},
    y::AbstractVector{T},
    f::T = 2/3,
    nsteps::Integer = 3,
    delta::T = 0.01*(maximum(x) - minimum(x))) where T <: AbstractFloat
    return lowess(Vector{Float64}(x), y, f, nsteps, delta)
end

function lowess(x::AbstractVector{T},
    y::AbstractVector{Int},
    f::T = 2/3,
    nsteps::Integer = 3,
    delta::T = 0.01*(maximum(x) - minimum(x))) where T <: AbstractFloat
    return lowess(x, Vector{Float64}(y), f, nsteps, delta)
end

function lowess(x::AbstractVector{Int},
    y::AbstractVector{Int},
    f::T = 2/3,
    nsteps::Integer = 3,
    delta::T = 0.01*(maximum(x) - minimum(x))) where T <: AbstractFloat
    return lowess(Vector{Float64}(x), Vector{Float64}(y), f, nsteps, delta)
end
end