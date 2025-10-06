# LowEvil

LowEvil inverses the way `eval()` works. Rather than evaluating a string of Ruby code that may contain interpolated variables, LowEvil evaluates Ruby code first then its interpolated variables, before finally running `eval()` on the hard-coded code.

Ruby's `eval()` method is feared but it's useful in some situations:
- Metaprogamming where you're analysing the user's code
- Programming tools where you're evaluating the user's code on their behalf (REPL)
- Because you feel like it

## Problem

- Running large strings of *changeable* code is seen as a security risk
- Errors aren't obvious where they're coming from (line number is relative to the `eval()`)
- When your multiline string is `eval`d and errors it wont tell you which line the error is one:
  > Error: Cannot open "../(eval)" for reading
