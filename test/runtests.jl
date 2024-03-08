using StringUnits
using Test
using Aqua

@testset "StringUnits.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(StringUnits)
    end
    # Write your tests here.
end
