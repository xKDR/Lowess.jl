using Lowess
using Test
using Distributions

@testset "Testing with floating point numbers" begin
    for i = 1:500
        n = rand(6:100)
        xs = rand(Uniform(1.0, 100.0), n)
        xs = sort(xs)
        ys = rand(Uniform(1.0, 100.0), n)
        zs = lowess(xs, ys, rand(Uniform(0.1, 1.0)), rand(3:10), rand(Uniform(0.0, 1.0)))
        @test length(zs) == length(ys)
    end
end

@testset "Testing with integers" begin
    for i = 1:500
        n = rand(6:100)
        xs = rand(1:100, n)
        xs = sort(xs)
        ys = rand(1:100, n)
        zs = lowess(xs, ys, rand(Uniform(0.1, 1.0)), rand(3:10), rand(Uniform(0.0, 1.0)))
        @test length(zs) == length(ys)
    end
end
