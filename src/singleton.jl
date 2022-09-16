macro singleton(expr::Expr)
   @assert isexpr(expr, :struct)
   @capture(expr, struct name_ fields__ end)

   typename = gensym(name)

   for (i, ex) in enumerate(fields)
      fields[i] = @whenx ex begin
         (field_::type_ = default_) => ( field, type, default )
         field_::type_ => ( field, type, nothing )
         field_  => ( field, :Any, nothing )
         expr_ => error("Invalid struct expression: $expr")
      end
   end

   quote
      mutable struct $(esc(typename))
         $(map(field -> Expr(:(::), field[1], esc(field[2])), fields)...)

         function $(esc(typename))()
            self = new()
            $(filter(!isnothing,
               map(fields) do ((field, type, default))
                  if !isnothing(default)
                     :( self.$(field) = $(esc(default)) )
                  end
               end
            )...)
            return self
         end
      end
      
      const $(esc(name)) = $(esc(typename))()
   end
end