module StringUnits

export cu, ch, gr, tw, offsetfrom

import Base.Unicode: isgraphemebreak!

"""
    AbstractStringUnit

Abstract superclass of all StringUnit types.
"""
abstract type AbstractStringUnit end


"""
    CodeunitUnit <: AbstractStringUnit

A unit type representing some number of codeunits.
"""
struct CodeunitUnit <: AbstractStringUnit
   index::Int
end

"""
    CharUnit <: AbstractStringUnit

A unit type representing some number of Chars.
"""
struct CharUnit <: AbstractStringUnit
    index::Int
end

"""
    GraphemeUnit <: AbstractStringUnit

A unit type representing some number of [`graphemes`](@extref `Unicode.graphemes`).
"""
struct GraphemeUnit <: AbstractStringUnit
    index::Int
end

"""
    CodeunitUnit <: AbstractStringUnit

A unit type representing a [`textwidth`](@extref).
"""
struct TextWidthUnit <: AbstractStringUnit
    index::Int
end

# Unit-style construction

struct CodeunitUnitMaker end
struct CharUnitMaker end
struct GraphemeUnitMaker end
struct TextWidthUnitMaker end

"""Unit for codeunits: 1cu."""
const cu = CodeunitUnitMaker()
"""Unit for Chars: 1ch."""
const ch = CharUnitMaker()
"""Unit for graphemes: 1gr."""
const gr = GraphemeUnitMaker()
"""Unit for textwidth: 1tw."""
const tw = TextWidthUnitMaker()

Base.:*(i::Int, ::CodeunitUnitMaker) = CodeunitUnit(i)
Base.:*(i::Int, ::CharUnitMaker) = CharUnit(i)
Base.:*(i::Int, ::GraphemeUnitMaker) = GraphemeUnit(i)
Base.:*(i::Int, ::TextWidthUnitMaker) = TextWidthUnit(i)

# OffsetStringUnits

"""
    OffsetStringUnit{B,O} <: AbstractStringUnit

A composite unit type representing some total number of disparate string
units, as applied in order to a given string.
"""
struct OffsetStringUnit{B<:AbstractStringUnit, O<:AbstractStringUnit} <: AbstractStringUnit
    index::B
    offset::O
end

# StringUnitRange
"""
    StringUnitRange{S<:AbstractStringUnit} <: AbstractUnitRange{S}

A range of string units. For efficiency, these should be of the same
type, but `:` will accept disparate StringUnit types as well.
"""
struct StringUnitRange{S<:AbstractStringUnit} <: AbstractUnitRange{S}
    start::S
    stop::S
end

function StringUnitRange(start::S, stop::OffsetStringUnit{I,S}) where {I<:AbstractStringUnit,S<:AbstractStringUnit}
    StringUnitRange(OffsetStringUnit(zero(I), start), stop)
end

function StringUnitRange(start::SR, stop::SP) where {SR<:AbstractStringUnit,SP<:AbstractStringUnit}
    start = StringUnitRange(OffsetStringUnit(start, zero(SP)), OffsetStringUnit(zero(SR), stop))
end

# Operations

function Base.:+(a::SU, b::SU) where {SU<:AbstractStringUnit}
    SU(a.index + b.index)
end

function Base.:+(a::SU, b::Integer) where {SU<:AbstractStringUnit}
    SU(a.index + b)
end

function Base.:+(a::SB, b::SO) where {SB<:AbstractStringUnit,SO<:AbstractStringUnit}
    OffsetStringUnit{SB,SO}(a, b)
end

Base.:+(a::Int, b::CodeunitUnit) = b + a

# Example: 3ch + 2tw + 2tw -> 3ch + 4tw
function Base.:+(a::OffsetStringUnit{SB,SO}, b::SO) where {SB<:AbstractStringUnit, SO<:AbstractStringUnit}
    OffsetStringUnit{SB,SO}(a.index, a.offset + b)
end

function Base.:+(a::Int, b::SU) where {SU<:AbstractStringUnit}
    OffsetStringUnit{CodeunitUnit,SU}(a*cu, b)
end

function Base.:-(a::SU, b::SU) where {SU<:AbstractStringUnit}
    SU(a.index - b.index)
end

function Base.:-(a::SU, b::Integer) where {SU<:AbstractStringUnit}
    SU(a.index - b)
end

function Base.:-(a::SU, b) where {SU<:AbstractStringUnit}
    SU(-a.index)
end

function Base.:*(a::SU, b::SU) where {SU<:AbstractStringUnit}
    SU(a.index * b.index)
end

function Base.:*(::SO, ::SU) where {SO<:OffsetStringUnit,SU<:AbstractStringUnit}
    throw(ArgumentError("Can't multiply StringOffsetUnits"))
end

function Base.:*(::OffsetStringUnit, b::Integer)
    throw(ArgumentError("Can't multiply StringOffsetUnits"))
end

function Base.:*(a::SU, b::Integer) where {SU<:AbstractStringUnit}
    SU(a.index * b)
end

