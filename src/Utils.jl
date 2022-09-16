module Utils

using Reexport

@reexport using MacroTools
@reexport using Match

export @map
export @whenx
export @singleton

include("whenx.jl")
include("singleton.jl")
include("map.jl")

end # moduke
