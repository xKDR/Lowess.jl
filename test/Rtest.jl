using Lowess

@testcase "testing against C" begin
    for i in 1:100
        n = rand(6:100)
        xs = rand(1:100.0, n)
        xs = sort(xs)
        ys = rand(1:100.0, n)
    end 
end 