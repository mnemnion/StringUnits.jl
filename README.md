# StringUnits

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mnemnion.github.io/StringUnits.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mnemnion.github.io/StringUnits.jl/dev/)
[![Build Status](https://github.com/mnemnion/StringUnits.jl/actions/workflows/CI.yml/badge.svg?branch=trunk)](https://github.com/mnemnion/StringUnits.jl/actions/workflows/CI.yml?query=branch%3Atrunk)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

**StringUnits.jl** is a package which provides units for indexing strings: by
codeunit, by character, by grapheme, and by textwidth.

```jldoctest
julia> str = "aλ🤔∅👨🏻‍🌾!"
"aλ🤔∅👨🏻\u200d🌾!"

julia> str[3ch]
'🤔': Unicode U+1F914 (category So: Symbol, other)

julia> str[1cu]
0x61

julia> str[5gr]
"👨🏻\u200d🌾"

julia> str[2ch:4ch]
"λ🤔∅"

julia> str[2ch:5ch + 0gr]
"λ🤔∅👨🏻\u200d🌾"
```

For details, see the [documentation](https://mnemnion.github.io/StringUnits.jl/)