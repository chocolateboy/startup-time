# startup-time

[![Build Status](https://travis-ci.org/chocolateboy/startup-time.svg)](https://travis-ci.org/chocolateboy/startup-time)
[![Gem Version](https://img.shields.io/gem/v/startup-time.svg)](https://rubygems.org/gems/startup-time)

<!-- toc -->

- [NAME](#name)
- [INSTALLATION](#installation)
- [SYNOPSIS](#synopsis)
  - [Sample Output](#sample-output)
- [DESCRIPTION](#description)
  - [Why?](#why)
- [OPTIONS](#options)
- [PREREQUISITES](#prerequisites)
- [REFERENCES](#references)
- [SEE ALSO](#see-also)
- [AUTHOR](#author)
- [VERSION](#version)
- [COPYRIGHT AND LICENSE](#copyright-and-license)

<!-- tocstop -->

## NAME

startup-time - a command-line benchmarking tool which measures the startup times of programs in various languages

## INSTALLATION

```sh
$ gem install startup-time
```

## SYNOPSIS

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

# run the test suite for at least 10 seconds (default: 10)
$ startup-time --time 30

# run each program 10 times
$ startup-time --count 10
```

### Sample Output

    Test                  Time (ms)
    C (gcc)                    0.33
    Nim                        0.44
    Kotlin Native              0.61
    LuaJIT                     0.64
    Go                         0.66
    Rust                       0.67
    JavaScript (QuickJS)       0.83
    D (DMD)                    0.88
    Lua                        0.94
    Java Native (GraalVM)      0.99
    Haskell (GHC)              1.08
    D (GDC)                    1.10
    Wren                       1.14
    C++ (g++)                  1.19
    Crystal                    1.55
    Perl                       1.66
    Bash                       2.63
    JavaScript (GraalVM)       3.88
    JavaScript (Deno)         11.15
    Python 3                  22.09
    Ruby (TruffleRuby)        28.66
    JavaScript (Node.js)      34.35
    Python 2                  43.43
    Java                      54.59
    Ruby                      68.61
    Kotlin                   103.02
    Scala                    801.21

## DESCRIPTION

A command-line tool which measures how long it takes to execute ["Hello, world!"](https://en.wikipedia.org/wiki/%22Hello,_World!%22_program)
programs written in various languages. It records the fastest time for each program and prints a sorted table of the times after each run.
Apart from the [prerequisites](#prerequisites) listed below, the tool doesn't require any of the tested languages to be installed: if a
compiler/interpreter is not available, the test is skipped.

### Why?

To determine which languages are practical (or impractical) to use for command-line interface (CLI) tools. Anything under
[100 milliseconds](https://www.nngroup.com/articles/response-times-3-important-limits/) is perceived as instantaneous.
Anything over that is perceptibly delayed, which can impair interactivity and productivity on the command line, and can
mean the difference between staying in the zone and losing your train of thought.

## OPTIONS

```
USAGE:

    startup-time [options]

OPTIONS:

    -c, --count, --rounds INTEGER    The number of times to run each program
        --clean                      Remove the build directory and exit
                                     (targets will be recompiled on the next run)
    -d, --dir PATH                   Specify the build directory
                                     (default: "${XDG_CACHE_HOME:-~/.cache}/startup-time")
    -h, --help                       Show this help message and exit
    -H, --help-only, --help-omit     Show the IDs and groups that can be passed to --only and --omit
    -j, --json                       Output the results in JSON format (implies --quiet)
    -o, --only LIST                  Only run the specified tests (comma-separated list of IDs/groups)
    -O, --omit LIST                  Don't run the specified tests (comma-separated list of IDs/groups)
    -q, --quiet                      Suppress all inessential output
    -t, --time INTEGER               The minimum number of seconds to run the test suite for
                                     (minimum: 2, default: 10)
    -v, --verbose                    Enable verbose logging
    -V, --version                    Display the version and exit
```

## PREREQUISITES

- Ruby >= 2.4

## REFERENCES

- [Response Times: The 3 Important Limits](https://www.nngroup.com/articles/response-times-3-important-limits/)
- [100 milliseconds](http://cogsci.stackexchange.com/questions/1664/what-is-the-threshold-where-actions-are-perceived-as-instant)

## SEE ALSO

- [drujensen/fib](https://github.com/drujensen/fib) - a recursive Fibonacci benchmark for multiple languages
- [Gabriel439/bench](https://github.com/Gabriel439/bench) - a command-line benchmark tool written in Haskell
- [gnustavo/startup-times](https://github.com/gnustavo/startup-times) - a script to investigate the startup times of several programming languages
- [jwiegley/helloworld](https://github.com/jwiegley/helloworld) - a comparison of "Hello, world" startup times in various languages
- [sharkdp/hyperfine](https://github.com/sharkdp/hyperfine) - a command-line benchmarking tool

## AUTHOR

[chocolateboy](mailto:chocolate@cpan.org)

## VERSION

1.3.0

## COPYRIGHT AND LICENSE

Copyright © 2015-2019 by chocolateboy

This benchmark game is free software; you can redistribute it and/or modify it under the
terms of the [Artistic License 2.0](http://www.opensource.org/licenses/artistic-license-2.0.php).
