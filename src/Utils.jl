module Utils

using Reexport

@reexport using MacroTools
@reexport using Match

const Mt = MacroTools

export @map
export @singleton


include("map.jl")
include("singleton.jl")

end # moduke
