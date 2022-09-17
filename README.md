# Utils

My collection of useful utilities for Julia.

## Macros

### @singleton

The `@singleton` macro is like the `object` keyword in kotlin.

```julia
@singleton struct State
   foo
   bar  :: Int
   qux  :: Float64 = 1.0
   path :: String = "foo/bar"
end

println(State.qux == 1.0) # true
println(State.path == "foo/bar") # true
println(State.foo) # Error, State.foo is not initialized

State.foo = :something
State.bar = 0.1f0 # Type Error, State.bar isa Int
State.bar = 1024

println(State.foo == :something) # true
println(State.bar == 1024) # true

foo(::typeof(State)) = println("bar")

foo(State) # bar
```

### @map

Lua table-like syntax for julia dictionaries.

```julia
table = @map {
   a = 1,
   b = 2,
   c = 3,
}

display(table) #=
Dict{Symbol, Int64} with 3 entries:
 :a => 1
 :b => 2
 :c => 3
=#

foo = "foo"

table = @map String => Char {
   [foo] = 'o',
   "bar" = 'c',
}

display(table) #=
Dict{String, Char} with 2 entries:
  "bar" => 'c'
  "foo" => 'o'
=#

cond = 10 > 5

table = @map {
   a = 1,
   b = 2,
   c = 3,
   if (cond) d = 4 end,
   if (!cond) e = 6 end,
}

display(table) #=
Dict{Symbol, Int64} with 4 entries:
  :a => 1
  :b => 2
  :d => 4
  :c => 3
=#

```

### @macro

Use `@macro` for defining macros with short syntax:

```julia
@macro pm(x, y) = :(($x + $y, $x - $y))

println(@pm 4 5) # (9, -1)
```