defmodule Transpiler.Tree.MainBlock do
  defstruct [:modules, :expressions]

  @moduledoc """
  This module serves as the container data structure that holds expressions
  (i.e. `%Transpiler.Tree.Expression{}`) and generates their eventual string
  representation (in this case, C code).

  The `%Transpiler.Tree.MainBlock{}` struct has:

  - `:modules` — a list of module references (not currently used in this example).
  - `:expressions` — a list of parsed expressions, each of which is
    a `%Transpiler.Tree.Expression{}`.
  """

  # check how to create doc for this type

  @typedoc """
  Represents the basic set of elementary operators recognized by this
  transpiler. Examples include arithmetic, comparison, and logical operators.

  Possible values are:

    - `:+`  (addition)
    - `:-`  (subtraction)
    - `:*`  (multiplication)
    - `:/`  (division)
    - `:<`  (less than)
    - `:>`  (greater than)
    - `:==` (equal to)
    - `:!=` (not equal to)
    - `:&&` (logical AND)
    - `:||` (logical OR)
  """

  @type ast_elementary_ops() :: :+ | :- | :* | :/ | :< | :> | :== | :!= | :&& | :||
  @typedoc """
  Represents a single abstract syntax tree (AST) element. An element can be:

    - A tuple of the form `{operator, meta, children}` where:
      - `operator` is one of the `ast_elementary_ops()`.
      - `meta` is a keyword list containing metadata (e.g., `[line: integer()]`).
      - `children` is a list of more `ast_element()` (sub-branches in the AST).

    - `nil`, indicating the absence of an AST node.
  """
  @type ast_element() ::
          {
            ast_elementary_ops(),
            [
              line: integer()
            ],
            [ast_element()]
          }
          | nil

  @doc """
  Parses a list of AST elements into a `%Transpiler.Tree.MainBlock{}`.

  This function wraps each parsed expression inside a `MainBlock` struct,
  storing them in the `:expressions` field.

  ## Parameters

    - `ast` — A list of AST elements (see `t:ast_element/0`).

  ## Examples

      iex> ast = [
      ...>   {:+, [line: 1], [1, 2]},
      ...>   {:=, [line: 2], [{:x, [line: 2], nil}, 42]}
      ...> ]
      iex> Transpiler.Tree.MainBlock.parse(ast)
      %Transpiler.Tree.MainBlock{
        modules: [],
        expressions: [
          %Transpiler.Tree.Expression{type: :+, ...},
          %Transpiler.Tree.Expression{type: :assign, ...}
        ]
      }

  ## Returns

    - A `%Transpiler.Tree.MainBlock{}` containing the parsed expressions.
    Generates a C `main()` function that wraps the code for all expressions in
  this main block.

  It inserts some preamble code (e.g., `setup_fault_tolerance_signal_handler()`)
  and a final call to `green_thread_run()`. Each expression in `main_block.expressions`
  is converted to C code by calling `Transpiler.Tree.Expression.generate_code/1`.

  ## Parameters

    - `main_block` — The main block containing expressions to render as C code.

  ## Examples

      iex> main_block = %Transpiler.Tree.MainBlock{expressions: [...]}
      iex> IO.puts Transpiler.Tree.MainBlock.generate_code(main_block)
      int main() {
          setup_fault_tolerance_signal_handler();
          /*
          code gets inserted
          */
          ...
          green_thread_run();
          return 0;
      }

  ## Returns

    - A `String.t()` containing the complete C code for the main function.

     Parses a list of AST elements into a list of `%Transpiler.Tree.Expression{}` structs.

  Each AST element is passed to `Transpiler.Tree.Expression.parse/2` along with a
  context map (holding variable bindings and other metadata). The function then
  collects the parsed expressions (and updated context) via `Enum.map_reduce/3`.

  The return value is the list of parsed expressions; the final context is discarded
  in this particular workflow.

  ## Parameters

    - `ast` – A list of AST elements (see `t:ast_element/0`), where each element
      can be a tuple representing an operation or `nil`.

  ## Returns

    - A list of `%Transpiler.Tree.Expression{}` structs.
  """
  @spec parse([ast_element()]) :: %Transpiler.Tree.MainBlock{}
  def parse(ast) do
    %__MODULE__{
      modules: [],
      expressions: parse_expressions(ast)
    }
  end

  @spec generate_code(%Transpiler.Tree.MainBlock{}) :: String.t()
  def generate_code(main_block) do
    """
    int main() {
        setup_fault_tolerance_signal_handler();
        /*
        code get inserted 👇
        */
        #{Enum.map_join(main_block.expressions, "    ;\n    ", &Transpiler.Tree.Expression.generate_code(&1))};
        /*
        code get inserted 👆
        */
        green_thread_run();
        return 0;
    }
    """
  end

  @spec parse_expressions([ast_element]) :: [%Transpiler.Tree.Expression{}]
  defp parse_expressions(ast) do
    {expressions, _} =
      Enum.map_reduce(ast, %{}, fn expression, context ->
        case Transpiler.Tree.Expression.parse(expression, context) do
          {expression, context} ->
            {expression, context}

          expression ->
            {expression, expression.context}
        end
      end)

    expressions
  end
end
