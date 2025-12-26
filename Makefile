.PHONY: all clean test check-deps

SRCS = asmlings.s \
       src/core/constants.s \
       src/core/data.s \
       src/core/strings.s \
       src/io/print.s \
       src/io/file.s \
       src/parse/decimal.s \
       src/parse/prediction.s \
       src/parse/expected.s \
       src/compile/testfile.s \
       src/compile/compile.s \
       src/compile/run.s \
       src/exercise/ptr.s \
       src/exercise/load.s \
       src/exercise/check.s \
       src/exercise/find.s \
       src/hints/hints.s \
       src/cmd/common.s \
       src/cmd/result.s \
       src/cmd/list.s \
       src/cmd/watch.s \
       src/cmd/hint.s \
       src/cmd/run.s \
       src/cmd/check.s \
       src/cmd/help.s \
       src/main.s

all: asmlings

asmlings: $(SRCS)
	as --64 -o asmlings.o asmlings.s
	ld -o asmlings asmlings.o
	@rm -f asmlings.o

clean:
	rm -f asmlings asmlings.o /tmp/asmlings_tmp*

test: asmlings check-deps
	@bats tests/test.bats

check-deps:
	@command -v bats >/dev/null || { echo "Error: bats not found. Install with: pacman -S bats"; exit 1; }
	@command -v timeout >/dev/null || { echo "Error: timeout not found (coreutils)"; exit 1; }
