var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = StringUnits\nDocTestSetup = quote\n    using StringUnits\nend","category":"page"},{"location":"#StringUnits","page":"Home","title":"StringUnits","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"StringUnits.jl is a package offering units for indexing and slicing strings, by codeunit, character, textwidth, and graphemes.","category":"page"},{"location":"","page":"Home","title":"Home","text":"It exports four singletons, cu, ch, tw, and gr, which are used via juxtaposition to create the associated units.","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> ref = \"aβ∅😃🫶🏼!\"\n\"aβ∅😃🫶🏼!\"\n\njulia> ref[2]\n'β': Unicode U+03B2 (category Ll: Letter, lowercase)\n\njulia> ref[2cu]\n0xce\n\njulia> ref[2ch]\n'β': Unicode U+03B2 (category Ll: Letter, lowercase)\n\njulia> ref[3ch]\n'∅': Unicode U+2205 (category Sm: Symbol, math)\n\njulia> ref[4ch]\n'😃': Unicode U+1F603 (category So: Symbol, other)\n\njulia> ref[4tw]\n'😃': Unicode U+1F603 (category So: Symbol, other)\n\njulia> ref[5tw]\n'😃': Unicode U+1F603 (category So: Symbol, other)\n\njulia> ref[5ch]\n'🫶': Unicode U+1FAF6 (category So: Symbol, other)\n\njulia> ref[5gr]\n\"🫶🏼\"","category":"page"},{"location":"","page":"Home","title":"Home","text":"String units of a common type support normal arithmetic for natural numbers.  Meaning that subtraction which would result in a negative value is an error, like dividing by zero.  Julia doesn't use the convention that negative-valued string indices count from the end of the string, so StringUnits doesn't either.","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> 2ch + 4ch\n6ch\n\njulia> 6ch - 2ch\n4ch\n\njulia> 8ch ÷ 2ch\n4ch\n\njulia> 2ch * 4ch\n8ch\n\njulia> 7ch % 3ch\n1ch\n\njulia> 4ch - 6ch\nERROR: DomainError with illegal subtraction 4ch < 6ch:\n[...]\n\njulia> 5ch ÷ 0ch\nERROR: DivideError: integer division error\n[...]","category":"page"},{"location":"#Mixed-Units:-OffsetStringUnit","page":"Home","title":"Mixed Units: OffsetStringUnit","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"When doing arithmetic between a StringUnit and an ordinary Integer, which side of the operation has the StringUnit is significant.  If the Integer is on the right hand side, we decide that the operation should be in terms of the unit:","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> 2gr + 4\n6gr\n\njulia> 6gr - 2\n4gr\n\njulia> 8gr ÷ 2\n4gr\n\njulia> 2gr * 4\n8gr\n\njulia> 7gr % 3\n1gr","category":"page"},{"location":"","page":"Home","title":"Home","text":"However, if the Integer is on the left hand side, we assume it's a native offset into the string, perhaps returned by a regex, findfirst|last, or any number of other functions.","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> 2 + 4gr\n2cu + 4gr\n\njulia> 6 - 2gr\nERROR: MethodError: no method matching -(::Int64, ::StringUnits.GraphemeUnit)\n[...]\n\njulia> 8 ÷ 2gr\nERROR: MethodError: no method matching div(::Int64, ::StringUnits.GraphemeUnit, ::RoundingMode{:ToZero})\n\njulia> 2 * 4gr\nERROR: MethodError: no method matching *(::Int64, ::StringUnits.GraphemeUnit)\n\njulia> 7 % 3gr\nERROR: MethodError: no method matching rem(::Int64, ::StringUnits.GraphemeUnit)","category":"page"},{"location":"","page":"Home","title":"Home","text":"There isn't a coherent interpretation of \"byte offset 8 divided by two graphemes\", nor for multiplication or remainder.","category":"page"},{"location":"","page":"Home","title":"Home","text":"On the other hand, \"byte offset six minus two graphemes\" does have a reasonable interpretation: \"find the index for the grapheme two graphemes before offset six\". This is currently illegal, because implementing negative-valued StringUnits requires unique algorithms for resolving the offset, complicating an already rather complex implementation, especially where graphemes are concerned.  It is a long-term goal of the package to support every combination which makes sense, and that does include negatively-valued offset string types.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Speaking of which, let's take another look at the legal operation from above.","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> 2 + 4gr\n2cu + 4gr","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is a StringUnit of mixed type, an OffsetStringUnit.  Read this as \"the index of the fourth grapheme after the second codeunit\".  The 'raw' byte offset is cast to cu, a CodeunitUnit, because it's expressed in terms of codeunits. Between disparate StringUnit types, the only valid operation is addition.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Units may be mixed (by addition) arbitrarily. The rule is \"we do what makes sense\", and is easier to first illustrate and then explain.","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> 3ch + 4gr\n3ch + 4gr\n\njulia> 3ch + (4ch + 4gr)\n7ch + 4gr\n\njulia> 3ch + 4gr + 4ch\n3ch + 4gr + 4ch","category":"page"},{"location":"","page":"Home","title":"Home","text":"Think of a chain of additions as instructions for finding the associated offset, starting from [1]: \"forward third characters then four graphemes forward\", \"forward three characters, forward four characters, forward four graphemes\", \"forward three characters, forward four graphemes, forward four characters\".","category":"page"},{"location":"","page":"Home","title":"Home","text":"You can see that the second of these can be partially elided to \"forward seven characters\", but the latter can't be simplified in the same way.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Disparate units are supported to an arbitrary degree:","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> 4cu + 3ch + 1cu + 3tw + 8gr + 2ch\n4cu + 3ch + 1cu + 3tw + 8gr + 2ch","category":"page"},{"location":"","page":"Home","title":"Home","text":"There's little to no practical use to such complex chains, but supporting the simple cases means that the complex ones come along for the ride.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The return value of an OffsetStringUnit is that indicated by the final unit in the chain:","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> ref[4ch + 1gr]\n\"🫶🏼\"\n\njulia> ref[4gr + 1ch]\n'🫶': Unicode U+1FAF6 (category So: Symbol, other)\n\njulia> ref[4gr + 1cu]\n0x9f","category":"page"},{"location":"","page":"Home","title":"Home","text":"If you would prefer a different sort of return value at a given index, add a 0-width unit of that type.","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> ref[5ch]\n'🫶': Unicode U+1FAF6 (category So: Symbol, other)\n\njulia> ref[5ch + 0gr]\n\"🫶🏼\"","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is particularly convenient for use with a precalculated base offset.","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> ref[11 + 0gr]\n\"🫶🏼\"","category":"page"},{"location":"#StringUnitRange","page":"Home","title":"StringUnitRange","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"In addition to indexing, StringUnits may be used as ranges, to return a slice or SubString.","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> ref = \"😻🫶🏼😸🫶🏼😹🫶🏼\"\n\"😻🫶🏼😸🫶🏼😹🫶🏼\"\n\njulia> ref[3gr:5gr]\n\"😸🫶🏼😹\"\n\njulia> ref[4ch:5gr]\n\"😸🫶🏼😹\"\n\njulia> ref[4ch:6ch]\n\"😸🫶🏼\"\n\njulia> ref[4ch:7ch]\n\"😸🫶🏼😹\"\n\njulia> ref[1:3gr]\n\"😻🫶🏼😸\"\n\njulia> ref[4ch:3gr]\n\"😸\"\n\njulia> ref[6ch:3gr]\n\"\"\n\njulia> ref[4ch:4ch+3gr]\n\"😸🫶🏼😹🫶🏼\"\n\njulia> typeof(ans)\nString\n\njulia> @view ref[4ch:4ch+3gr]\n\"😸🫶🏼😹🫶🏼\"\n\njulia> typeof(ans)\nSubString{String}","category":"page"},{"location":"","page":"Home","title":"Home","text":"Straightforward enough. Let's take a brief look under the hood.","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> 4ch:5gr\n(4ch + 0gr):(0ch + 5gr)\n\njulia> 4ch:4ch+3gr\n(4ch + 0gr):(4ch + 3gr)\n\njulia> 17:3ch\n(17cu + 0ch):(0cu + 3ch)\n\njulia> 8tw:1tw\n8tw:1tw","category":"page"},{"location":"","page":"Home","title":"Home","text":"One of the things this illustrates is that StringUnitRanges are never simplified, in contrast to the ordinary sort of UnitRange:","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> 5:1\n5:4\n\njulia> isempty(5:1)\ntrue","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is true even when we can statically determine that the span must be empty.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The reasoning is that it's better to have consistent behavior, and for some number of ranges of disparate units, they could describe a slice with contents at one offset of a string, and be empty at a different offset.","category":"page"},{"location":"","page":"Home","title":"Home","text":"StringUnits does fast-path empty units of the same type, since 5gr:3gr will never have contents, and isempty works out of the box on these.  But be cautious: comparison of disparate units isn't supported, so don't call this function on a range without knowing the types of that range.","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> isempty(5tw:1tw)\ntrue\n\njulia> isempty(5tw:7tw)\nfalse\n\njulia> isempty(4ch:3gr)\nERROR: ArgumentError: can't compare lengths for offset string units","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is because isless doesn't support an \"I don't know\" answer.  So even though we can statically determine that 14cu < 3ch is always false, since a Char is at most four bytes wide, we can't say the same for 6cu ≤ 3ch: it's true for emoji and Greek, but not for ASCII.  It would be possible to return missing under these circumstances, but this would more than likely create more problems than just throwing an error for such comparisons.","category":"page"},{"location":"","page":"Home","title":"Home","text":"For the more usual case of homogenous StringUnitRanges, the logic will reuse the count from the start unit, so if you have a very long string and index a range like mylongstring[10000gr:10100gr], getindex will count off 10,000 graphemes, note the offset, count off an additional 100, then return the indicated slice.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The following might be obvious, but is perhaps worth noting anyway: with the exception of cu, all of the StringUnits have O(n) performance on indexing. Ranges of differing units will have to start the count over for the stop range as well.  It would be possible to optimize that case somewhat, but it would greatly add to the complexity of the implementation and is unlikely to be useful to practical programs which employ the package.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Getting better performance is more of a matter of writing an AbstractString subclass with a different structure, and adapting StringUnits to it, a project I happen to be working on.  There's some discussion of how to adapt StringUnits to a custom AbstractString subtype in the docstrings section.","category":"page"},{"location":"#Quirks","page":"Home","title":"Quirks","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"StringUnits is a young package. I've shaken out any number of bugs, and one might fairly expect that more remain.  However, it might also do things one wouldn't expect, especially when playing around with complex chains of disparate units out of curiousity.","category":"page"},{"location":"","page":"Home","title":"Home","text":"It's easy to hit behavior which looks buggy, but is actually a consequence of how Julia deals with indices and ranges. Let's look at some examples.","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> ref = \"🤬!🤬!\"\n\"🤬!🤬!\"\n\njulia> ref[1]\n'🤬': Unicode U+1F92C (category So: Symbol, other)\n\njulia> ref[1:1]\n\"🤬\"\n\njulia> ref[2]\nERROR: StringIndexError: invalid index [2], valid nearby indices [1]=>'🤬', [5]=>'!'\n[...]\n\njulia> ref[1:2]\nERROR: StringIndexError: invalid index [2], valid nearby indices [1]=>'🤬', [5]=>'!'\n[...]\n\njulia> ref[1:5]\n\"🤬!\"\n\njulia> ref[1ch]\n'🤬': Unicode U+1F92C (category So: Symbol, other)\n\njulia> ref[1ch:1ch]\n\"🤬\"\n\njulia> ref[1ch:1ch+1cu]\nERROR: StringIndexError: invalid index [2], valid nearby indices [1]=>'🤬', [5]=>'!'\n[...]\n\njulia> ref[1ch+1cu]\n0x9f\n\njulia> ref[1ch+1cu+0ch]\nERROR: StringIndexError: invalid index [2], valid nearby indices [1]=>'🤬', [5]=>'!'\n[...]","category":"page"},{"location":"","page":"Home","title":"Home","text":"It's tempting to parse 1ch + 1cu as \"the first codeunit after the (end of the) first character\", which would be !, but it's \"one codeunit after the (index of the) first character\", which is in the middle of the 🤬: valid to index as a cu, since you get a byte back, but not valid to index as a ch.  Practical applications of StringUnits are unlikely to run into problems of this sort, because units like 12ch + 5cu + 8gr + 4tw, while they're fun to try out in the REPL, don't really represent indices or ranges which one might be looking for in a real program.","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is in fact an illustration of an advantage which semi-open intervals (which imply zero-based indexing, for reasons Edsger Dijkstra famously explained) have over the closed intervals used in Julia. A string \"🥸!\", from 0 to 5, would be sliced thus to get the nerd out: \"🥸!\"[0:4], and for the bang, \"🥸!\"[4:5]. The way Julia indexes strings, it has to be \"🥸!\"[1:1], because 4 is inside the nerd and 5 includes the bang.  Note also that 4 - 0 is the number of codeunits in Groucho, and 5-4 the number in !, although Julia mitigates this problem entirely by storing the length with the string, so interval maths can be done using sizeof(str), without the performance and security (!) implications of strlen.","category":"page"},{"location":"","page":"Home","title":"Home","text":"However I consider this the correct tradeoff! Julia's scheme makes life a bit harder on complex manipulation code, the sort that gets written into packages, while making life easier on user code, because \"12345\"[3] and \"12345\"[2:3] do what you'd expect.","category":"page"},{"location":"","page":"Home","title":"Home","text":"And now, with StringUnits, you can do \"१२३४५\"[2ch:3ch], or \"1︎⃣2︎⃣3︎⃣4︎⃣5︎⃣\"[2gr:3gr], with the same ease.","category":"page"},{"location":"#Docstrings","page":"Home","title":"Docstrings","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"StringUnits is (probably) not feature-complete, may have bugs, and shouldn't be considered stable in its current form.  The public interface is the exported unit types, which will retain their names and core semantics, but may give different results on a particular string in a later release, if and when we identify bugs in the implementation.  Some operations which throw errors may no longer do so.  Note that any changes in the results given by textwidth will change the values from tw accordingly, improving them in the process, we may hope.","category":"page"},{"location":"","page":"Home","title":"Home","text":"We intend that the functions necessary to implement the AbstractStringUnit interface for specific subtypes of AbstractString will also be considered API, but as yet it's unclear which of these functions is in fact necessary. Rigorous handling of \"bookends\", such as the values in a UnitRange, may require separating offsetafter into two methods.  StringUnits was designed in part for use with a rope package, which is still in development.  Adapting it to that package should provide some insight into which internal functions do in fact need adaptation to allow AbstractString subtypes with more efficient indexing to implement StringUnits using that more efficient indexing.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Note that, so long as they're encoded using UTF-8, existing subtypes of AbstractString should function with StringUnits as-is, with the same level of efficiency, more or less. Strings with an eltype which is not Char will probably not function correctly.  Extending methods will only be useful for those subtypes which provide sublinear performance in indexing for units other than the native byte offset.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [StringUnits]","category":"page"},{"location":"#StringUnits.ch","page":"Home","title":"StringUnits.ch","text":"Unit for Chars: 1ch == CharUnit(1).\n\n\n\n\n\n","category":"constant"},{"location":"#StringUnits.cu","page":"Home","title":"StringUnits.cu","text":"Unit for codeunits: 1cu == CodeunitUnit(1).\n\n\n\n\n\n","category":"constant"},{"location":"#StringUnits.gr","page":"Home","title":"StringUnits.gr","text":"Unit for graphemes: 1gr == GraphemeUnit(1).\n\n\n\n\n\n","category":"constant"},{"location":"#StringUnits.tw","page":"Home","title":"StringUnits.tw","text":"Unit for textwidth: 1tw == TextWidthUnit(!).\n\n\n\n\n\n","category":"constant"},{"location":"#StringUnits.AbstractStringUnit","page":"Home","title":"StringUnits.AbstractStringUnit","text":"AbstractStringUnit\n\nAbstract superclass of all StringUnit types.\n\n\n\n\n\n","category":"type"},{"location":"#StringUnits.CharUnit","page":"Home","title":"StringUnits.CharUnit","text":"CharUnit <: AbstractStringUnit\n\nA unit type representing some number of Chars.\n\n\n\n\n\n","category":"type"},{"location":"#StringUnits.CodeunitUnit","page":"Home","title":"StringUnits.CodeunitUnit","text":"CodeunitUnit <: AbstractStringUnit\n\nA unit type representing some number of codeunits.\n\n\n\n\n\n","category":"type"},{"location":"#StringUnits.GraphemeUnit","page":"Home","title":"StringUnits.GraphemeUnit","text":"GraphemeUnit <: AbstractStringUnit\n\nA unit type representing some number of [graphemes]''(@extref Unicode.graphemes).\n\n\n\n\n\n","category":"type"},{"location":"#StringUnits.OffsetStringUnit","page":"Home","title":"StringUnits.OffsetStringUnit","text":"OffsetStringUnit{B,O} <: AbstractStringUnit\n\nA composite unit type representing some total number of disparate string units, as applied in order to a given string.\n\n\n\n\n\n","category":"type"},{"location":"#StringUnits.StringUnitRange","page":"Home","title":"StringUnits.StringUnitRange","text":"StringUnitRange{S<:AbstractStringUnit} <: AbstractUnitRange{S}\n\nA range of string units. For efficiency, these should be of the same type, but : will accept disparate StringUnit types as well.\n\n\n\n\n\n","category":"type"},{"location":"#StringUnits.TextWidthUnit","page":"Home","title":"StringUnits.TextWidthUnit","text":"CodeunitUnit <: AbstractStringUnit\n\nA unit type representing a [textwidth]''(@extref).\n\n\n\n\n\n","category":"type"},{"location":"#StringUnits.grapheme_at-Union{Tuple{S}, Tuple{S, Integer}} where S<:AbstractString","page":"Home","title":"StringUnits.grapheme_at","text":"grapheme_at(str::S, i::Integer) where {S<:AbstractString}\n\nRetrieve the grapheme at the given offset.\n\n\n\n\n\n","category":"method"},{"location":"#StringUnits.indicesfrom-Union{Tuple{S}, Tuple{AbstractString, StringUnits.StringUnitRange{S}}} where S","page":"Home","title":"StringUnits.indicesfrom","text":"indicesfrom(str::AbstractString, range::StringUnitRange{S}) where {S}\n\nReturn a Tuple (start, stop) containing the codeunit range corresponding to range.\n\n\n\n\n\n","category":"method"},{"location":"#StringUnits.offsetafter-Tuple{AbstractString, Integer, StringUnits.AbstractStringUnit}","page":"Home","title":"StringUnits.offsetafter","text":"offsetafter(str::AbstractString, offset::Integer unit::AbstractStringUnit)\n\nObtain the 'raw' offset/codeunit index unit count after offset.  String types which have more efficient ways to calculate a unit offset should define this for their AbstractString subtype.\n\n\n\n\n\n","category":"method"},{"location":"#StringUnits.offsetfrom-Tuple{AbstractString, StringUnits.AbstractStringUnit}","page":"Home","title":"StringUnits.offsetfrom","text":"offsetfrom(str::AbstractString, unit::AbstractStringUnit)\noffsetfrom(str::AbstractString, range::StringUnitRange)\n\nObtain the native index value or range of the unit or range for the given string str.  String types which have efficient ways to find this value should implement StringUnits.offsetafter, not offsetfrom.\n\n\n\n\n\n","category":"method"},{"location":"#StringUnits.partforoffset-Tuple{Type{<:StringUnits.AbstractStringUnit}, AbstractString, Integer}","page":"Home","title":"StringUnits.partforoffset","text":"partforoffset(::Type{<:AbstractStringUnit}, str::AbstractString, idx::Integer)\n\nRetrieve a \"string part\" of the appropriate type for the StringUnit, at the (byte) offset idx into str.\n\n\n\n\n\n","category":"method"}]
}
