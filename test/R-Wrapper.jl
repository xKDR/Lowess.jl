module LowessWrapper

export Rclowess

function Rclowess(
    x::Vector{Float64},
    y::Vector{Float64},
    f::Float64=2/3,
    nsteps::Int64=3,
    delta::Float64=0.01*tupleDiff(extrema(x))
)::Vector{Float64}
    # variables needed to call lowess
    n::UInt = length(x)
    ys::Vector{Float64} = Vector{Float64}(undef, n)
    rw::Vector{Float64} = Vector{Float64}(undef, n)
    res::Vector{Float64} = Vector{Float64}(undef, n)

    # calling Rclowess from ./Rlowess/Rlowess.c
    ccall(
        (:Rclowess, "./sharedlib/libRlowess.so"),  # lowess
        Cvoid,   # return type
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
        x, y, n, f, nsteps, delta, ys, rw, res
    )
    return ys
end

end 