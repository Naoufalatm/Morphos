defmodule Transpiler do
  @moduledoc """
  This is the entry point for the Transpiler
  """

  @doc """
  Function: transpile/2


  ### Description:
  This function is overloaded to handle two types of inputs:

  A binary string containing Elixir code.

  A file path containing Elixir code.

  ### Clauses:


  #### 1. transpile(path, :file)

  ### Arguments:

  path (binary): The path to the file containing Elixir code.

  > :file (atom): Specifies that the input is a file.

  ### Returns:

  > {:ok, term()}: The transpiled output.

  ### Behavior:

  Reads the file specified by the path.

  Extracts the Elixir code and calls transpile/2 with the :binary option.

  ### Implementation:

  ```elixir
  def transpile(path, :file) do
      with {:ok, elixir_code} <- File.read(path) do
         transpile(elixir_code, :binary)
      end
  end
  ```
  #### 2. transpile(elixir_code, :binary)

  ### Arguments:

  > elixir_code (binary): The Elixir code to be transpiled.

  > :binary (atom): Specifies that the input is a binary string.

  ### Returns:

  > {:ok, term()}: The transpiled output.

  ### Behavior:

  Parses the Elixir code using Code.string_to_quoted!/1.

  Transforms the code using the Transpiler.Parser.parse/1 function.

  Generates the final output with Transpiler.CodeGenerator.generate_code/1.

  ### Implementation:

  ```elixir
  def transpile(elixir_code, :binary) do
  output =
    elixir_code
    |> Code.string_to_quoted!()
    |> Transpiler.Parser.parse()
    |> Transpiler.CodeGenerator.generate_code()

  {:ok, output}
  end
  ```
  ### Implementation Details

  #### File Reading:

  Utilizes File.read/1 to handle file inputs, ensuring robust error handling through the with construct.

  #### Parsing:

  Converts Elixir code into an abstract syntax tree (AST) using Code.string_to_quoted!/1.

  The AST is processed by Transpiler.Parser.parse/1 to extract meaningful transformations.

  ### Code Generation:

  Transpiler.CodeGenerator.generate_code/1 handles the final transformation of the parsed AST into the desired output format.

  ### Example Usage

  #### Example 1: Transpiling a binary string
  ```elixir
  elixir_code = "defmodule Example do\n  def hello, do: IO.puts(\"Hello, world!\")\nend"
  {:ok, output} = transpile(elixir_code, :binary)
  ```
  #### Example 2: Transpiling a file
  ```elixir
  file_path = "example.ex"
  {:ok, output} = transpile(file_path, :file)
  ```
  ### Error Handling

  #### File Reading Errors:
  If the specified file cannot be read, File.read/1 returns an error tuple (e.g., {:error, reason}). This is propagated back to the caller.

  #### Parsing Errors:
  Code.string_to_quoted!/1 raises an exception for invalid Elixir code. Proper input validation is recommended before invoking this function.
  """
  @spec transpile(binary(), atom()) :: {:ok, term()}
  def transpile(elixir_code, type \\ :binary)

  @spec transpile(binary(), atom()) :: {:ok, term()}
  def transpile(path, :file) do
    with {:ok, elixir_code} <- File.read(path) do
      transpile(elixir_code, :binary)
    end
  end

  @spec transpile(binary(), atom()) :: {:ok, term()}
  def transpile(elixir_code, :binary) do
    output =
      elixir_code
      |> Code.string_to_quoted!()
      |> Transpiler.Parser.parse()
      |> Transpiler.CodeGenerator.generate_code()

    {:ok, output}
  end
end
