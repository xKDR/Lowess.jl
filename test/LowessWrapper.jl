module LowessWrapper

export clowess, flowess, Rclowess

"""
    tupleDiff(p)

Function to return the difference p[2] - p[1]

# Arguments

    - p: a pair 

# Returns

    - the difference p[2] - p[1]
"""
function tupleDiff(p::Tuple{Float64, Float64})::Float64
    return p[2] - p[1]
end

"""
    clowess(x, y, f, nsteps, delta)

Julia wrapper for lowess in lowess.c.

# Arguments

    - x: vector of x coordinates
    - y: vector of y coordinates
    - f: amount of smoothing. In the interval (0, 1)
    - nsteps: number of iterations
    - delta: a nonnegative parameter

# Returns

    - ys, the vector of predictions for x
"""
function clowess(
    x::Vector{Float64},
    y::Vector{Float64},
    f::Float64 = 2 / 3,
    nsteps::Int64 = 3,
    delta::Float64 = 0.01 * tupleDiff(extrema(x))
)::Vector{Float64}
    # variables needed to call lowess
    n::UInt = length(x)
    ys::Vector{Float64} = Vector{Float64}(undef, n)
    rw::Vector{Float64} = Vector{Float64}(undef, n)
    res::Vector{Float64} = Vector{Float64}(undef, n)

    # calling lowess from lowess.c
    ccall(
        (:lowess, "./sharedlib/liblowess.so"),  # lowess
        Cint,   # return type
        (
            Ptr{Cdouble},   # x
            Ptr{Cdouble},   # y
            Csize_t,        # n
            Cdouble,        # f
            Csize_t,        # nsteps
            Cdouble,        # delta
            Ptr{Cdouble},   # ys
            Ptr{Cdouble},   # rw
            Ptr{Cdouble}    # res
        ),
        x,
        y,
        n,
        f,
        nsteps,
        delta,
        ys,
        rw,
        res
    )
    return ys
end

end
