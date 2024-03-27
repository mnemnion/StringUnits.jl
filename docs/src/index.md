```@meta
CurrentModule = StringUnits
DocTestSetup = quote
    using StringUnits
end
```

# StringUnits

**StringUnits.jl** is a package offering units for indexing and slicing strings, by
codeunit, character, textwidth, and graphemes.

It exports four singletons, `cu`, `ch`, `tw`, and `gr`, which are used via
juxtaposition to create the associated units.

```jldoctest stringunits1
julia> ref = "aβ∅😃🫶🏼!"
"aβ∅😃🫶🏼!"

julia> ref[2]
'β': Unicode U+03B2 (category Ll: Letter, lowercase)

julia> ref[2cu]
0xce

julia> ref[2ch]
'β': Unicode U+03B2 (category Ll: Letter, lowercase)

julia> ref[3ch]
'∅': Unicode U+2205 (category Sm: Symbol, math)

julia> ref[4ch]
'😃': Unicode U+1F603 (category So: Symbol, other)

julia> ref[4tw]
'😃': Unicode U+1F603 (category So: Symbol, other)

julia> ref[5tw]
'😃': Unicode U+1F603 (category So: Symbol, other)

julia> ref[5ch]
'🫶': Unicode U+1FAF6 (category So: Symbol, other)

julia> ref[5gr]
"🫶🏼"
```

String units of a common type support normal arithmetic for natural numbers.  Meaning
that subtraction which would result in a negative value is an error, like dividing by
zero.  Julia doesn't use the convention that negative-valued string indices count
from the end of the string, so `StringUnits` doesn't either.  We allow zero units,
for reasons which will become clear shortly.

```jldoctest
julia> 2ch + 4ch
6ch

julia> 6ch - 2ch
4ch

julia> 8ch ÷ 2ch
4ch

julia> 2ch * 4ch
8ch

julia> 7ch % 3ch
1ch

julia> 4ch - 6ch
ERROR: DomainError with illegal subtraction 4ch < 6ch:
[...]

julia> 5ch ÷ 0ch
ERROR: DivideError: integer division error
[...]
```

## Mixed Units: OffsetStringUnit

When doing arithmetic between a `StringUnit` and an ordinary `Integer`, which side
of the operation has the `StringUnit` is significant.  If the `Integer` is on the
right hand side, we decide that the operation should be in terms of the unit:

```jldoctest
julia> 2gr + 4
6gr

julia> 6gr - 2
4gr

julia> 8gr ÷ 2
4gr

julia> 2gr * 4
8gr

julia> 7gr % 3
1gr
```

However, if the Integer is on the left hand side, we assume it's a native offset into
the string, perhaps returned by a regex, `findfirst|last`, or any number of other functions.

```jldoctest
julia> 2 + 4gr
2cu + 4gr

julia> 6 - 2gr
ERROR: MethodError: no method matching -(::Int64, ::StringUnits.GraphemeUnit)
[...]

julia> 8 ÷ 2gr
ERROR: MethodError: no method matching div(::Int64, ::StringUnits.GraphemeUnit, ::RoundingMode{:ToZero})

julia> 2 * 4gr
ERROR: MethodError: no method matching *(::Int64, ::StringUnits.GraphemeUnit)

julia> 7 % 3gr
ERROR: MethodError: no method matching rem(::Int64, ::StringUnits.GraphemeUnit)
```

There isn't a coherent interpretation of "byte offset 8 divided by two graphemes",
nor for multiplication or remainder.

On the other hand, "byte offset six minus two graphemes" does have a reasonable
interpretation: "find the index for the grapheme two graphemes before offset six".
This is currently illegal, because implementing negative-valued StringUnits requires
unique algorithms for resolving the offset, complicating an already rather complex
implementation, especially where graphemes are concerned.  It is a long-term goal of
the package to support every combination which makes sense, and that does include
negatively-valued offset string types.

Speaking of which, let's take another look at the legal operation from above.

```jldoctest
julia> 2 + 4gr
2cu + 4gr
```

This is a StringUnit of mixed type, an `OffsetStringUnit`.  Read this as "the index
of the fourth grapheme after the second codeunit".  The 'raw' byte offset is cast to
`cu`, a `CodeunitUnit`, because it's expressed in terms of codeunits. Between disparate
`StringUnit` types, the only valid operation is addition.

Units may be mixed (by addition) arbitrarily. The rule is "we do what makes sense",
and is easier to first illustrate and then explain.

