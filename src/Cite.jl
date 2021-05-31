module Cite

export get_citations

using Pkg
using Bibliography: import_bibtex, export_bibtex, Entry
using DataStructures

function citation_path(pkg)
    bib_path = joinpath(pkg.source, "CITATION.bib")
    if isfile(bib_path)
        bib_path
    end
end

function get_citation(pkg)
    bib_path = citation_path(pkg)
    if !isnothing(bib_path)
        @debug "Reading CITATION.bib for $(pkg.name)"
        try
            import_bibtex(bib_path)
        catch e
            @warn("There was an error reading the CITATION.bib file for $(pkg.name)")
            @debug e
        end
    end
end

"""
    collect_citations()

Collect the citations from all the dependencies in the current environment.
"""
function collect_citations()
    @info "Generating citation report for the current environment"
    deps = Pkg.dependencies()
    citations = DataStructures.OrderedDict{String,Entry}()
    for pkg in values(deps)
        c = get_citation(pkg)
        if !isnothing(c)
            merge!(citations, c)
        end
    end

    return citations
end

function get_citations(;filename="julia_citations.bib")
    citations = collect_citations()
    if isfile(filename)
        @warn "Overwriting $filename"
    end
    export_bibtex(filename, citations)
end

end
