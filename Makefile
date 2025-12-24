.PHONY: all clean test

SRCS = asmlings.s \
       src/constants.s \
       src/data.s \
       src/strings.s \
       src/print.s \
       src/exercises.s \
       src/commands.s \
       src/main.s

all: asmlings

asmlings: $(SRCS)
	as --64 -o asmlings.o asmlings.s
	ld -o asmlings asmlings.o
	@rm -f asmlings.o

clean:
	rm -f asmlings asmlings.o /tmp/asmlings_tmp* tests/test_asmlings

test: asmlings tests/test_asmlings
	@./tests/test_asmlings

tests/test_asmlings: tests/test_asmlings.c
	@mkdir -p tests
	gcc -o tests/test_asmlings tests/test_asmlings.c -Wall -Wextra