```jldoctest
julia> 3ch + 4gr
3ch + 4gr

julia> 3ch + (4ch + 4gr)
7ch + 4gr

julia> 3ch + 4gr + 4ch
3ch + 4gr + 4ch
```

Think of a chain of additions as instructions for finding the associated offset, starting from `[1]`: "forward third characters then four graphemes forward", "forward three characters, forward four characters, forward four graphemes", "forward three characters, forward four graphemes, forward four characters".

You can see that the second of these can be partially elided to "forward seven
characters", but the latter can't be simplified in the same way.

!!! note "Abuse of Notation"
    A few of you are squirming in your chairs at this point. Yes, 'addition' of heterogeneous `StringUnits` doesn't commute. Yes, this is abuse of notation.
    Yes, I'm interested in your breakdown of the real analysis of StringUnit
    metrics, including a notation.  No, I won't change StringUnits to use it.
    Yes, I would more-than-likely link to your contribution.

Disparate units are supported to an arbitrary degree:

```jldoctest
julia> 4cu + 3ch + 1cu + 3tw + 8gr + 2ch
4cu + 3ch + 1cu + 3tw + 8gr + 2ch
```

There's little to no practical use to such complex chains, but supporting the simple
cases means that the complex ones come along for the ride.

The return value of an `OffsetStringUnit` is that indicated by the final unit in the chain:

```jldoctest stringunits1
julia> ref[4ch + 1gr]
"🫶🏼"

julia> ref[4gr + 1ch]
'🫶': Unicode U+1FAF6 (category So: Symbol, other)

julia> ref[4gr + 1cu]
0x9f
```

This return value may be determined for any subclass of `AbstractStringUnit` using `StringUnits.stringunittype`:

```jldoctest
julia> StringUnits.stringunittype(1ch)
StringUnits.CharUnit

julia> StringUnits.stringunittype(1ch+1gr)
StringUnits.GraphemeUnit

julia> StringUnits.stringunittype(1ch+1gr:5+1tw)
StringUnits.TextWidthUnit
```

If you would prefer a different sort of return value at a given index, add a 0-width
unit of that type.

```jldoctest stringunits1
julia> ref[5ch]
'🫶': Unicode U+1FAF6 (category So: Symbol, other)

julia> ref[5ch + 0gr]
"🫶🏼"
```

This is particularly convenient for use with an existing base offset.

```jldoctest stringunits1
julia> ref[11 + 0gr]
"🫶🏼"
```

## StringUnitRange

In addition to indexing, `StringUnits` may be used as ranges, to return a slice or SubString.

```jldoctest stringunits2
julia> ref = "😻🫶🏼😸🫶🏼😹🫶🏼"
"😻🫶🏼😸🫶🏼😹🫶🏼"

julia> ref[3gr:5gr]
"😸🫶🏼😹"

julia> ref[4ch:5gr]
"😸🫶🏼😹"

julia> ref[4ch:6ch]
"😸🫶🏼"

julia> ref[4ch:7ch]
"😸🫶🏼😹"

julia> ref[1:3gr]
"😻🫶🏼😸"

julia> ref[4ch:3gr]
"😸"

julia> ref[6ch:3gr]
""

julia> ref[4ch:4ch+3gr]
"😸🫶🏼😹🫶🏼"

julia> typeof(ans)
String

julia> @view ref[4ch:4ch+3gr]
"😸🫶🏼😹🫶🏼"

julia> typeof(ans)
SubString{String}
```

Straightforward enough. Let's take a brief look under the hood.

```jldoctest
julia> 4ch:5gr
(4ch + 0gr):(0ch + 5gr)

julia> 4ch:4ch+3gr
(4ch + 0gr):(4ch + 3gr)

julia> 17:3ch
(17cu + 0ch):(0cu + 3ch)

julia> 8tw:1tw
8tw:1tw
```

One of the things this illustrates is that `StringUnitRange`s are never simplified,
in contrast to the ordinary sort of UnitRange:

```jldoctest
julia> 5:1
5:4

julia> isempty(5:1)
true
```

This is true even when we can statically determine that the span must be empty.

The reasoning is that it's better to have consistent behavior, and for some ranges of
disparate units, they could describe a slice with contents at one offset of a string,
and be empty at a different offset.

`StringUnits` does fast-path empty units of the same type, since `5gr:3gr` will never
have contents, and `isempty` works out of the box on these.  But be cautious:
comparison of disparate units isn't supported, so don't call this function on a range
without knowing the types of that range.

