module LowessWrapper

export Rclowess

function tupleDiff(p::Tuple{Float64, Float64})::Float64
    return p[2] - p[1]
end

function Rclowess(
    x::Vector{T},
    y::Vector{T},
    f::T=2/3,
    nsteps::Int=3,
    delta::T=0.01*tupleDiff(extrema(x))
)::Vector{T} where T <: AbstractFloat
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

function Rpsort(x::Vector{T}, n::Int, k::Int) where T <: AbstractFloat
    ccall(
        (:rPsort, "./sharedlib/libRlowess.so"),  # lowess
        Cvoid,   # return type
        (
            Ptr{Cdouble},   # x
            Csize_t,        # n
            Csize_t,        # k
        ),  
        x, n, k
    )
end

end