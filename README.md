# Transpiler

## About The Project : 
Transpiler is a small school projects that transpile a subset of Elixir into a concurent C code that consumes a runtime that was written by us ;

The subset of Elixir contains : 
- defining new variables 
- fn -> _ end anonymous function declaration
- IO.inspect 
- basic rudimentary arithmetic operations 
- spawn , creating green thread

## Getting started with Transpiler 

First fetch the dependencies and compile them : 

``` sh
mix deps.get
mix deps.compile
```

Transpiler uses Escript , that takes as input a file ( .exs elixir script ) and an output directory when it will put the code .
To get started let's write a dummy script called `input.exs`:

``` sh
echo IO.inspect ("Hello from Elixir :) ") > input.exs
```

Then let's compile and generate our Escript binaries :

``` sh
mix escript.build
```

Next let's run the command `transpiler` with our input and specifying the output as a `output/` folder :

``` sh
./transpiler -i input.exs -o ./output
```

If the command succeed you should get a `Successfully transpiled!` message in your stdout .

Let's check our newly generated content :

``` sh
cat ./output/main.c
```

The output should be something like that : 

``` c
#include <stdio.h>
#include "obz_scheduler.h"

int main() {
    setup_fault_tolerance_signal_handler();
    /*
    code get inserted 👇
    */
    printf("%s \n", "Hello from Elixir :)");
    /*
    code get inserted 👆
    */
    green_thread_run();
    return 0;
}
```

Great ! now to run this program , we need to statically compile our rudimentary C runtime ; 

## Compiling the C runtime ( backend ) : 

To compile the backend

``` bash
cd ./src_c
make clean 
make
```

that will generate two new folders : 

``` sh
build/ # generates the build objects ( .o )
lib/ # contains the dynamically and statically linked libraries (.a , .so)
```

In our case we will be concerned mainly by the statically linked case , where we should find our newly compiled library at `/src_c/lib/libobzruntime.a`

## Compiling our sample program with our runtime :

Great ! now we compiled the elixir project , generated our transpiler binary and compiled our statically linked library `libobzruntime.a`, now it's time to finally compile our sample transpiled code `./output/main.c` and run it ! 

To do so :

``` sh
cd .. # go back to root directory 
gcc ./output/main.c ./src_c/lib/libobzruntime.a # compile our app with the statically linked library 
```

If that's succeed , we must find a `a.out` in our root directory .
You can runt it by :

``` sh
./a.out
```

if everything went well you should find this message :

``` text
Hello from Elixir :)
```

