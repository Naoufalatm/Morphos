_input = """
defmodule MyModule do
  def run() do
    1 + 2
  end
end

MyModule.run()
"""

# output:
# {:__block__, [],
#   [
#     {:defmodule, [line: 1],
#      [
#        {:__aliases__, [line: 1], [:MyModule]},
#        [
#          do: {:def, [line: 2],
#           [{:run, [line: 2], []}, [do: {:+, [line: 3], [1, 2]}]]}
#        ]
#      ]},
#     {{:., [line: 7], [{:__aliases__, [line: 7], [:MyModule]}, :run]}, [line: 7],
#      []}
#   ]}

_input = """
def run() do
  a = 1
  b = 2
  a + b
end
"""

# output:
# {:def, [line: 1],
#  [
#    {:run, [line: 1], []},
#    [
#      do: {:__block__, [],
#       [
#         {:=, [line: 2], [{:a, [line: 2], nil}, 1]},
#         {:=, [line: 3], [{:b, [line: 3], nil}, 2]},
#         {:+, [line: 4], [{:a, [line: 4], nil}, {:b, [line: 4], nil}]}
#       ]}
#    ]
#  ]}

input = """
IO.inspect((1 + 2) * 3)
"""

input
|> Transpiler.transpile()
|> IO.inspect()

# output:
# {
#   {:., [line: 1], [{:__aliases__, [line: 1], [:IO]}, :inspect]},
#   [line: 1],
#   ["Hello, World!"]
# }
