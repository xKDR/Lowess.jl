module Lowess
using Interpolations

export lowess, lowess_model

function min(x::Int64, y::Int64)::Int64
    return ((x < y) ? x : y)
end

function max(x::Int64, y::Int64)::Int64
    return ((x > y) ? x : y)
end

function pow2(x)
    return x*x
end

function pow3(x)
    return x*x*x
end

function fmax(x, y)
    return (x > y ? x : y)
end

function tupleDiff(p::Tuple{Float64, Float64})
    return p[2] - p[1]
end

function lowest(
    x::Vector,
    y::Vector,
    n::Int64, 
    xs,
    ys::Vector,
    ys_pos::Int64, 
    nleft::Int64,
    nright::Int64,
    w::Vector,
    userw::Bool, 
    rw::Vector,
    ok::Vector{Int}
)
    b = 0.0
    c = 0.0
    r = 0.0
    nrt::Int64 = 0

    # Julia indexing starts at 1, so add 1 to all indexes
    range = x[n] - x[1]
    h = fmax(xs - x[nleft + 1], x[nright + 1] - xs)
    h9 = 0.999 * h
    h1 = 0.001 * h

    # compute weights (pick up all ties on right)
    a = 0.0     # sum of weights
    j::Int64 = nleft   # initialize j
    
    for i in nleft:(n - 1)  # i = j at all times
        w[j + 1] = 0.0
        r = abs(x[j + 1] - xs)      # replaced fabs with abs
        if (r <= h9)       # small enough for non-zero weight
            if (r > h1)
                w[j + 1] = pow3(1.0 - pow3(r/h))
            else 
                w[j + 1] = 1.0
            end
            if (userw)
                w[j + 1] = rw[j + 1] * w[j + 1]
            end 
            a += w[j + 1]
        elseif (x[j + 1] > xs)      # get out at first zero wt on right
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

        # make sum of w[j] == 1
        j = nleft
        for i in nleft:nrt      # i = j at all times
            w[j + 1] = w[j + 1] / a

            # increment j
            j = j + 1
        end

        if (h > 0.0)    # use linear fit
            # find weighted center of x values
            j = nleft
            a = 0.0
            for i in nleft:nrt  # i = j at all times
                a += w[j + 1] * x[j + 1]
                
                # increment j
                j = j + 1
            end
            
            b = xs - a

            j = nleft
            c = 0.0
            for i in nleft:nrt  # i = j at all times
                c += w[j + 1] * (x[j + 1] - a) * (x[j + 1] - a)

                # increment j 
                j = j + 1
            end 

            if (sqrt(c) > 0.001 * range)
                # points are spread out enough to compute slope
                b = b/c

                j = nleft
                for i in nleft:nrt  # i = j at all times
                    w[j + 1] = w[j + 1] * (1.0 + b*(x[j + 1] - a))

                    # increment 
                    j = j + 1
                end 
            end 
        end

        j = nleft
        ys[ys_pos + 1] = 0.0
        for i in nleft:nrt  # i = j at all times
            ys[ys_pos + 1] += w[j + 1] * y[j + 1]

            # increment j
            j = j + 1
        end 
    end 
end 

function lowess(
    x::Vector{T},
    y::Vector{T},
    f = 2/3,
    nsteps::Int64 = 3,
    delta = 0.01*(maximum(x) - minimum(x))
) where T <: Real

    # defining needed variables
    n = length(x)
    ys = Vector(undef, n)
    rw = Vector(undef, n)
    res = Vector(undef, n)

    iter = 0
    ok = Vector{Int}(undef, 1)
    # for safety, initialize ok to 0
    ok[1] = 0

    i = 0
    j = 0
    last = 0
    m1 = 0
    m2 = 0
    nleft = 0
    nright = 0
    ns = 0
    d1 = 0.0
    d2 = 0.0
    denom = 0.0
    alpha = 0.0
    cut = 0.0
    cmad = 0.0
    c9 = 0.0
    c1 = 0.0
    r = 0.0

    if (n < 2)
        ys[1] = y[1]
        return ys
    end 

    ns = max(min(floor(Int64, f*n), n), 2)  # at least two, at most n points
    for iter in 1:(nsteps + 1)  # robustness iterations
        nleft = 0
        nright = ns - 1
        last = -1   # index of prev estimated point
        i = 0   # index of current point

        while true 
            while (nright < n - 1)
                # move nleft, nright to right if radius decreases
                d1 = x[i + 1] - x[nleft + 1]
                d2 = x[nright + 2] - x[i + 1]
                # if d1 <= d2 with x[nright + 2] == x[nright + 1], lowest fixes
                if (d1 <= d2)
                    break
                end
                # radius will not decrease by move right
                nleft = nleft + 1;
	            nright = nright + 1;
            end

            lowest(x, y, n, x[i + 1], ys, i, nleft, nright, res, (iter > 1), rw, ok)

            # fitted value at x[i]
            if (ok == 0)
                ys[i + 1] = y[i + 1]
            end 

            # all weights zero - copy over value (all rw==0)
            if (last < i - 1)   # skipped points -- interpolate
                denom = x[i + 1] - x[last + 1]  # non-zero - proof?
                j = last + 1
                for t in (last + 1):(i - 1) # t = j at all times
                    alpha = (x[j + 1] - x[last + 1]) / denom
                    ys[j + 1] = alpha * ys[i + 1] + (1.0 - alpha) * ys[last + 1]

                    # increment j
                    j = j + 1
                end 
            end 

            last = i    # last point actually estimated
            cut = x[last + 1] + delta   # x coord of close points

            # find close points
            i = last + 1
            for t in (last + 1):(n - 1) # t = i at all times
                if (x[i + 1] > cut) # i one beyond last pt within cut
                    break
                end 
                
                if (x[i + 1] == x[last + 1])
                    ys[i + 1] = ys[last + 1]
                    last = i
                end 

                # increment i
                i = i + 1
            end
            i = max(last + 1,i - 1)
            
            # back 1 point so interpolation within delta, but always go forward
            # check do while loop condition
            (last < n - 1) || break
        end
        
        # residuals
        for i in 0:(n - 1) 
            res[i + 1] = y[i + 1] - ys[i + 1]
        end
        
        if (iter > nsteps)  # compute robustness weights except last time
            break
        end

        for i in 0:(n - 1)
            rw[i + 1] = abs(res[i + 1])
        end
        
        sort!(rw)

        m1 = Int(floor(1 + n/2))
        m2 = Int(n - m1 + 1)
        cmad = 3.0 * (rw[m1 + 1] + rw[m2 + 1])  # 6 median abs resid
        c9 = 0.999 * cmad
        c1 = 0.001 * cmad
        for i in 0:(n - 1)
            r = abs(res[i + 1])
            if (r <= c1)    # near 0, avoid underflow
                rw[i + 1] = 1.0
            elseif (r > c9) # near 1, avoid underflow
                rw[i + 1] = 0.0
            else 
                rw[i + 1] = pow2(1.0 - pow2(r / cmad))
            end
        end 
    end
    return ys 
end 

function  lowess_model(xs, ys, f = 2/3, nsteps = 3, delta = 0.01*tupleDiff(extrema(xs)))
    model = lowess(xs, ys, f, nsteps, delta)
    prediction_model = interpolate(model, BSpline(Linear()))
    prediction_model = scale(prediction_model, range(extrema(xs)[1], stop = extrema(xs)[2], length = length(xs)))    
    return prediction_model
end

end