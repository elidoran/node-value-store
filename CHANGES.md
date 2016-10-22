
0.3.6 - Released 2016/10/22

1. moved `set()` index check to the top in case `@array` is empty
2. revised `shift()` and `pop()` to work the way I originally intended
3. modified test suite to handle all these changes

0.3.5 - Released 2016/10/22

1. removed default index value of 0 from `set` and `remove`
2. updated `set()` to find key to remove (when it's a remove operation)
3. updated `set()` to return various results depending on actions taken

0.3.4 - Released 2016/10/22

1. fixed `get()` to search when index isn't specified
2. fixed `has()` to search when index isn't specified
3. fixed `source()` to assume the worst and protect against a bad index

0.3.3 - Released 2016/10/22

1. add a newline to `write()` output
2. make JSON pretty printed
3. add `write()` example to README
4. fix checking ini extension
5. accept options to append for a `format` option
6. record the format used to read a new file
7. use recorded format when writing
8. use `fs` to read JSON files instead of `require()` so pathing is right
9. add missing calls to `pop()` and `shift()`
10. resolve paths so stored file path is absolute

0.3.2 - Released 2016/10/22

1. fixed bug in `write()` when accessing options.format the options may be null

0.3.1 - Released 2016/10/22

1. changed .npmignore to ignore both the CHANGES file and the travis file

0.3.0 Released 2016/10/22

1. added `write()` so an object source can be written out to a file

0.1.0 - Released 2016/10/20

1. initial working version with tests
