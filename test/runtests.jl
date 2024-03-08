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

    @testset "Indexing" begin
        @test "abcdαβ👨🏻‍🌾γ"[1gr] == "a"
        @test "abcdαβ👨🏻‍🌾γ"[7gr] == "👨🏻‍🌾"
        @test "abcdαβ👨🏻‍🌾γ"[8gr] == "γ"
        @test "abcdαβ👨🏻‍🌾γ"[1gr] == "a"
        @test "abcd"[3cu] == UInt8('c')
        @test "abcd"[1cu] == UInt8('a')
        @test "abcd"[4cu] == UInt8('d')
        @test_throws BoundsError "abcd"[5cu]
        @test ("abc👍de")[3tw] == 'c'
        @test ("abc👍de")[4tw] == '👍'
        @test ("abc👍de")[5tw] == '👍'
        @test ("abc👍de")[6tw] == 'd'
        ref = "ab👍🏼☝🏽👎🏼"
        @test ref[5gr] == "👎🏼"
        @test ref[1 + 4gr] == "👎🏼"
        @test ref[1 + 3gr] == "☝🏽"
    end

    @testset "Heterogenous Addition" begin
        @test repr(1 + 1gr + 1gr) == "1cu + 2gr"
        @test repr(3 + 1gr + 1tw) == "3cu + 1gr + 1tw"
        @test repr(1gr) == "1gr"
        @test repr(3 + 1cu + 1gr) == "4cu + 1gr"
        @test repr(1tw + 1gr + 1tw + 1ch) == "1tw + 1gr + 1tw + 1ch"
    end
end
