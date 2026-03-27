# Janga Docs
Janga uses the Stack for all math, if your unfamiliar look it up
everything must have spaces inbetween them unless otherwise shown
variables must be 1 ascii key(if you want good naming then too bad)

## Variables
`define x 0`  - makes a variable x with value 0
`var x num 5 + -> x`  - adds 5 to x and stores it back

## Math
All math is applied to top 2 values in the stack, gets rid of both and stores result at the top of the stack

`num [value]`  - pushes a number onto the stack 
```
+  - add
-  - subtract
*  - multiply
/  - divide
%  - modulo
```
pop - destroys top value in the stack

## Comparisons
!= - not equal
`>` - greater than
#### Comparison Examples
`num 1 num 2 != -> x`  x would equal 1 (not equal)
`num 1 num 2 > -> x`   x would equal 0 (not greater)

## Control Flow
if [var] [value]  - runs block if var equals value
end  - closes an if block
loop [var] [condition type] [condition]  - loops until condition is met
    - loop a num 2
    - loop a var b
check  - goes back to top of loop if condition not met

## Output
print [var]  - prints a variable
printStr [text]|  - prints a string (end with |)
newLine  - prints a new line

## Example (FizzBuzz)
define a 0 //this is a comment//
loop a num 51
    var a num 3 % -> c
    if c 0 printStr fizz| end
    var a num 5 % -> c
    if c 0 printStr buzz| end
    var a num 1 + -> a
    newLine
check
