# startup-time

[![Build Status](https://travis-ci.org/chocolateboy/startup-time.svg)](https://travis-ci.org/chocolateboy/startup-time)
[![Gem Version](https://img.shields.io/gem/v/startup-time.svg)](https://rubygems.org/gems/startup-time)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [NAME](#name)
- [USAGE](#usage)
- [INSTALLATION](#installation)
- [DESCRIPTION](#description)
  - [Why?](#why)
  - [Example Output](#example-output)
- [PREREQUISITES](#prerequisites)
- [Further Reading](#further-reading)
- [See Also](#see-also)
- [Author](#author)
- [Version](#version)
- [Copyright and License](#copyright-and-license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## NAME

startup-time - a command-line benchmarking tool which measures the startup times of programs in various languages

## USAGE

```sh
# run all available tests
$ startup-time

# only run the "fast" tests
$ startup-time --only fast

# run all but the "slow" tests
$ startup-time --omit slow

# only run the JVM tests (e.g. Java, Scala etc.)
$ startup-time --only jvm

# only run tests which finish quickly
$ startup-time --only fast --omit slow-compile

# increase the number of times each test is run (default: 10)
$ startup-time --rounds 100
```

## INSTALLATION

```sh
$ gem install startup-time
```

## DESCRIPTION

A command-line tool which measures how long it takes to execute ["Hello, world!"](https://en.wikipedia.org/wiki/%22Hello,_World!%22_program) programs written in various languages. It records the fastest time for each program and prints a sorted table of the times after each run. Apart from the [prerequisites](#prerequisites) listed below, the tool doesn't require any of the tested languages to be installed: if a compiler/interpreter is not available, the test is skipped.

### Why?

To determine which languages are practical (or impractical) to use for command-line interface (CLI) programs. Anything under
[100 milliseconds](https://www.nngroup.com/articles/response-times-3-important-limits/) is perceived as instantaneous. Anything over that is perceived as delayed, which can tangibly impair productivity and flow, and even risk breaking the user's train of thought.

### Example Output

    Test                  Time (ms)
    C (gcc)                    0.33
    Nim                        0.45
    LuaJIT                     0.62
    Rust                       0.63
    Kotlin Native (konan)      0.66
    Go                         0.75
    Lua                        1.00
    Haskell (GHC)              1.17
    C++ (g++)                  1.24
    Perl                       1.75
    Java Native (GraalVM)      1.95
    Crystal                    2.20
    Bash                       3.37
    JavaScript (Deno)         11.18
    Python 3                  26.41
    JavaScript (GraalVM)      35.58
    Java                      56.40
    Python 2                  57.00
    JavaScript (Node.js)      71.61
    Ruby                      77.30
    Ruby (TruffleRuby)        91.28
    Kotlin                   103.02
    Scala                    801.21

## PREREQUISITES

- Ruby >= 2.4

## Further Reading

- [Response Times: The 3 Important Limits](https://www.nngroup.com/articles/response-times-3-important-limits/)
- [100 milliseconds](http://cogsci.stackexchange.com/questions/1664/what-is-the-threshold-where-actions-are-perceived-as-instant)
- [The Great Startup Problem](http://mail.openjdk.java.net/pipermail/mlvm-dev/2014-August/005866.html)

## See Also

- [gnustavo/startup-times](https://github.com/gnustavo/startup-times) - a script to investigate the startup times of several programming languages
- [jwiegley/helloworld](https://github.com/jwiegley/helloworld) - a comparison of "Hello, world" startup times in various languages
- [sharkdp/hyperfine](https://github.com/sharkdp/hyperfine) - a command-line benchmarking tool

## Author

[chocolateboy](mailto:chocolate@cpan.org)

## Version

1.0.0

## Copyright and License

Copyright © 2015-2019 by chocolateboy

This benchmark game is free software; you can redistribute it and/or modify it under the
terms of the [Artistic License 2.0](http://www.opensource.org/licenses/artistic-license-2.0.php).
