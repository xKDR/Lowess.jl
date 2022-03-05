using Lowess
using Test

@testset "Testing Lowess" begin
    for i in 1:100
        n = rand(6:100)
        xs = rand(1:100.0, n)
        xs = sort(xs)
        ys = rand(1:100.0, n)
        zs = lowess(xs, ys, rand(0.1:1.0), rand(3:10), rand(0.1:1.0))
        @test length(zs) == length(ys)
    end
end

