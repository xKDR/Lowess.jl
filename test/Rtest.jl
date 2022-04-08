include("./R-Wrapper.jl")
include("../src/Lowess.jl")
import .Lowess
import .LowessWrapper
using Distributions
using Test

function rcmp(x::Float64, y::Float64, nalast::Int)::Int
    if (x < y)
        return -1
    end 
    if (x > y)
        return 1
    end 
    return 0
end

function rPsort2(x::Vector{Float64}, lo::Int, hi::Int, k::Int)
    v::Float64 = 0.0
    w::Float64 = 0.0
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

function rPsort(x::Vector{Float64}, n::Int, k::Int)
    rPsort2(x, 1, n, k)
end

# @testset "testing partial sort" begin
#     for i in 1:100
#         n = rand(6:100)
#         k = rand(1:n)
#         c_partial_sort = rand(Uniform(1.0, 100.0), n)
#         partial_sort = copy(c_partial_sort)
#         LowessWrapper.Rpsort(c_partial_sort, n, k - 1)
#         rPsort(partial_sort, n, k)
    
#         @test c_partial_sort == partial_sort
#     end
# end

@testset "testing against C" begin
    for i in 1:100
        n = rand(6:10)
        xs = rand(Uniform(1.0, 100.0), n)
        xs = sort(xs)
        ys = rand(Uniform(1.0, 100.0), n)
        
        f = rand(Uniform(0.1, 1.0))
        nsteps = rand(3:10)
        delta = rand(Uniform(0.0, 1.0))

        R_output = LowessWrapper.Rclowess(xs, ys, f, nsteps, delta)
        output = Lowess.lowess(xs, ys, f, nsteps, delta)
       
        difference = R_output - output
        difference = (x -> abs(x)).(difference)
        @test(maximum(difference) < 1e-10)
        if (maximum(difference) > 10)
            @show(maximum(difference))
            @show(xs, ys, f, nsteps, delta)
            @show(R_output, output)
        end
    end 
end



include("./R-Wrapper.jl")
include("../src/Lowess.jl")
import .Lowess
import .LowessWrapper
using Distributions
xs = [15.361428983354386, 16.70724402403631, 42.09115173426488, 46.797150380796936, 47.8809386839651, 81.9527062494856]
ys = [1.5600927764007515, 21.045822428247593, 96.12348994164263, 12.39346798256919, 97.41279574408354, 85.33955982400067]
xs = Float32.(xs)
ys = Float32.(ys)
f = 0.5101270884305311
f = Float32(f)
nsteps = 6
delta = 0.922503865326734
delta = Float32(delta)

Lowess.lowess(xs, ys, f, nsteps, delta)
LowessWrapper.Rclowess(xs, ys, f, nsteps, delta)
