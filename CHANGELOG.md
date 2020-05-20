## 2.0.0 - TBD

**Breaking Changes**:

- renamed some IDs/groups:
  - graalvm-js -> graal-js
  - quickjs    -> qjs
  - rubies     -> ruby
  - ruby       -> mri
- the GraalVM `js` interpeter is identified as `graal-js` rather than `js`
- the minimum number of rounds for --count is now 2 (anything lower is set to 2)

Other changes:

- add SpiderMonkey (`spidermonkey`)
- add GraalVM's `node` implementation (`graal-node`)
- log the number of rounds for each test in verbose mode
- update the deno version command

## 1.3.0 - 2019-09-11

- bump the default minimum duration from 5s to 10s
- disable the Java tests (javac, java-native) if `java` is installed but
  `javac` isn't
- add [Wren](http://wren.io/)

## 1.2.0 - 2019-07-15

- add -t/--time option to specify the minimum length of time to run tests for
 (default: 5s)
- format the ID -> group table as JSON if the --json option is provided

## 1.1.1 - 2019-07-13

- add [QuickJS](https://bellard.org/quickjs/)
- update deno version command

## 1.1.0 - 2019-02-27

- dump the version of the compiler/interpreter in verbose mode
- fix gcc 4 (hello.c): add missing return value
- update obsolete dmd options

## 1.0.0 - 2019-02-21

- convert the script to a gem and release it
- add tests for Deno, GraalVM JavaScript, Nim, and TruffleRuby
- add --json option to render the results as a JSON array
- add changelog
