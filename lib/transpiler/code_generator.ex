defmodule Transpiler.CodeGenerator do
  @moduledoc """
  The `Transpiler.CodeGenerator` module is responsible for generating C code from
  the structured internal representation defined by `Transpiler.Tree.MainBlock`.

  The `Transpiler.Tree.MainBlock` struct represents the main block of code.

  This module defines a single public function, `generate_code/1`, which takes a
  `Transpiler.Tree.MainBlock` struct and produces a corresponding C source code
  string (binary). The output includes standard header imports as well as any
  generated code segments derived from the AST.

  ## Examples

      iex> main_block = %Transpiler.Tree.MainBlock{
      ...>   # fields representing your AST...
      ...> }
      iex> Transpiler.CodeGenerator.generate_code(main_block)
      "#include <stdio.h>
       #include \"obz_scheduler.h\"

       // ... rest of the generated code ...
       "

  ## Returns

  A binary (string) containing the generated C code, ready to be compiled.
  """
  @typedoc """
  Represents the string (binary) containing the generated C code.
  """
  @type generated_c_code() :: binary()

  @doc """
  Generates the final C code as a binary (string) from the given
  `%Transpiler.Tree.MainBlock{}`.

  This function inserts standard C headers, like `stdio.h` and `obz_scheduler.h`,
  and then delegates to `Transpiler.Tree.MainBlock.generate_code/1` to convert
  the `main_block` struct into C source code.

  ## Parameters

    - `main_block` - A `%Transpiler.Tree.MainBlock{}` struct that holds the parsed
      representation of your source code.

  ## Examples

      iex> main_block = %Transpiler.Tree.MainBlock{
      ...>   # fields representing your AST...
      ...> }
      iex> Transpiler.CodeGenerator.generate_code(main_block)
      "#include <stdio.h>
       #include \"obz_scheduler.h\"

       // ... rest of the generated code ...
       "

  ## Returns

  A binary (string) containing the generated C code, ready to be compiled.
  """

  @spec generate_code(%Transpiler.Tree.MainBlock{}) :: generated_c_code()
  def generate_code(main_block) do
    """
    #include <stdio.h>
    #include "obz_scheduler.h"

    #{Transpiler.Tree.MainBlock.generate_code(main_block)}
    """
  end
end