function Base.:÷(a::SU, b::SU) where {SU<:AbstractStringUnit}
    SU(a.index ÷ b.index)
end

function Base.:÷(a::SU, b::Integer) where {SU<:AbstractStringUnit}
    SU(a.index ÷ b)
end

function Base.:÷(::SO, ::SU) where {SO<:OffsetStringUnit,SU<:AbstractStringUnit}
    throw(ArgumentError("Can't divide StringOffsetUnits"))
end

function Base.:÷(::OffsetStringUnit, b::Integer)
    throw(ArgumentError("Can't divide StringOffsetUnits"))
end

function Base.:%(a::SU, b::SU) where {SU<:AbstractStringUnit}
    SU(a.index % b.index)
end

function Base.:%(a::SU, b::Integer) where {SU<:AbstractStringUnit}
    SU(a.index % b)
end

function Base.:%(::SO, ::SU) where {SO<:OffsetStringUnit,SU<:AbstractStringUnit}
    throw(ArgumentError("Can't take remainder of StringOffsetUnits"))
end

function Base.:%(::OffsetStringUnit, b::Integer)
    throw(ArgumentError("Can't take remainder of StringOffsetUnits"))
end

Base.isless(a::SU, b::SU) where {SU<:AbstractStringUnit} = a.index < b.index
Base.isless(::OffsetStringUnit, ::AbstractStringUnit) = throw(ArgumentError("can't compare lengths for offset string units"))
Base.isless(::AbstractStringUnit, ::OffsetStringUnit) = throw(ArgumentError("can't compare lengths for offset string units"))
Base.isless(::OffsetStringUnit, ::OffsetStringUnit) = throw(ArgumentError("can't compare lengths for offset string units"))
function Base.isless(a::SU, b::SV) where {SU<:AbstractStringUnit, SV<:AbstractStringUnit}
    throw(ArgumentError("can't compare lengths of $SU and $SV"))
end

Base.:(==)(a::SU, b::SU) where {SU<:AbstractStringUnit} = a.index == b.index
Base.:(==)(a::OffsetStringUnit{I,O}, b::OffsetStringUnit{I,O}) where {I,O} = a.index == b.index && a.offset == b.offset

Base.one(::Union{T,Type{T}}) where {T<:AbstractStringUnit} = T(1)
Base.oneunit(::Union{T,Type{T}}) where {T<:AbstractStringUnit} = T(1)
function Base.one(::Union{OffsetStringUnit{B,O},Type{OffsetStringUnit{B,O}}}) where {B<:AbstractStringUnit, O<:AbstractStringUnit}
    OffsetStringUnit(zero(B), one(O))
end
Base.oneunit(::Union{SO,Type{SO}}) where {SO<:OffsetStringUnit} = one(SO)

Base.zero(::Union{T,Type{T}}) where {T<:AbstractStringUnit} = T(0)
function Base.zero(::Union{OffsetStringUnit{B,O},Type{OffsetStringUnit{B,O}}}) where {B<:AbstractStringUnit, O<:AbstractStringUnit}
    OffsetStringUnit(zero(B), zero(O))
end
Base.typemin(::Union{T,Type{T}}) where {T<:AbstractStringUnit} = zero(T)

Base.:(:)(a::AbstractStringUnit, b::AbstractStringUnit) = StringUnitRange(a,b)
Base.:(:)(a::AbstractStringUnit, b::Int) = StringUnitRange(a,CodeunitUnit(b))
Base.:(:)(a::Int, b::AbstractStringUnit) = StringUnitRange(CodeunitUnit(a), b)

Base.eltype(::Union{T,Type{T}}) where {T<:StringUnitRange{S}} where {S} = S
Base.eltype(::Union{T,Type{T}}) where {T<:StringUnitRange{S}} where {S<:OffsetStringUnit{B,I}} where {B,I} = I

function Base.getindex(str::AbstractString, unit::SU) where {SU<:AbstractStringUnit}
    partforoffset(SU, str, offsetfrom(str, unit))
end

function Base.getindex(str::AbstractString, unit::OffsetStringUnit{I,O}) where {I<:AbstractStringUnit,O<:AbstractStringUnit}
    at = offsetfrom(str, unit)
    partforoffset(O, str, at)
end

function Base.getindex(str::AbstractString, unit::GraphemeUnit)
    grapheme_at(str, offsetfrom(str, unit))
end

function Base.getindex(str::AbstractString, range::StringUnitRange)
    start, stop = @inline indicesfrom(str, range)::Tuple{Int,Int}
    str[start:stop]
end

function Base.maybeview(str::AbstractString, range::StringUnitRange)
    start, stop = @inline indicesfrom(str, range)
    Base.maybeview(str, start:stop)
end

function Base.view(str::AbstractString, range::StringUnitRange)
    Base.maybeview(str, range)
end

# Conversion to offset

"""
    offsetafter(str::AbstractString, offset::Int, unit::AbstractStringUnit)

Obtain the offset/codeunit index `unit` count after `offset`.  String types which
have more efficient ways to calculate a unit offset should define this for their
`AbstractString` subtype.
"""
function offsetafter(::AbstractString, ::Int, unit::AbstractStringUnit)
    error("$(typeof(unit)) <: AbstractStringUnit must define `offsetfrom`")
