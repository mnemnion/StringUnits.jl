using StringUnits
using Test
using Aqua
import Base.Unicode: graphemes

@testset "StringUnits.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(StringUnits)
    end

    @testset "Base prerequisites and assumptions" begin
        @test isdefined(Base.Unicode, :isgraphemebreak!)
        @test Base.Unicode.isgraphemebreak!(Ref{Int32}(0), 'a', 'b')
        @test Base.Unicode.isgraphemebreak!(Ref{Int32}(0), '👍', '🏼') == false
        # Detect improvement in textwidth results, so we can use a more
        # accurate grapheme-based comparison should it improve.
        @test textwidth("👍") == 2
        @test textwidth("👎🏼") == 4  # Ideally, this is also 2
    end

    @testset "Erroneous Arithmetic" begin
        # These operations lack a coherent meaning, so we define them
        # to throw an error
        @test_throws ArgumentError (4gr) ÷ (3cu)
        @test_throws ArgumentError (4gr) * (3cu)
        @test_throws ArgumentError (4gr) % (3cu)
        @test_throws ArgumentError (4gr + 3cu) ÷ 4
        @test_throws ArgumentError (4gr + 3cu) * 5
        @test_throws ArgumentError (4gr + 3cu) % 5
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
        @test ref[2ch + 1gr] == "👍🏼"
        @test_throws BoundsError ref[0cu]
        @test_throws BoundsError ref[0ch]
        @test_throws BoundsError ref[0gr]
        @test_throws BoundsError ref[0tw]
        @test ref[1cu + 0gr] == ref[0cu + 1gr]
    end

    @testset "Comparisons and Identities" begin
        @test iszero(0cu)
        @test iszero(0ch)
        @test iszero(0gr)
        @test iszero(0tw)
        @test zero(1cu) == 0cu
        @test zero(1ch) == 0ch
        @test zero(1gr) == 0gr
        @test zero(1tw) == 0tw
    end

    @testset "Heterogenous Addition" begin
        @test repr(1 + 1gr + 1gr) == "1cu + 2gr"
        @test repr(3 + 1gr + 1tw) == "3cu + 1gr + 1tw"
        @test repr(1gr) == "1gr"
        @test repr(3 + 1cu + 1gr) == "4cu + 1gr"
        @test repr(1tw + 1gr + 1tw + 1ch) == "1tw + 1gr + 1tw + 1ch"
        @test repr(4tw + 1gr + 3) == "4tw + 4gr"
        @test 4tw + 1gr + 3 == 4tw + 4gr
    end

    @testset "Slicing" begin
        ref = "γδgdȧ̶̢̧̡̧̢̨̡̨̢̧̨̨̢̛̛̛̛̟̤̭̞̙̘̜̫͖̠͍̠̙̹̻͙͕̯̭͕̞̰͖̮̟̮͙̠̙̹̤̖͖̟̜̣̠̜̜̠̜̤̦̪͖̺͓̠͉̘̩̠̯̖͙̦̙̖͖͚̥̳̗͕͈̦͎̻͈̞͉̰͖̦̟̿̂̒͛̎̏͋̌̔̌̀̽́̎̑̊̐͛̊͋͆̀͒̈̄͂̑̉̌̀́͆̎͛̋͒̆̐̔́̊̄͐̑̓̍̽̊̀́̓̅̾̍͐̆̿͛̾̉̒̈̃̽͛́͗͗̇̈̔̄̂͒̌̿̍̉̐̒̒͑̀̇̽̇̌̅̒̚̕̕͜͝͝͠ͅ💬w➔!"
        @test sizeof(ref) == 398
        @test length(ref) == 200
        @test length(graphemes(ref)) == 9
        @test textwidth(ref) == 10
        @test ref[1cu:3cu] == "γδ"
        @test ref[1:3] == ref[1cu:3cu]
        @test ref[1ch:2ch] == "γδ"
        @test ref[1gr:9gr] == "γδgdȧ̶̢̧̡̧̢̨̡̨̢̧̨̨̢̛̛̛̛̟̤̭̞̙̘̜̫͖̠͍̠̙̹̻͙͕̯̭͕̞̰͖̮̟̮͙̠̙̹̤̖͖̟̜̣̠̜̜̠̜̤̦̪͖̺͓̠͉̘̩̠̯̖͙̦̙̖͖͚̥̳̗͕͈̦͎̻͈̞͉̰͖̦̟̿̂̒͛̎̏͋̌̔̌̀̽́̎̑̊̐͛̊͋͆̀͒̈̄͂̑̉̌̀́͆̎͛̋͒̆̐̔́̊̄͐̑̓̍̽̊̀́̓̅̾̍͐̆̿͛̾̉̒̈̃̽͛́͗͗̇̈̔̄̂͒̌̿̍̉̐̒̒͑̀̇̽̇̌̅̒̚̕̕͜͝͝͠ͅ💬w➔!"
        @test ref[4ch:4ch + 2gr] == "dȧ̶̢̧̡̧̢̨̡̨̢̧̨̨̢̛̛̛̛̟̤̭̞̙̘̜̫͖̠͍̠̙̹̻͙͕̯̭͕̞̰͖̮̟̮͙̠̙̹̤̖͖̟̜̣̠̜̜̠̜̤̦̪͖̺͓̠͉̘̩̠̯̖͙̦̙̖͖͚̥̳̗͕͈̦͎̻͈̞͉̰͖̦̟̿̂̒͛̎̏͋̌̔̌̀̽́̎̑̊̐͛̊͋͆̀͒̈̄͂̑̉̌̀́͆̎͛̋͒̆̐̔́̊̄͐̑̓̍̽̊̀́̓̅̾̍͐̆̿͛̾̉̒̈̃̽͛́͗͗̇̈̔̄̂͒̌̿̍̉̐̒̒͑̀̇̽̇̌̅̒̚̕̕͜͝͝͠ͅ💬"
        @test ref[5gr:5gr] == "ȧ̶̢̧̡̧̢̨̡̨̢̧̨̨̢̛̛̛̛̟̤̭̞̙̘̜̫͖̠͍̠̙̹̻͙͕̯̭͕̞̰͖̮̟̮͙̠̙̹̤̖͖̟̜̣̠̜̜̠̜̤̦̪͖̺͓̠͉̘̩̠̯̖͙̦̙̖͖͚̥̳̗͕͈̦͎̻͈̞͉̰͖̦̟̿̂̒͛̎̏͋̌̔̌̀̽́̎̑̊̐͛̊͋͆̀͒̈̄͂̑̉̌̀́͆̎͛̋͒̆̐̔́̊̄͐̑̓̍̽̊̀́̓̅̾̍͐̆̿͛̾̉̒̈̃̽͛́͗͗̇̈̔̄̂͒̌̿̍̉̐̒̒͑̀̇̽̇̌̅̒̚̕̕͜͝͝͠ͅ"
        @test ref[5gr:6gr] == "ȧ̶̢̧̡̧̢̨̡̨̢̧̨̨̢̛̛̛̛̟̤̭̞̙̘̜̫͖̠͍̠̙̹̻͙͕̯̭͕̞̰͖̮̟̮͙̠̙̹̤̖͖̟̜̣̠̜̜̠̜̤̦̪͖̺͓̠͉̘̩̠̯̖͙̦̙̖͖͚̥̳̗͕͈̦͎̻͈̞͉̰͖̦̟̿̂̒͛̎̏͋̌̔̌̀̽́̎̑̊̐͛̊͋͆̀͒̈̄͂̑̉̌̀́͆̎͛̋͒̆̐̔́̊̄͐̑̓̍̽̊̀́̓̅̾̍͐̆̿͛̾̉̒̈̃̽͛́͗͗̇̈̔̄̂͒̌̿̍̉̐̒̒͑̀̇̽̇̌̅̒̚̕̕͜͝͝͠ͅ💬"
        @test ref[5gr:4gr] == ""
        @test ref[1tw:4tw] == "γδgd"
        twref = "δ🤬w🤔→🥹!"
        @test textwidth(twref) == 10
        @test twref[1tw:2tw] == "δ🤬"
        @test twref[2tw:2tw] == "🤬"
        @test twref[1tw:10tw] == "δ🤬w🤔→🥹!"
        @test twref[3tw:2tw] == ""
    end
end
