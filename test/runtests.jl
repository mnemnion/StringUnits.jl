using StringUnits
using Test
using Aqua

@testset "StringUnits.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(StringUnits)
    end

    @testset "Base prerequisites and assumptions" begin
        @test isdefined(Base.Unicode, :isgraphemebreak!)
        @test Base.Unicode.isgraphemebreak!(Ref{Int32}(0), 'a', 'b')
        @test Base.Unicode.isgraphemebreak!(Ref{Int32}(0), '👍', '🏼') == false
        # Detect improvement in textwidth results, so we can use a more
        # accurate grapheme-based comparison should be become so
        @test textwidth("👍") == 2
        @test textwidth("👎🏼") == 4  # Ideally, this is also 2
    end
end