end

offsetafter(::AbstractString, off::Int, unit::CodeunitUnit) = off + unit.index
offsetafter(str::AbstractString, off::Int, unit::CharUnit) = nextind(str, off, unit.index)

function offsetafter(str::S, off::Int, unit::GraphemeUnit) where {S<:AbstractString}
    @boundscheck off + unit.index ≤ 0 && throw(BoundsError(str, off + unit.index))
    iszero(unit) && return off

    state = Ref{Int32}(0)
    c0 = eltype(S)(0x00000000)
    n = 0
    idx = off
    while true
        idx = nextind(str, idx)
        @boundscheck idx > ncodeunits(str) && throw(BoundsError(str, idx))
        c = str[idx]
        if isgraphemebreak!(state, c0, c)
            n += 1
            n ≥ unit.index && return idx
        end
        c0 = c
    end
end

function offsetafter(str::AbstractString, off::Int, unit::TextWidthUnit)
    # Note: the current implementation of `textwidth` is unsatisfactory: it lacks
    # state entirely, so it gives 2 for 👍 and 4 for 👎🏼.
    # Given that, we judge textwidth on a per-Char basis, rather than generating
    # graphemes and using the string method for textwidth.
    # I've added a test for textwidth to verify the buggy results describe above
    # continue to hold, if those tests ever fail, this can be switched to measure
    # graphemes accordingly.
    @boundscheck off + unit.index ≤ 0 && throw(BoundsError(str, off + unit.index))
    iszero(unit) && return off
    idx = off
    width = 0
    while true
        idx = nextind(str, idx)
        @boundscheck idx > ncodeunits(str) && throw(BoundsError(str, idx))
        width += textwidth(str[idx])
        width ≥ unit.index && return idx
    end
end

function offsetafter(str::AbstractString, off::Int, unit::OffsetStringUnit)
    if iszero(unit.index)
        offsetafter(str, off, unit.offset)
    else
        offsetafter(str, offsetafter(str, off, unit.index), unit.offset)
    end
end

"""
    offsetfrom(str::AbstractString, unit::AbstractStringUnit)
    offsetfrom(str::AbstractString, range::StringUnitRange)

Obtain the native index value or range of the `unit` or `range` for the
given string `str`.  String types which have efficient ways to find this
value should implement [`StringUnits.offsetafter`](@ref), not `offsetfrom`.
"""
offsetfrom(str::AbstractString, unit::AbstractStringUnit) = offsetafter(str, 0, unit)

function offsetfrom(str::AbstractString, range::StringUnitRange)
    start, stop = indicesfrom(str, range)
    start:stop
end

function partforoffset(::Type{CodeunitUnit}, str::AbstractString, idx::Int)
    codeunit(str, idx)
end

function partforoffset(::Type{GraphemeUnit}, str::AbstractString, idx::Int)
    grapheme_at(str, idx)
end

function partforoffset(::Type{<:AbstractStringUnit}, str::AbstractString, idx::Int)
    str[idx]
end

function grapheme_at(str::S, i::Integer) where {S<:AbstractString}
    c0 = str[i]
    state = Ref{Int32}(0)
    n = 0
    idx = i
    while true
        idx = nextind(str, idx)
        idx > ncodeunits(str) && return @views str[i:prevind(str,idx)]
        c = str[idx]
        if isgraphemebreak!(state, c0, c)
            return @views str[i:prevind(str,idx)]
        end
        c0 = c
    end
end

"""
    indicesfrom(str::AbstractString, range::StringUnitRange{S}) where {S}

Return a Tuple `(start, stop)` containing the codeunit range corresponding
to `range`.
"""
function indicesfrom(str::AbstractString, range::StringUnitRange{S}) where {S}
    if eltype(range) == S
        range.stop < range.start && return 1, 0
        start = offsetfrom(str, range.start)
        stop = offsetafter(str, start, range.stop - range.start)
        return start, stop
    else
        start = offsetfrom(str, range.start)
        stop = offsetfrom(str, range.stop)
        if start > stop
            return start, start-1
        else
            return start, stop
        end
    end
end

Base.show(io::IO, idx::CodeunitUnit) = print(io, "$(idx.index)cu")
Base.show(io::IO, idx::CharUnit) = print(io, "$(idx.index)ch")
Base.show(io::IO, idx::GraphemeUnit) = print(io, "$(idx.index)gr")
Base.show(io::IO, idx::TextWidthUnit) = print(io, "$(idx.index)tw")
function Base.show(io::IO, idx::OffsetStringUnit)
    show(io, idx.index)
    print(io, " + ")
    show(io, idx.offset)
end
function Base.show(io::IO, range::StringUnitRange{S}) where {S}
    if S <: OffsetStringUnit
        print(io, "(", range.start, "):(", range.stop, ")")
    else
        print(io, range.start, ":", range.stop)
    end
end

end  # module StringUnits
