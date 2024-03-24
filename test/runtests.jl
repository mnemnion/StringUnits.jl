using StringUnits
import StringUnits: stringunittype
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
        @test_throws DomainError 4gr - 8gr
        @test 4gr - 4gr == 0gr
        @test_throws ArgumentError 4gr < 5cu
        @test_throws ArgumentError 120gr > 2cu  # even though...
    end
    @testset "Bounds Errors" begin
        str = "abc"
        @test_throws BoundsError str[0cu]
        @test_throws BoundsError str[0ch]
        @test_throws BoundsError str[0tw]
        @test_throws BoundsError str[0gr]
        @test_throws BoundsError   str[0cu+0ch+0tw+0gr]
        @test_throws BoundsError str[4cu]
        @test_throws BoundsError str[4ch]
        @test_throws BoundsError str[4tw]
        @test_throws BoundsError str[4gr]
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
        ref = "😻🫶🏼😸🫶🏼😹🫶🏼";
        @test ref[2ch + 0cu + 0ch + 0gr] == "🫶🏼"
        @test ref[2ch + (0cu + 0ch + 0gr)] == "🫶🏼"
    end

    @testset "Comparisons and Identities" begin
        @test iszero(0cu)
        @test iszero(0ch)
        @test iszero(0gr)
        @test iszero(0tw)
        @test iszero(0tw + 0gr)
        @test zero(1cu) == 0cu
        @test zero(1ch) == 0ch
        @test zero(1gr) == 0gr
        @test zero(1tw) == 0tw
        @test one(5cu) == 1cu
        @test one(5ch) == 1ch
        @test one(5tw) == 1tw
        @test one(5gr) == 1gr
        @test one(1cu + 5gr) == 0cu + 1gr
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

    @testset "Slicing and Length" begin
        # H̸̡̪̯ͨ͊̽̅̾̎Ȩ̬̩̾͛ͪ̈́̀́͘ ̶̧̨̱̹̭̯ͧ̾ͬC̷̙̲̝͖ͭ̏ͥͮ͟Oͮ͏̮̪̝͍M̲̖͊̒ͪͩͬ̚̚͜Ȇ̴̟̟͙̞ͩ͌͝S̨̥̫͎̭ͯ̿̔̀ͅ
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
        @test ref[2tw+2ch:4ch+2gr] == "dȧ̶̢̧̡̧̢̨̡̨̢̧̨̨̢̛̛̛̛̟̤̭̞̙̘̜̫͖̠͍̠̙̹̻͙͕̯̭͕̞̰͖̮̟̮͙̠̙̹̤̖͖̟̜̣̠̜̜̠̜̤̦̪͖̺͓̠͉̘̩̠̯̖͙̦̙̖͖͚̥̳̗͕͈̦͎̻͈̞͉̰͖̦̟̿̂̒͛̎̏͋̌̔̌̀̽́̎̑̊̐͛̊͋͆̀͒̈̄͂̑̉̌̀́͆̎͛̋͒̆̐̔́̊̄͐̑̓̍̽̊̀́̓̅̾̍͐̆̿͛̾̉̒̈̃̽͛́͗͗̇̈̔̄̂͒̌̿̍̉̐̒̒͑̀̇̽̇̌̅̒̚̕̕͜͝͝͠ͅ💬"
        @test ref[2tw+2ch:2tw+2ch+2gr] == "dȧ̶̢̧̡̧̢̨̡̨̢̧̨̨̢̛̛̛̛̟̤̭̞̙̘̜̫͖̠͍̠̙̹̻͙͕̯̭͕̞̰͖̮̟̮͙̠̙̹̤̖͖̟̜̣̠̜̜̠̜̤̦̪͖̺͓̠͉̘̩̠̯̖͙̦̙̖͖͚̥̳̗͕͈̦͎̻͈̞͉̰͖̦̟̿̂̒͛̎̏͋̌̔̌̀̽́̎̑̊̐͛̊͋͆̀͒̈̄͂̑̉̌̀́͆̎͛̋͒̆̐̔́̊̄͐̑̓̍̽̊̀́̓̅̾̍͐̆̿͛̾̉̒̈̃̽͛́͗͗̇̈̔̄̂͒̌̿̍̉̐̒̒͑̀̇̽̇̌̅̒̚̕̕͜͝͝͠ͅ💬"
        @test ref[4ch:4ch + 1gr] == "dȧ̶̢̧̡̧̢̨̡̨̢̧̨̨̢̛̛̛̛̟̤̭̞̙̘̜̫͖̠͍̠̙̹̻͙͕̯̭͕̞̰͖̮̟̮͙̠̙̹̤̖͖̟̜̣̠̜̜̠̜̤̦̪͖̺͓̠͉̘̩̠̯̖͙̦̙̖͖͚̥̳̗͕͈̦͎̻͈̞͉̰͖̦̟̿̂̒͛̎̏͋̌̔̌̀̽́̎̑̊̐͛̊͋͆̀͒̈̄͂̑̉̌̀́͆̎͛̋͒̆̐̔́̊̄͐̑̓̍̽̊̀́̓̅̾̍͐̆̿͛̾̉̒̈̃̽͛́͗͗̇̈̔̄̂͒̌̿̍̉̐̒̒͑̀̇̽̇̌̅̒̚̕̕͜͝͝͠ͅ"
        @test ref[5ch:5ch + 0gr] == "ȧ̶̢̧̡̧̢̨̡̨̢̧̨̨̢̛̛̛̛̟̤̭̞̙̘̜̫͖̠͍̠̙̹̻͙͕̯̭͕̞̰͖̮̟̮͙̠̙̹̤̖͖̟̜̣̠̜̜̠̜̤̦̪͖̺͓̠͉̘̩̠̯̖͙̦̙̖͖͚̥̳̗͕͈̦͎̻͈̞͉̰͖̦̟̿̂̒͛̎̏͋̌̔̌̀̽́̎̑̊̐͛̊͋͆̀͒̈̄͂̑̉̌̀́͆̎͛̋͒̆̐̔́̊̄͐̑̓̍̽̊̀́̓̅̾̍͐̆̿͛̾̉̒̈̃̽͛́͗͗̇̈̔̄̂͒̌̿̍̉̐̒̒͑̀̇̽̇̌̅̒̚̕̕͜͝͝͠ͅ"
        @test ref[1ch + 1tw + 1gr + 1cu:4gr] == "d"
        @test twref[1ch + 2tw + 4cu + 1gr:5gr] == "🤔→"
        @test twref[2ch + 0cu] == 0xf0
        @test twref[2ch + 0cu] isa UInt8
        @test_throws StringIndexError twref[1ch + 2tw:2ch + 1cu]
        @test length(ref, 5gr, 5gr) == 192
        @test length(ref, 1ch, 4ch) == 4
        for i in eachindex(ref)
            @test ref[i] == ref[i + 0ch]
            @test length(ref, 1ch, i + 0ch) == length(@view ref[begin:i])
        end
    end

    @testset "Find previous and next" begin
        ref =  "a👍🏼a👎🏼a👍🏼a👎🏼a"
        ref2 = "a👍a👎a👍a👎a"
        @test findnext('a', ref, 4gr) == 19
        @test ref[19] == 'a'
        @test findprev('a', ref, 8gr) == 28
        @test ref[28] == 'a'
        @test findnext(c -> c == 'a', ref, 4gr) == 19
        @test findprev(c -> c == 'a', ref, 8gr) == 28
        @test findnext(c -> c == 'a', ref2, 6tw) == 11
        @test ref2[11] == 'a'
        @test findprev(c -> c == 'a', ref2, 11tw) == 16
        @test ref2[16] == 'a'
    end
    @testset "StringUnit stringunittype" begin
        @test stringunittype(1cu) == StringUnits.CodeunitUnit
        @test stringunittype(2ch) == StringUnits.CharUnit
        @test stringunittype(3gr) == StringUnits.GraphemeUnit
        @test stringunittype(4tw) == StringUnits.TextWidthUnit
        @test stringunittype(1cu + 3gr) == StringUnits.GraphemeUnit
        @test stringunittype(1:4tw) == StringUnits.TextWidthUnit
        @test stringunittype(1gr:2gr) == StringUnits.GraphemeUnit
        @test stringunittype(1cu+3ch:3tw+4gr) == StringUnits.GraphemeUnit
    end
end