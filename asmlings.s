# asmlings - Learn x86-64 assembly
.intel_syntax noprefix

# Core
.include "src/core/constants.s"
.include "src/core/data.s"
.include "src/core/strings.s"

# I/O
.include "src/io/print.s"
.include "src/io/file.s"

# Parsing
.include "src/parse/decimal.s"
.include "src/parse/prediction.s"
.include "src/parse/expected.s"

# Compilation and execution
.include "src/compile/testfile.s"
.include "src/compile/compile.s"
.include "src/compile/wait.s"
.include "src/compile/run.s"

# Exercise handling
.include "src/exercise/ptr.s"
.include "src/exercise/load.s"
.include "src/exercise/check.s"
.include "src/exercise/find.s"

# Hints
.include "src/hints/hints.s"

# Command helpers
.include "src/cmd/common.s"
.include "src/cmd/result.s"

# Commands
.include "src/cmd/list.s"
.include "src/cmd/watch.s"
.include "src/cmd/hint.s"
.include "src/cmd/run.s"
.include "src/cmd/check.s"
.include "src/cmd/help.s"

# Entry point
.include "src/main.s"
