function __when(expr, pattern, body, condition=nothing)
   bs = MacroTools.allbindings(pattern)
   pattern = MacroTools.subtb(MacroTools.subor(pattern))
   
   condition = 
      if isnothing(condition) 
         :( !isnothing(env) )
      else
         :( !isnothing(env) && $(esc(condition)) )
      end

   env = :( MacroTools.trymatch($(esc(Expr(:quote, pattern))), $(esc(expr))) )

   return :(
      if begin; env = $env; $(condition); end
         $([:($(esc(b)) = get(env, $(esc(Expr(:quote, b))), nothing)) for b in bs]...)
         $(esc(body))
      end
   )
end


function pushif(a, b)
   while length(a.args) == 3
      a = last(a.args)
   end
   push!(a.args, b)
end
 
"""
`Match` for expressions
"""
macro whenx(expr, exprs)
   @assert isexpr(exprs, :block)
   res     = :()
   cases   = Expr[]
 
   for case in exprs.args
      if @capture(case, pattern_ => body_)
         push!(cases, __when(expr, pattern, body))
      elseif @capture(case, (pattern_, if cond_ end => body_))
         push!(cases, __when(expr, pattern, body, cond))
      end
   end

   res = popfirst!(cases)
   
   foreach(cases) do case
      pushif(res, case)
   end
 
   return quote
      env = nothing
      $(res)
   end
end