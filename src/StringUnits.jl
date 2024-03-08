module StringUnits

export cu, ch, gr, tw

import Base.Unicode: isgraphemebreak!

"""
    AbstractStringUnit

Abstract superclass of all StringUnit types.
"""
abstract type AbstractStringUnit end

"""
    AbstractOffsetStringUnit <: AbstractStringUnit

Abstract superclass of all OffsetStringUnit types.
"""
abstract type AbstractOffsetStringUnit <: AbstractStringUnit end

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

# Operations

function Base.:+(a::SU, b::SU) where {SU<:AbstractStringUnit}
    SU(a.index + b.index)
end

function Base.:+(a::SU, b::Integer) where {SU<:AbstractStringUnit}
    SU(a.index + b)
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

function offsetafter(str::AbstractString, off::Int, unit::GraphemeUnit)
    state = Ref{Int32}(0)
    n = 0
    c0 = str[off]
    idx = off
    while true
        idx = nextind(str, idx)
        idx > ncodeunits(str) && throw(BoundsError(str, idx))
        c = str[idx]
        if isgraphemebreak!(state, c0, c)
            n += 1
            n == unit.index && return idx
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


offsetfrom(str::AbstractString, unit::AbstractStringUnit) = offsetafter(str, 0, unit)



end  # module StringUnits
