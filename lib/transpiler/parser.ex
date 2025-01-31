defmodule Transpiler.Parser do
  @moduledoc """
     The `Transpiler.Parser` module is responsible for converting Elixir AST nodes into
    a more structured internal representation defined by `Transpiler.Tree.MainBlock`.

    In Elixir, AST (Abstract Syntax Tree) structures are typically represented by tuples
    such as `{:__block__, meta, expressions}` or simply Elixir values and structs that
    represent different types of code constructs. This module takes either:

    1. A single expression (`%Transpiler.Tree.Expression{}`),
    2. Or a block of expressions (`{:__block__, _, [%Transpiler.Tree.Expression{}, ...]}`)

    and transforms them into a `%Transpiler.Tree.MainBlock{}`.

    Internally, both the single and block versions delegate the parsing process to
    `Transpiler.Tree.MainBlock.parse/1`, but they differ in how they gather the
    expressions to be passed along.

    ## How It Works

    - **`parse/1` with a block**:
      Receives a tuple that starts with the atom `:__block__`, some metadata, and then
      a list of `Transpiler.Tree.Expression` structs. It extracts these expressions,
      and calls `Transpiler.Tree.MainBlock.parse/1` with the list.

    - **`parse/1` with a single expression**:
      Receives a single `%Transpiler.Tree.Expression{}` struct and calls
      `Transpiler.Tree.MainBlock.parse/1` with a list containing just that one expression.

    This abstraction allows you to transparently handle both multiple expressions in a
    block as well as a lone expression in the same overarching workflow.

    ## Examples

        iex> single_expression = %Transpiler.Tree.Expression{type: :some_ast_node, ...}
        iex> Transpiler.Parser.parse(single_expression)
        %Transpiler.Tree.MainBlock{
          # ...
        }

        iex> block = {:__block__, [], [
        ...>   %Transpiler.Tree.Expression{type: :some_ast_node, ...},
        ...>   %Transpiler.Tree.Expression{type: :another_ast_node, ...}
        ...> ]}
        iex> Transpiler.Parser.parse(block)
        %Transpiler.Tree.MainBlock{
          # ...
        }

    **Note**: The specifics of the resulting `%Transpiler.Tree.MainBlock{}` structure depend
    on your `Transpiler.Tree.MainBlock.parse/1` implementation.

    ## Error Handling

    - Currently, `parse/1` does not handle cases where the input is neither a single
      `%Transpiler.Tree.Expression{}` nor a valid Elixir AST block tuple. If you need
      to handle other cases gracefully, consider adding pattern matches or guard checks.

    ## See Also

    - `Transpiler.Tree.MainBlock.parse/1` – The function that handles the actual parsing logic.
    - `Transpiler.Tree.Expression` – The struct representing individual AST expressions.
  """

  @doc """
  Parses a block of expressions (in Elixir AST form) into a `Transpiler.Tree.MainBlock`.

    This function expects a tuple with the following pattern:
    `{:__block__, any_meta, [%Transpiler.Tree.Expression{}, ...]}`.

    It extracts the list of `Transpiler.Tree.Expression` structs and delegates to
    `Transpiler.Tree.MainBlock.parse/1`.

    ## Examples

        iex> block = {:__block__, [], [%Transpiler.Tree.Expression{...}, %Transpiler.Tree.Expression{...}]}
        iex> Transpiler.Parser.parse(block)
        %Transpiler.Tree.MainBlock{
          # details depend on the parse implementation
        }
  """
  @spec parse(
          {:__block__, any(),
           [
             %Transpiler.Tree.Expression{}
           ]}
        ) ::
          %Transpiler.Tree.MainBlock{}
  def parse({:__block__, _meta, expressions}) do
    Transpiler.Tree.MainBlock.parse(expressions)
  end

  @spec parse(%Transpiler.Tree.Expression{}) :: %Transpiler.Tree.MainBlock{}
  def parse(single_expression) do
    Transpiler.Tree.MainBlock.parse([single_expression])
  end
end
