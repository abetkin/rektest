

# defmodule MapDestruct do

#   defmacro __using__(_) do
#     quote do
#       # import Kernel, except: [def: 2]
#       import Macros
#     end
#   end

#   defmacro def(head, {:inject, _, args_list}, body) do
#     args_list |> IO.inspect(label: :body)
#     nil
#   end

#   defmacro def(
#     head,
#     {:when, _line, [inject, con]},
#     body
#   ) do
#     con |> IO.inspect(label: :cond)
#     nil
#   end

# end