```jldoctest
julia> isempty(5tw:1tw)
true

julia> isempty(5tw:7tw)
false

julia> isempty(4ch:3gr)
ERROR: ArgumentError: can't compare lengths for offset string units
```

This is because `isless` doesn't support an "I don't know" answer.  So even though we
can statically determine that `14cu < 3ch` is always `false`, since a `Char` is at
most four bytes wide, we can't say the same for `6cu ≤ 3ch`: it's true for emoji and
Greek, but not for ASCII.  It would be possible to return `missing` under these
circumstances, but this would more than likely create more problems than just
throwing an error for such comparisons.

For the more usual case of homogenous `StringUnitRange`s, the logic will reuse the
count from the start unit, so if you have a very long string and index a range like
`mylongstring[10000gr:10100gr]`, `getindex` will count off 10,000 graphemes, note the
offset, count off an additional 100, then return the indicated slice.

The following might be obvious, but is perhaps worth noting anyway: with the
exception of `cu`, all of the `StringUnits` have O(n) performance on indexing. Ranges
of differing units will have to start the count over for the stop range as well.  It
would be possible to optimize that case somewhat, but it would greatly add to the
complexity of the implementation and is unlikely to be useful to practical programs
which employ the package.

Getting better performance is more of a matter of writing an `AbstractString`
subclass with a different structure, and adapting `StringUnits` to it, a project I
happen to be working on.  There's some discussion of how to adapt `StringUnits` to a
custom `AbstractString` subtype in the [docstrings](#Docstrings) section.

## Inclusion

StringUnits can be tested for inclusion.

```jldoctest
julia> 3gr ∈ 1gr:5gr
true

julia> 3gr ∈ 1ch:50ch
false

julia> 3ch ∈ 1cu:50ch
false

julia> 3ch + 1gr ∈ 1ch+1gr:10ch+3gr
false
```

This is also conservative, but will always return a `Bool`. The philosophy here is
that a `StringUnitRange` is a range of that unit, not _per se_ a description of a
section of a given `String`.

These behaviors are consistent with Base:

```jldoctest
julia> 5 ∈ "ab5cd"
false

julia> 5 < "five"
MethodError: no method matching isless(::Int64, ::String)
```

Homogenous `StringUnits` may be iterated.  Another description of our implementation
of `in` is that a given `StringUnit` is in a `StringUnitRange` only if iterating that
range will produce that unit.

```jldoctest
julia> [unit for unit in 1gr:10gr]
10-element Vector{StringUnits.GraphemeUnit}:
 1gr
 2gr
 3gr
 4gr
 5gr
 6gr
 7gr
 8gr
 9gr
 10gr
 ```

 This will complain about incomparable lengths if tried on ranges where the concept
 is ill-formed, there being no way to describe the steps in the range `1cu:5gr` or
 the many variations like it.

## Miscellaneous

Methods have been implemented for Base functions which are documented to take a string
and an index.

```jldoctest
julia> ref =  "a👍🏼a👎🏼a👍🏼a👎🏼a"
"a👍🏼a👎🏼a👍🏼a👎🏼a"

julia> ref2 = "a👍a👎a👍a👎a"
"a👍a👎a👍a👎a"

julia> findnext('a', ref, 4gr)
19

julia> findprev('a', ref, 8gr)
28

julia> findnext(c -> c == 'a', ref2, 6tw)
11

julia> findprev(c -> c == 'a', ref2, 11tw)
16

julia> length(ref, 1ch, 4gr)
6

julia> length(ref[1ch:4gr])
6
```

If we missed any, feel free to open an issue.

Custom functions which take a string and an index should be easy to adapt:

```julia
function mystringfn(str::AbstractString, unit::AbstractStringUnit, args...)
    mystringfn(str, StringUnits.offsetfrom(str, unit), args...)
end
```

## Quirks

`StringUnits` is a young package. I've shaken out any number of bugs, and one might
fairly expect that more remain.  However, it might also do things one wouldn't
expect, especially when playing around with complex chains of disparate units out of curiousity.

It's easy to hit behavior which looks buggy, but is actually a consequence of how
Julia deals with indices and ranges. Let's look at some examples.

```jldoctest
julia> ref = "🤬!🤬!"
"🤬!🤬!"

julia> ref[1]
'🤬': Unicode U+1F92C (category So: Symbol, other)

julia> ref[1:1]
"🤬"

julia> ref[2]
ERROR: StringIndexError: invalid index [2], valid nearby indices [1]=>'🤬', [5]=>'!'
[...]

julia> ref[1:2]
ERROR: StringIndexError: invalid index [2], valid nearby indices [1]=>'🤬', [5]=>'!'
[...]

julia> ref[1:5]
"🤬!"

julia> ref[1ch]
'🤬': Unicode U+1F92C (category So: Symbol, other)

julia> ref[1ch:1ch]
"🤬"

julia> ref[1ch:1ch+1cu]
ERROR: StringIndexError: invalid index [2], valid nearby indices [1]=>'🤬', [5]=>'!'
[...]

julia> ref[1ch+1cu]
0x9f

julia> ref[1ch+1cu+0ch]
ERROR: StringIndexError: invalid index [2], valid nearby indices [1]=>'🤬', [5]=>'!'
[...]
```

It's tempting to parse `1ch + 1cu` as "the first codeunit after the (end of the)
first character", which would be `!` (`0x21`), but it's "one codeunit after the
(index of the) first character", which is inside of `🤬`: valid to index as a `cu`,
since you get a byte back, but not valid to index as a `ch`.  Practical applications
of `StringUnits` are unlikely to run into problems of this sort, because units like
`12ch + 5cu + 8gr + 4tw`, while they're fun to try out in the REPL, don't really
represent indices or ranges which one might be looking for in a real program.  Note
that if a composite `StringUnit` tries to measure e.g. characters from an invalid
index, this will throw an error, even in the middle of a chain of offsets. We felt
that cases where this happens are probably erroneous, and that it is therefore more
helpful to surface the error than to silently recalibrate with `thisind` or
`nextind`.

This behavior is also an illustration of an advantage which semi-open intervals
(which imply zero-based indexing, for reasons [Edsger Dijkstra famously
explained](https://www.cs.utexas.edu/users/EWD/transcriptions/EWD08xx/EWD831.html))
have over the closed intervals used in Julia. A string "🥸!", from `0` to `5`, would
be sliced thus to get the nerd out: `"🥸!"[0:4]`, and for the bang, `"🥸!"[4:5]`.
The way Julia indexes strings, it has to be `"🥸!"[1:1]`, because `4` is inside the
nerd and `5` includes the bang.  Note also that `4 - 0` is the number of codeunits in
Groucho, and `5-4` the number in `!`, although Julia mitigates this problem
by storing the length with the string, so interval maths can be done using
`sizeof(str)`, without the performance and security (!) implications of `strlen`.

However I consider this the correct tradeoff! Julia's scheme makes life a bit harder
on complex manipulation code, the sort that gets written into packages, while making
life easier on user code, because `"12345"[3]` and `"12345"[2:3]` do what you'd
expect.

And now, with `StringUnits`, you can do these as well, with the same ease.

```jldoctest
julia> "१२३४५"[2ch:3ch]
"२३"

julia> "1︎⃣2︎⃣3︎⃣4︎⃣5︎⃣"[2gr:3gr]
"2︎⃣3"

julia> length(ans)
4
```

Threw in the length there to demonstrate that, if the output appears incorrect, this
is just a rendering bug.


## Docstrings

`StringUnits` is (probably) not feature-complete, may have bugs, and shouldn't be
considered stable in its current form.  The public interface is the exported unit
types, which will retain their names and core semantics, but may give different
results on a particular string in a later release, if and when we identify bugs in
the implementation.  Some operations which throw errors may no longer do so.  Note
that any changes in the results given by `textwidth` will change the values from `tw`
accordingly, improving them in the process, we may hope.

We intend that the functions necessary to implement the `AbstractStringUnit` interface
for specific subtypes of `AbstractString` will also be considered API, but as yet
it's unclear which of these functions is in fact necessary. Rigorous handling of
"bookends", such as the values in a UnitRange, may require separating `offsetafter`
into two methods.  `StringUnits` was designed in part for use with a
[rope](https://en.wikipedia.org/wiki/Rope_(data_structure)) package, which is still
in development.  Adapting it to that package should provide some insight into which
internal functions do in fact need adaptation to allow `AbstractString` subtypes with
more efficient indexing to implement StringUnits using that more efficient indexing.

Note that, so long as they're encoded using UTF-8, existing subtypes of
`AbstractString` should function with `StringUnits` as-is, with the same level of
efficiency, more or less. Strings with an `eltype` which is not `Char` will probably
not function correctly.  Extending methods will only be useful for those subtypes
which provide sublinear performance in indexing for units other than the native
byte offset.


```@autodocs
Modules = [StringUnits]
```
