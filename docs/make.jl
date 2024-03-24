using StringUnits
using Documenter

DocMeta.setdocmeta!(StringUnits, :DocTestSetup, :(using StringUnits); recursive=true)

makedocs(;
    modules=[StringUnits],
    authors="Sam Atman <atmanistan@gmail.com> and contributors",
    sitename="StringUnits.jl",
    format=Documenter.HTML(;
        canonical="https://mnemnion.github.io/StringUnits.jl",
        edit_link="trunk",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mnemnion/StringUnits.jl",
    devbranch="trunk",
    branch="gh-pages",
    versions=["stable" => "v^", "v#.#"],
)
