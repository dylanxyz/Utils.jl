@eval macro $(:macro)(expr)
   if @capture(expr, name_(args__) = body_)
      return :(
         macro $(esc(name))($(esc.(args)...))
            $(esc.(body.args)...)
         end
      )
   else
      error("@macro expects expression of type func(args...) = ...")
   end
end