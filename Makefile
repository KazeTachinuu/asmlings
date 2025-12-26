.PHONY: all clean test check-deps

SRCS = asmlings.s \
       src/constants.s \
       src/data.s \
       src/strings.s \
       src/print.s \
       src/exercises.s \
       src/check.s \
       src/expected.s \
       src/hints.s \
       src/commands.s \
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
