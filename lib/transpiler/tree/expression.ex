defmodule Transpiler.Tree.Expression do
  defstruct [:arguments, :type, :return_type, :context]

  @moduledoc """
  Defines the `Transpiler.Tree.Expression` struct and functions for parsing Elixir AST
  elements into this struct, as well as generating C code from these expressions.

  An `%Transpiler.Tree.Expression{}` holds:

    - `arguments`: A list or map of sub-expressions or literal values.
    - `type`: The operation or construct this expression represents (e.g., `:+`, `:spawn`, `:varname`).
    - `return_type`: The type inferred for the expression (e.g., `:int`, `:float`, `:bool`, `:string`, `:void`).
    - `context`: A map storing context (e.g., variable bindings).

  ## Examples

      iex> expr = %Transpiler.Tree.Expression{
      ...>   arguments: [1, 2],
      ...>   type: :+,
      ...>   return_type: :int,
      ...>   context: %{}
      ...> }
      iex> Transpiler.Tree.Expression.generate_code(expr)
      "1 + 2"

  These expressions can be parsed from Elixir AST tuples, then subsequently
  translated into C code for further compilation or execution.
  """
  @typedoc """
  A list of basic operators recognized in expressions (without assignment).
  """
  @type ast_elementary_ops() :: :+ | :- | :* | :/ | :< | :> | :== | :!= | :&& | :||
  @typedoc """
  A list of basic operators recognized in expressions, plus the `:=` operator for assignment.
  """
  @type ast_elementary_ops_with_assigment() :: ast_elementary_ops() | :=
  @typedoc """
  Represents keywords for special function constructs, such as `:spawn` or an anonymous function (`:fn`).
  """
  @type ast_elementary_funs() :: :spawn | :fn | nil
  @typedoc """
  Represents literal types recognized by the parser.
  """
  @type literal_type() :: :integer_literal | :float_literal | :boolean_literal | :string_literal

  # arguments are sub-expressions
  # type can be :+, :-, :*, :/, :<, :>, :==, :!=, :&&, :||, :!, :assign, :print
  # return_type can be :int, :float, :bool, :string, :list, :function, :nil

  @doc """
  Parses a binary AST tuple into an expression representing a binary operation,
  such as `+`, `-`, `*`, `/`, `<`, `>`, `==`, `!=`, `&&`, `||`.

  The parsed expression is returned as a `%Transpiler.Tree.Expression{}`.

  ## Parameters

    - `operator_tuple` - An AST tuple, e.g., `{:+, meta, [left, right]}`.
    - `context` - A map containing variable bindings or other information used to infer return types.

  ## Returns

  A `%Transpiler.Tree.Expression{}` struct with:

    - `type` set to the operator (e.g., `:+`).
    - `arguments` set to the parsed left and right expressions.
    - `return_type` inferred based on operands (e.g., `:int` vs. `:float`).
    - `context` carried over from the `context` parameter.

     Parses a tuple representing an assignment, such as `{:=, meta, [{var, _, nil}, right]}`.

  Returns a tuple containing the newly created expression and an updated `context` map
  reflecting the assigned variable.

  ## Parameters

    - `operator_tuple` - An AST tuple representing an assignment (`:=`),
      e.g., `{:=, _, [{:x, _, nil}, right_expr]}`.
    - `context` - A map used to store variable bindings.

  ## Returns

    - A tuple of the form:
      `{ %Transpiler.Tree.Expression{}, updated_context }`

      Where `updated_context` includes the new binding for the assigned variable.

      Parses an Elixir AST tuple representing an `IO.inspect(...)` call into a
  print expression (`:print`).

  ## Examples

      iex> ast = {{:., [], [{:__aliases__, [], [:IO]}, :inspect]}, [], [42]}
      iex> Transpiler.Tree.Expression.parse(ast, %{})
      %Transpiler.Tree.Expression{
        arguments: [%Transpiler.Tree.Expression{type: :integer_literal, ...}],
        type: :print,
        return_type: :void,
        context: %{}
      }

       Parses an AST tuple representing a spawn expression, e.g., `{:spawn, meta, arg_for_spawn}`.

  Internally, it expects an anonymous function (`:fn`) within the `arg_for_spawn`.
  The resulting `%Transpiler.Tree.Expression{}` holds arguments that reference a parsed
  main block of expressions (via `Transpiler.Parser.parse/1`).

  ## Returns

  A `%Transpiler.Tree.Expression{}` struct with:
    - `type: :spawn`
    - `arguments: %{args: block_expressions}`
    - `return_type: :void`
    - `context: context`

    Parses a variable name into a `:varname` expression.

  The variable's `return_type` is derived from the current context.

  ## Returns

    - A tuple `{ %Transpiler.Tree.Expression{}, map }` containing
      the expression and the (unchanged) context.

        Parses an integer literal into an `%Transpiler.Tree.Expression{}` of type `:integer_literal`.
   Parses a float literal into an `%Transpiler.Tree.Expression{}` of type `:float_literal`.
   Parses a boolean value into an `%Transpiler.Tree.Expression{}` of type `:boolean_literal`.
  Parses a binary (string) literal into an `%Transpiler.Tree.Expression{}` of type `:string_literal`.

  Generates C code for a print (`:print`) expression, using `printf`.

  The format string is chosen based on the `return_type` of the expression's argument,
  and the argument's code is generated recursively.

  ## Examples

      iex> expr = %Transpiler.Tree.Expression{
      ...>   type: :print,
      ...>   arguments: [%Transpiler.Tree.Expression{type: :integer_literal, arguments: [42], return_type: :int}],
      ...>   return_type: :void
      ...> }
      iex> Transpiler.Tree.Expression.generate_code(expr)
      "printf(\"%d \\n\", 42)"
      Parses the content of an anonymous function block, producing a snippet of C code
  suitable for embedding in a `lambda(...)` expression used by `:spawn`.

  This creates a `while (1) { ... }` loop around the generated expressions,
  simulating a repeatedly executing thread body.
   Generates C code for a spawn expression, creating a green thread with an anonymous function.

  Uses `parse_anonymous_fun_content/1` to produce the body of the function.

  Generates C code for an assignment expression, using the inferred type (e.g., `int`, `float`, `char`, `char*`)
  to declare the variable.

  ## Examples

      iex> expr = %Transpiler.Tree.Expression{
      ...>   type: :assign,
      ...>   arguments: [:x, %Transpiler.Tree.Expression{type: :integer_literal, arguments: [42], return_type: :int}],
      ...>   return_type: :int
      ...> }
      iex> Transpiler.Tree.Expression.generate_code(expr)
      "int x = 42"

      Generates C code for literal values (integers, floats, booleans).

  Returns the literal as a string (e.g., `"42"`, `"3.14"`, `"true"`).

    Generates C code for string literals, wrapping the value in double quotes.

   Generates C code for a variable name expression.

  Simply returns the variable's name as a string.

   Fallback code generator for a binary operation expression (e.g., `:+`, `:-`, `:*`, `:/`, `:<`, `:>`,
  `:==`, `:!=`, `:&&`, `:||`, `:assign`).

  This function dispatches on `expression.type` to build the appropriate C code,
  recursively generating code for each of the expression's sub-arguments.

  Infers the return type of a binary arithmetic operator (`:+`, `:-`, `:*`, `:/`).

  - If either operand has a type `:float`, the result is `:float`.
  - Otherwise, it's `:int`.

   Infers the return type of logical or comparison operators (`:<`, `:>`, `:==`, `:!=`, `:&&`, `:||`),
  always returning `:bool`.
  """

  @spec parse({ast_elementary_ops(), term(), [integer()]}, map()) :: %Transpiler.Tree.Expression{}
  def parse({operator, _meta, [left, right]}, context)
      when operator in [:+, :-, :*, :/, :<, :>, :==, :!=, :&&, :||] do
    right_expr = parse(right, context)
    left_expr = parse(left, context)

    %__MODULE__{
      arguments: [left_expr, right_expr],
      type: operator,
      return_type: infer_return_type(operator, right_expr.return_type, left_expr.return_type),
      context: context
    }
  end

  @spec parse({ast_elementary_ops_with_assigment(), term(), [term()]}, map()) ::
          {%Transpiler.Tree.Expression{}, map()}
  def parse({:=, _meta, [{varname, _, nil}, right]}, context) do
    right_expr = parse(right, context)

    {%__MODULE__{
       arguments: [varname, right_expr],
       type: :assign,
       return_type: right_expr.return_type,
       ## why ?
       context: context
     }, Map.put(context, varname, right_expr)}
  end

  @spec parse(ast_elementary_ops(), String.t()) :: {%Transpiler.Tree.Expression{}, map()}
  def parse(
        {{:., _, [{:__aliases__, _, [:IO]}, :inspect]}, _, [arg]},
        context
      ) do
    %__MODULE__{
      arguments: [parse(arg, context)],
      type: :print,
      return_type: :void,
      context: context
    }
  end

  # Experimental , creating fun clause
  @spec parse({ast_elementary_funs(), any(), [any()]}, map()) :: %Transpiler.Tree.Expression{}
  def parse(
        {:spawn, _, arg_for_spawn},
        context
      ) do
    {:fn, _, [{:->, _, [_, block_element]}]} = hd(arg_for_spawn)

    %__MODULE__{
      arguments: %{args: Transpiler.Parser.parse(block_element)},
      type: :spawn,
      return_type: :void,
      context: context
    }
  end

  @spec parse({atom(), term(), nil}, map()) :: {%Transpiler.Tree.Expression{}, map()}
  def parse({varname, _meta, nil}, context) do
    %__MODULE__{
      arguments: [varname],
      type: :varname,
      return_type: context[varname].return_type,
      context: context
    }
  end

  @spec parse({atom(), term(), nil}, map()) :: {%Transpiler.Tree.Expression{}, map()}
  def parse(value, context) when is_integer(value) do
    %__MODULE__{
      arguments: [value],
      type: :integer_literal,
      return_type: :int,
      context: context
    }
  end

  @spec parse(float(), map()) :: %Transpiler.Tree.Expression{}
  def parse(value, context) when is_float(value) do
    %__MODULE__{
      arguments: [value],
      type: :float_literal,
      return_type: :float,
      context: context
    }
  end

  @spec parse(bool(), map()) :: %Transpiler.Tree.Expression{}
  def parse(value, context) when is_boolean(value) do
    %__MODULE__{
      arguments: [value],
      type: :boolean_literal,
      return_type: :bool,
      context: context
    }
  end

  @spec parse(binary(), map()) :: %Transpiler.Tree.Expression{}
  def parse(value, context) when is_binary(value) do
    %__MODULE__{
      arguments: [value],
      type: :string_literal,
      return_type: :string,
      context: context
    }
  end


  @spec parse_anonymous_fun_content([%Transpiler.Tree.Expression{}]) :: nonempty_binary()
  defp parse_anonymous_fun_content(anonymous_function_block) do
    "while (1) {#{Enum.map_join(anonymous_function_block.expressions, "    ;\n            ", &Transpiler.Tree.Expression.generate_code(&1))};} \n"
  end


  @spec generate_code(%Transpiler.Tree.Expression{type: :print, arguments: []}) :: String.t()
  def generate_code(%__MODULE__{type: :print, arguments: [value]}) do
    format_string =
      case value.return_type do
        :int -> "%d"
        :float -> "%f"
        :bool -> "%d"
        :string -> "%s"
      end

    ~s[printf("#{format_string} \\n", #{generate_code(value)})]
  end

  # TODO



  @spec generate_code(%Transpiler.Tree.Expression{type: :spawn, arguments: []}) :: String.t()
  def generate_code(%__MODULE__{type: :spawn, arguments: %{args: value}}) do
    ~s[green_thread_create(\n        lambda(void, (void* arg), { \n            #{parse_anonymous_fun_content(value)} }), NULL)]
  end

  @spec generate_code(%Transpiler.Tree.Expression{type: :assign, arguments: [any()]}) ::
          String.t()
  def generate_code(%__MODULE__{type: :assign, arguments: [varname, right_expr]}) do
    type_keyword =
      case right_expr.return_type do
        :int -> "int"
        :float -> "float"
        :bool -> "char"
        :string -> "char*"
      end

    "#{type_keyword} #{varname} = #{generate_code(right_expr)}"
  end

  @spec generate_code(%Transpiler.Tree.Expression{type: literal_type(), arguments: [any()]}) ::
          binary()
  def generate_code(%__MODULE__{type: type, arguments: [value]})
      when type in [:integer_literal, :float_literal, :boolean_literal] do
    "#{value}"
  end

  @spec generate_code(%Transpiler.Tree.Expression{type: literal_type(), arguments: [any()]}) ::
          String.t()
  def generate_code(%__MODULE__{type: :string_literal, arguments: [value]}) do
    ~s["#{value}"]
  end

  @spec generate_code(%Transpiler.Tree.Expression{type: :varname, arguments: [any()]}) ::
          String.t()
  def generate_code(%__MODULE__{type: :varname, arguments: [varname]}) do
    "#{varname}"
  end

  @spec generate_code(%Transpiler.Tree.Expression{}) :: String.t()
  def generate_code(expression) do
    [arg1, arg2] = expression.arguments

    case expression.type do
      :+ -> "#{generate_code(arg1)} + #{generate_code(arg2)}"
      :- -> "#{generate_code(arg1)} - #{generate_code(arg2)}"
      :* -> "(#{generate_code(arg1)}) * (#{generate_code(arg2)})"
      :/ -> "(#{generate_code(arg1)}) / (#{generate_code(arg2)})"
      :< -> "(#{generate_code(arg1)}) < (#{generate_code(arg2)})"
      :> -> "(#{generate_code(arg1)}) > (#{generate_code(arg2)})"
      :== -> "(#{generate_code(arg1)}) == (#{generate_code(arg2)})"
      :!= -> "(#{generate_code(arg1)}) != (#{generate_code(arg2)})"
      :&& -> "(#{generate_code(arg1)}) && (#{generate_code(arg2)})"
      :|| -> "(#{generate_code(arg1)}) || (#{generate_code(arg2)})"
      :assign -> "int #{arg1} = #{generate_code(arg2)}"
    end
  end

  # till we can standarize this types
  @typedoc """
  Temporary (or partial) types used for inference in arithmetic and logical operations.
  Can be `:float`, `:int`, `:bool`, or an `atom()` placeholder.
  """
  @type temp_types() :: :float | :int | :bool | atom()
  @spec infer_return_type(ast_elementary_ops(), temp_types(), temp_types()) :: temp_types()
  defp infer_return_type(operator, left_type, right_type) when operator in [:+, :-, :*, :/] do
    if left_type == :float or right_type == :float do
      :float
    else
      :int
    end
  end

  @spec infer_return_type(ast_elementary_ops(), any(), any()) :: temp_types()
  defp infer_return_type(operator, _, _) when operator in [:<, :>, :==, :!=, :&&, :||], do: :bool
end
