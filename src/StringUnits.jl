module StringUnits

export cu, ch, gr, tw

import Base.Unicode: isgraphemebreak!

"""
    AbstractStringUnit

Abstract superclass of all StringUnit types.
"""
abstract type AbstractStringUnit end

struct CodeunitUnit <: AbstractStringUnit
   index::Int
end

struct CharUnit <: AbstractStringUnit
    index::Int
end

struct GraphemeUnit <: AbstractStringUnit
    index::Int
end

struct TextWidthUnit <: AbstractStringUnit
    index::Int
end

# Unit-style construction

struct CodeunitUnitMaker end
struct CharUnitMaker end
struct GraphemeUnitMaker end
struct TextWidthUnitMaker end

const cu = CodeunitUnitMaker()
const ch = CharUnitMaker()
const gr = GraphemeUnitMaker()
const tw = TextWidthUnitMaker()

Base.:*(i::Int, ::CodeunitUnitMaker) = CodeunitUnit(i)
Base.:*(i::Int, ::CharUnitMaker) = CharUnit(i)
Base.:*(i::Int, ::GraphemeUnitMaker) = GraphemeUnit(i)
Base.:*(i::Int, ::TextWidthUnitMaker) = TextWidthUnit(i)

# OffsetStringUnits

struct OffsetStringUnit{B<:AbstractStringUnit, O<:AbstractStringUnit} <: AbstractStringUnit
    index::B
    offset::O
end

OffsetStringUnit(a::SU, b::SU) where {SU<:AbstractStringUnit} = SU(a + b)

# Operations

function Base.:+(a::SU, b::SU) where {SU<:AbstractStringUnit}
    SU(a.index + b.index)
end

function Base.:+(a::SU, b::Integer) where {SU<:AbstractStringUnit}
    SU(a.index + b)
end

function Base.:+(a::SB, b::SO) where {SB<:AbstractStringUnit,SO<:AbstractStringUnit}
    OffsetStringUnit{SB,SO}(a ,b)
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

function Base.:*(a::SU, b::Integer) where {SU<:AbstractStringUnit}
    SU(a.index * b)
end

function Base.:÷(a::SU, b::SU) where {SU<:AbstractStringUnit}
    SU(a.index ÷ b.index)
end

function Base.:÷(a::SU, b::Integer) where {SU<:AbstractStringUnit}
    SU(a.index ÷ b)
end

function Base.:%(a::SU, b::SU) where {SU<:AbstractStringUnit}
    SU(a.index % b.index)
end

function Base.:%(a::SU, b::Integer) where {SU<:AbstractStringUnit}
    SU(a.index % b)
end

# Conversion to offset

function offsetafter(::AbstractString, ::Int, unit::AbstractStringUnit)
    error("$(typeof(unit)) <: AbstractStringUnit must define `offsetfrom`")
end

offsetafter(::AbstractString, off::Int, unit::CodeunitUnit) = off + unit.index
offsetafter(str::AbstractString, off::Int, unit::CharUnit) = nextind(str, off, unit.index)

function offsetafter(str::S, off::Int, unit::GraphemeUnit) where {S<:AbstractString}
    state = Ref{Int32}(0)
    c0 = eltype(S)(0x00000000)
    n = 0
    idx = off
    while true
        idx = nextind(str, idx)
        idx > ncodeunits(str) && throw(BoundsError(str, idx))
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
    idx = off
    width = 0
    while true
        idx = nextind(str, idx)
        idx > ncodeunits(str) && throw(BoundsError(str, idx))
        width += textwidth(str[idx])
        width ≥ unit.index && return idx
    end
end

function offsetafter(str::AbstractString, off::Int, unit::OffsetStringUnit)
    offsetafter(str, offsetafter(str, off, unit.index), unit.offset)
end

offsetfrom(str::AbstractString, unit::AbstractStringUnit) = offsetafter(str, 0, unit)

function Base.getindex(str::AbstractString, unit::AbstractStringUnit)
    str[offsetfrom(str, unit)]
end

Base.getindex(str::AbstractString, unit::CodeunitUnit) = codeunit(str, offsetfrom(str, unit))

function Base.getindex(str::AbstractString, unit::GraphemeUnit)
    grapheme_at(str, offsetfrom(str, unit))
end

function grapheme_at(str::S, i::Integer) where {S<:AbstractString}
    c0 = str[i]
    state = Ref{Int32}(0)
    n = 0
    idx = i
    while true
        idx = nextind(str, idx)
        idx > ncodeunits(str) && return @views str[i:i]
        c = str[idx]
        if isgraphemebreak!(state, c0, c)
            return @views str[i:prevind(str,idx)]
        end
        c0 = c
    end
end

end  # module StringUnits
