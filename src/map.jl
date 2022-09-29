macro map(type, expr)
   @assert isexpr(expr, :braces)
   
   @capture(type, (K_, V_) | (K_ => V_))

   tempvar = gensym()
   pairs = Expr[]
   after = Expr[]
   
   for ex in expr.args
      Mt.@match (ex) begin

         (if (cond_) key_ = value_ end) => begin
            key = isexpr(key, :vect) ?
               esc(first(key.args))  :
               QuoteNode(key)

            value = esc(value)

            push!(after, :(
               if !$(esc(cond))
                  delete!($tempvar, $key)
               end
            ))

            push!(pairs, :( $key => $value ))
         end

         (key_ = value_) => begin
            key = isexpr(key, :vect) ?
               esc(first(key.args))  :
               QuoteNode(key)
            
            value = esc(value)
            push!(pairs, :( $key => $value ))
         end

         (expr_) => error("Expected assign expression, got: $expr")
      end
   end

   dict = isnothing(K) && isnothing(V) ?
      esc(:( Dict )) : esc(:( Dict{$K, $V} ))

   return if isempty(after)
      :( $dict($(pairs...)) )
   else
      quote
         let $tempvar = $dict($(pairs...))
            $(after...)
            $tempvar
         end
      end
   end
end

macro map(expr)
   esc(:(@map () $(expr)))
end