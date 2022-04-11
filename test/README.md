# Running tests

To test the package, follow the usual steps for testing a package via `Pkg`. 

Our tests also include testing the Julia code against the C code in the file `lowess.c`. To run these tests, do the following. 

1. Run the makefile in this directory. 
    
        make 

2. Run `ctest.jl` with the environment in this directory.

        $ julia --project ctest.jl