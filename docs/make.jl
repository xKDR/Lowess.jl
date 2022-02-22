using Lowess
using Documenter

DocMeta.setdocmeta!(Lowess, :DocTestSetup, :(using Lowess); recursive=true)

makedocs(;
    modules=[Lowess],
    authors="xKDR Forum",
    repo="https://github.com/ayushpatnaikgit/Lowess.jl/blob/{commit}{path}#{line}",
    sitename="Lowess.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ayushpatnaikgit.github.io/Lowess.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ayushpatnaikgit/Lowess.jl",
    devbranch="main",
)
