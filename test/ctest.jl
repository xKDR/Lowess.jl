include("../src/Lowess.jl")
include("./LowessWrapper.jl")
using .Lowess
using .LowessWrapper
using Test

@testset "Testing against C" begin
    for i = 1:1000
        n = rand(6:100)
        xs = unique(sort(rand(1:1000.0, 10000)))[1:n] ./ 77777
        ys = rand(1:1000.0, 10000)[1:n] ./ 777777

        f = rand(1:1000) / 1000
        nsteps = Int(rand(1:5))
        delta = rand(0:1000) / 1000

        @test isequal(
            Lowess.lowess(xs, ys, f, nsteps, delta),
            LowessWrapper.clowess(xs, ys, f, nsteps, delta)
        )
    end
end
