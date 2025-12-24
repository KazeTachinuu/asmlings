/*
 * asmlings test suite
 *
 * Tests core functionality with proper isolation using temp directories.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <time.h>

#define COLOR_GREEN  "\033[92m"
#define COLOR_RED    "\033[91m"
#define COLOR_DIM    "\033[2m"
#define COLOR_RESET  "\033[0m"

static int tests_passed = 0;
static int tests_failed = 0;
static char test_dir[256];
static char orig_dir[256];

/* Test macros */
#define TEST(name) static int test_##name(void)
#define RUN_TEST(name) run_test(#name, test_##name)

#define ASSERT(cond, msg) do { \
    if (!(cond)) { \
        fprintf(stderr, "    " COLOR_RED "ASSERT FAILED: %s" COLOR_RESET "\n", msg); \
        return 0; \
    } \
} while(0)

#define ASSERT_EQ(a, b, msg) ASSERT((a) == (b), msg)
#define ASSERT_NE(a, b, msg) ASSERT((a) != (b), msg)
#define ASSERT_STR(haystack, needle, msg) ASSERT(strstr(haystack, needle) != NULL, msg)
#define ASSERT_NOT_STR(haystack, needle, msg) ASSERT(strstr(haystack, needle) == NULL, msg)

/* Run a test with proper reporting */
static void run_test(const char *name, int (*fn)(void)) {
    printf("  %-45s ", name);
    fflush(stdout);
    if (fn()) {
        printf(COLOR_GREEN "PASS" COLOR_RESET "\n");
        tests_passed++;
    } else {
        printf(COLOR_RED "FAIL" COLOR_RESET "\n");
        tests_failed++;
    }
}

/* Execute command and capture output */
static int run_cmd(const char *cmd, char *out, size_t size, int *exit_code) {
    FILE *fp = popen(cmd, "r");
    if (!fp) return 0;

    size_t n = 0;
    while (n < size - 1) {
        size_t r = fread(out + n, 1, size - 1 - n, fp);
        if (r == 0) break;
        n += r;
    }
    out[n] = '\0';

    int status = pclose(fp);
    if (exit_code) {
        *exit_code = WIFEXITED(status) ? WEXITSTATUS(status) : -1;
    }
    return 1;
}

/* Write content to file */
static void write_file(const char *path, const char *content) {
    FILE *fp = fopen(path, "w");
    if (fp) {
        fputs(content, fp);
        fclose(fp);
    }
}

/* Create test environment with temp exercises directory */
static void setup_test_env(void) {
    getcwd(orig_dir, sizeof(orig_dir));
    snprintf(test_dir, sizeof(test_dir), "/tmp/asmlings_test_%d", getpid());

    mkdir(test_dir, 0755);

    char path[512];
    snprintf(path, sizeof(path), "%s/exercises", test_dir);
    mkdir(path, 0755);

    snprintf(path, sizeof(path), "%s/hints", test_dir);
    mkdir(path, 0755);
}

/* Clean up test environment */
static void teardown_test_env(void) {
    char cmd[512];
    snprintf(cmd, sizeof(cmd), "rm -rf %s", test_dir);
    system(cmd);
}

/* Create a test exercise file */
static void create_exercise(const char *name, const char *code, int with_marker) {
    char path[512];
    snprintf(path, sizeof(path), "%s/exercises/%s", test_dir, name);

    FILE *fp = fopen(path, "w");
    if (!fp) return;

    fprintf(fp, "# Test exercise\n");
    if (with_marker) {
        fprintf(fp, "# I AM NOT DONE\n");
    }
    fprintf(fp, "# Expected exit code: 0\n\n");
    fprintf(fp, "%s", code);
    fclose(fp);
}

/* Create a hint file */
static void create_hint(const char *num, const char *text) {
    char path[512];
    snprintf(path, sizeof(path), "%s/hints/%s.txt", test_dir, num);
    write_file(path, text);
}

/* Run asmlings in test directory */
static int run_asmlings(const char *args, char *out, size_t size, int *exit_code) {
    char cmd[1024];
    snprintf(cmd, sizeof(cmd),
        "cd %s && cp %s/asmlings . && timeout 2 ./asmlings %s 2>&1",
        test_dir, orig_dir, args ? args : "");
    return run_cmd(cmd, out, size, exit_code);
}

/* ============================================================
 * BINARY TESTS
 * ============================================================ */

TEST(binary_exists) {
    struct stat st;
    ASSERT_EQ(stat("./asmlings", &st), 0, "asmlings binary not found");
    ASSERT(st.st_mode & S_IXUSR, "asmlings not executable");
    return 1;
}

TEST(binary_runs) {
    char out[4096];
    int code;
    run_cmd("./asmlings help 2>&1", out, sizeof(out), &code);
    ASSERT_EQ(code, 0, "asmlings help failed");
    return 1;
}

/* ============================================================
 * CLI TESTS
 * ============================================================ */

TEST(help_shows_usage) {
    char out[4096];
    int code;
    run_cmd("./asmlings help 2>&1", out, sizeof(out), &code);
    ASSERT_EQ(code, 0, "help failed");
    ASSERT_STR(out, "USAGE", "missing USAGE");
    ASSERT_STR(out, "watch", "missing watch command");
    ASSERT_STR(out, "list", "missing list command");
    ASSERT_STR(out, "hint", "missing hint command");
    return 1;
}

TEST(help_h_works) {
    char out[4096];
    int code;
    run_cmd("./asmlings -h 2>&1", out, sizeof(out), &code);
    ASSERT_EQ(code, 0, "-h failed");
    ASSERT_STR(out, "USAGE", "missing USAGE");
    return 1;
}

TEST(help_long_works) {
    char out[4096];
    int code;
    run_cmd("./asmlings --help 2>&1", out, sizeof(out), &code);
    ASSERT_EQ(code, 0, "--help failed");
    ASSERT_STR(out, "USAGE", "missing USAGE");
    return 1;
}

TEST(unknown_cmd_shows_help) {
    char out[4096];
    int code;
    run_cmd("./asmlings notacommand 2>&1", out, sizeof(out), &code);
    ASSERT_STR(out, "USAGE", "should show help for unknown command");
    return 1;
}

/* ============================================================
 * EXERCISE DETECTION TESTS
 * ============================================================ */

TEST(detects_exercises) {
    setup_test_env();

    create_exercise("01_test.s",
        ".global _start\n.text\n_start:\n    mov $60, %rax\n    xor %rdi, %rdi\n    syscall\n",
        1);
    create_exercise("02_test.s",
        ".global _start\n.text\n_start:\n    mov $60, %rax\n    xor %rdi, %rdi\n    syscall\n",
        1);

    char out[8192];
    int code;
    run_asmlings("list", out, sizeof(out), &code);

    teardown_test_env();

    ASSERT_EQ(code, 0, "list failed");
    ASSERT_STR(out, "01_test", "01_test not found");
    ASSERT_STR(out, "02_test", "02_test not found");
    ASSERT_STR(out, "0/2", "wrong count");
    return 1;
}

TEST(exercises_sorted) {
    setup_test_env();

    /* Create out of order */
    create_exercise("03_c.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 1);
    create_exercise("01_a.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 1);
    create_exercise("02_b.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 1);

    char out[8192];
    run_asmlings("list", out, sizeof(out), NULL);

    char *p1 = strstr(out, "01_a");
    char *p2 = strstr(out, "02_b");
    char *p3 = strstr(out, "03_c");

    teardown_test_env();

    ASSERT(p1 && p2 && p3, "exercises not found");
    ASSERT(p1 < p2, "01 should be before 02");
    ASSERT(p2 < p3, "02 should be before 03");
    return 1;
}

TEST(ignores_non_s_files) {
    setup_test_env();

    create_exercise("01_test.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 1);

    char path[512];
    snprintf(path, sizeof(path), "%s/exercises/readme.txt", test_dir);
    write_file(path, "This is not an exercise");
    snprintf(path, sizeof(path), "%s/exercises/notes.md", test_dir);
    write_file(path, "# Notes");

    char out[8192];
    run_asmlings("list", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_NOT_STR(out, "readme", "should not list .txt");
    ASSERT_NOT_STR(out, "notes", "should not list .md");
    ASSERT_STR(out, "01_test", "should list .s file");
    return 1;
}

/* ============================================================
 * MARKER DETECTION TESTS
 * ============================================================ */

TEST(marker_blocks_pass) {
    setup_test_env();

    /* Valid code but has marker */
    create_exercise("01_test.s",
        ".global _start\n.text\n_start:\n    mov $60, %rax\n    xor %rdi, %rdi\n    syscall\n",
        1); /* with marker */

    char out[8192];
    run_asmlings("list", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, ">", "should show incomplete marker");
    ASSERT_STR(out, "0/1", "should show 0 passed");
    return 1;
}

TEST(no_marker_allows_pass) {
    setup_test_env();

    /* Valid code without marker */
    create_exercise("01_test.s",
        ".global _start\n.text\n_start:\n    mov $60, %rax\n    xor %rdi, %rdi\n    syscall\n",
        0); /* no marker */

    char out[8192];
    run_asmlings("list", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "1/1", "should pass when marker removed");
    return 1;
}

/* ============================================================
 * COMPILATION & EXECUTION TESTS
 * ============================================================ */

TEST(valid_code_passes) {
    setup_test_env();

    create_exercise("01_test.s",
        ".global _start\n"
        ".text\n"
        "_start:\n"
        "    mov $60, %rax\n"
        "    xor %rdi, %rdi\n"
        "    syscall\n",
        0);

    char out[8192];
    run_asmlings("list", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "1/1", "valid code should pass");
    return 1;
}

TEST(invalid_code_fails) {
    setup_test_env();

    create_exercise("01_test.s",
        "this is not valid assembly code\n",
        0);

    char out[8192];
    run_asmlings("list", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "0/1", "invalid code should fail");
    return 1;
}

TEST(wrong_exit_code_fails) {
    setup_test_env();

    /* Expected is 0, but returns 42 */
    create_exercise("01_test.s",
        ".global _start\n"
        ".text\n"
        "_start:\n"
        "    mov $60, %rax\n"
        "    mov $42, %rdi\n"  /* wrong exit code */
        "    syscall\n",
        0);

    char out[8192];
    run_asmlings("list", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "0/1", "wrong exit code should fail");
    return 1;
}

TEST(correct_exit_code_passes) {
    setup_test_env();

    create_exercise("01_test.s",
        ".global _start\n"
        ".text\n"
        "_start:\n"
        "    mov $60, %rax\n"
        "    mov $0, %rdi\n"
        "    syscall\n",
        0);

    char out[8192];
    run_asmlings("list", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "1/1", "correct exit code should pass");
    return 1;
}

/* ============================================================
 * HINT TESTS
 * ============================================================ */

TEST(hint_shows_content) {
    setup_test_env();

    create_exercise("01_test.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 1);
    create_hint("01", "This is the hint for exercise 01");

    char out[4096];
    run_asmlings("hint", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "This is the hint", "hint content not shown");
    return 1;
}

TEST(hint_specific_exercise) {
    setup_test_env();

    create_exercise("01_first.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 1);
    create_exercise("02_second.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 1);
    create_hint("01", "Hint for 01");
    create_hint("02", "Hint for 02");

    char out[4096];
    run_asmlings("hint 02", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "Hint for 02", "should show hint for 02");
    return 1;
}

/* ============================================================
 * WATCH MODE TESTS
 * ============================================================ */

TEST(watch_starts) {
    setup_test_env();

    create_exercise("01_test.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 1);

    char out[4096];
    run_asmlings("watch", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "Watching", "watch mode should start");
    return 1;
}

TEST(watch_shows_first_incomplete) {
    setup_test_env();

    /* First exercise passes (no marker) */
    create_exercise("01_done.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 0);
    /* Second exercise incomplete (has marker) */
    create_exercise("02_todo.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 1);

    char out[8192];
    run_asmlings("watch", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "02_todo", "should show first incomplete exercise");
    return 1;
}

TEST(watch_detects_file_change) {
    setup_test_env();

    create_exercise("01_test.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 1);

    /* Copy asmlings to test dir */
    char cmd[1024];
    snprintf(cmd, sizeof(cmd), "cp %s/asmlings %s/", orig_dir, test_dir);
    system(cmd);

    /* Start watch in background, touch file, capture output */
    snprintf(cmd, sizeof(cmd),
        "cd %s && ("
        "  ./asmlings watch &"
        "  PID=$!;"
        "  sleep 0.3;"
        "  touch exercises/01_test.s;"
        "  sleep 0.3;"
        "  kill $PID 2>/dev/null;"
        "  wait $PID 2>/dev/null"
        ") 2>&1",
        test_dir);

    char out[8192];
    run_cmd(cmd, out, sizeof(out), NULL);

    teardown_test_env();

    /* Should show "Checking" at least twice - once on start, once on change */
    char *first = strstr(out, "Checking");
    ASSERT(first != NULL, "should show Checking");
    char *second = strstr(first + 1, "Checking");
    ASSERT(second != NULL, "should detect file change");
    return 1;
}

TEST(watch_detects_atomic_save) {
    setup_test_env();

    create_exercise("01_test.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 1);

    char cmd[1024];
    snprintf(cmd, sizeof(cmd), "cp %s/asmlings %s/", orig_dir, test_dir);
    system(cmd);

    /* Simulate atomic save (cp + mv like vim does) */
    snprintf(cmd, sizeof(cmd),
        "cd %s && ("
        "  ./asmlings watch &"
        "  PID=$!;"
        "  sleep 0.3;"
        "  cp exercises/01_test.s /tmp/atomic_test.s;"
        "  mv /tmp/atomic_test.s exercises/01_test.s;"
        "  sleep 0.3;"
        "  kill $PID 2>/dev/null;"
        "  wait $PID 2>/dev/null"
        ") 2>&1",
        test_dir);

    char out[8192];
    run_cmd(cmd, out, sizeof(out), NULL);

    teardown_test_env();

    char *first = strstr(out, "Checking");
    ASSERT(first != NULL, "should show Checking");
    char *second = strstr(first + 1, "Checking");
    ASSERT(second != NULL, "should detect atomic save");
    return 1;
}

/* ============================================================
 * PROGRESS TESTS
 * ============================================================ */

TEST(progress_counts_correct) {
    setup_test_env();

    /* 1 passed, 1 incomplete */
    create_exercise("01_a.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 0);
    create_exercise("02_b.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 1);

    char out[8192];
    run_asmlings("list", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "1/2", "should show 1/2 passed");
    return 1;
}

TEST(progress_shows_percentage) {
    setup_test_env();

    create_exercise("01_test.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 0);
    create_exercise("02_test.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 1);

    char out[8192];
    run_asmlings("list", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "50%", "should show 50%");
    return 1;
}

TEST(all_complete_message) {
    setup_test_env();

    create_exercise("01_test.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 0);

    char out[8192];
    run_asmlings("watch", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "complete", "should show completion message");
    return 1;
}

/* ============================================================
 * OUTPUT VERIFICATION TESTS
 * ============================================================ */

/* Create exercise with expected output */
static void create_exercise_output(const char *name, const char *code, int with_marker, const char *expected_out) {
    char path[512];
    snprintf(path, sizeof(path), "%s/exercises/%s", test_dir, name);

    FILE *fp = fopen(path, "w");
    if (!fp) return;

    fprintf(fp, "# Test exercise\n");
    if (with_marker) {
        fprintf(fp, "# I AM NOT DONE\n");
    }
    fprintf(fp, "# Expected output: \"%s\"\n", expected_out);
    fprintf(fp, "# Expected exit code: 0\n\n");
    fprintf(fp, "%s", code);
    fclose(fp);
}

/* Create predict exercise with ??? */
static void create_predict_exercise(const char *name, const char *code, int with_marker, const char *predict_val) {
    char path[512];
    snprintf(path, sizeof(path), "%s/exercises/%s", test_dir, name);

    FILE *fp = fopen(path, "w");
    if (!fp) return;

    fprintf(fp, "# Test predict exercise\n");
    if (with_marker) {
        fprintf(fp, "# I AM NOT DONE\n");
    }
    fprintf(fp, "# Expected exit code: %s\n\n", predict_val);
    fprintf(fp, "%s", code);
    fclose(fp);
}

TEST(output_correct_passes) {
    setup_test_env();

    /* Exercise that outputs "Hi" and expects "Hi" */
    create_exercise_output("01_test.s",
        ".global _start\n"
        ".section .rodata\n"
        "msg: .ascii \"Hi\"\n"
        ".section .text\n"
        "_start:\n"
        "    mov $1, %rax\n"
        "    mov $1, %rdi\n"
        "    lea msg(%rip), %rsi\n"
        "    mov $2, %rdx\n"
        "    syscall\n"
        "    mov $60, %rax\n"
        "    xor %rdi, %rdi\n"
        "    syscall\n",
        0, "Hi");

    char out[8192];
    run_asmlings("list", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "1/1", "correct output should pass");
    return 1;
}

TEST(output_wrong_fails) {
    setup_test_env();

    /* Exercise outputs "Yo" but expects "Hi" */
    create_exercise_output("01_test.s",
        ".global _start\n"
        ".section .rodata\n"
        "msg: .ascii \"Yo\"\n"
        ".section .text\n"
        "_start:\n"
        "    mov $1, %rax\n"
        "    mov $1, %rdi\n"
        "    lea msg(%rip), %rsi\n"
        "    mov $2, %rdx\n"
        "    syscall\n"
        "    mov $60, %rax\n"
        "    xor %rdi, %rdi\n"
        "    syscall\n",
        0, "Hi");

    char out[8192];
    run_asmlings("list", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "0/1", "wrong output should fail");
    return 1;
}

TEST(output_shows_expected_actual) {
    setup_test_env();

    create_exercise_output("01_test.s",
        ".global _start\n"
        ".section .rodata\n"
        "msg: .ascii \"Yo\"\n"
        ".section .text\n"
        "_start:\n"
        "    mov $1, %rax\n"
        "    mov $1, %rdi\n"
        "    lea msg(%rip), %rsi\n"
        "    mov $2, %rdx\n"
        "    syscall\n"
        "    mov $60, %rax\n"
        "    xor %rdi, %rdi\n"
        "    syscall\n",
        0, "Hi");

    char out[8192];
    run_asmlings("watch", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "Wrong output", "should show wrong output message");
    ASSERT_STR(out, "Expected", "should show expected label");
    ASSERT_STR(out, "Got", "should show actual label");
    return 1;
}

/* ============================================================
 * PREDICT EXERCISE TESTS
 * ============================================================ */

TEST(predict_unfilled_not_done) {
    setup_test_env();

    /* Predict exercise with ??? (not filled in yet) */
    create_predict_exercise("01_predict.s",
        ".global _start\n"
        ".text\n"
        "_start:\n"
        "    mov $60, %rax\n"
        "    mov $42, %rdi\n"
        "    syscall\n",
        0, "???");

    char out[8192];
    run_asmlings("list", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "0/1", "??? should be treated as not done");
    return 1;
}

TEST(predict_correct_passes) {
    setup_test_env();

    /* Predict exercise with correct answer filled in */
    create_predict_exercise("01_predict.s",
        ".global _start\n"
        ".text\n"
        "_start:\n"
        "    mov $60, %rax\n"
        "    mov $42, %rdi\n"
        "    syscall\n",
        0, "42");

    char out[8192];
    run_asmlings("list", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "1/1", "correct prediction should pass");
    return 1;
}

TEST(predict_wrong_no_answer) {
    setup_test_env();

    /* Predict exercise with wrong answer - should not reveal correct answer */
    create_predict_exercise("01_predict.s",
        ".global _start\n"
        ".text\n"
        "_start:\n"
        "    mov $60, %rax\n"
        "    mov $42, %rdi\n"
        "    syscall\n",
        0, "99");

    char out[8192];
    run_asmlings("watch", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "Wrong prediction", "should show wrong prediction message");
    ASSERT_NOT_STR(out, "expected 42", "should NOT reveal the answer");
    return 1;
}

/* ============================================================
 * ERROR MESSAGE TESTS
 * ============================================================ */

TEST(shows_wrong_exit_message) {
    setup_test_env();

    create_exercise("01_test.s",
        ".global _start\n_start: mov $60,%rax\nmov $99,%rdi\nsyscall\n",
        0);

    char out[8192];
    run_asmlings("watch", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "Wrong exit code", "should show wrong exit code message");
    ASSERT_STR(out, "99", "should show actual exit code");
    ASSERT_STR(out, "0", "should show expected exit code");
    return 1;
}

TEST(shows_compilation_failed) {
    setup_test_env();

    create_exercise("01_test.s", "invalid asm garbage xyz\n", 0);

    char out[8192];
    run_asmlings("watch", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "failed", "should show compilation failed");
    return 1;
}

TEST(shows_hint_tip) {
    setup_test_env();

    create_exercise("01_test.s", ".global _start\n_start: mov $60,%rax\nxor %rdi,%rdi\nsyscall\n", 1);

    char out[8192];
    run_asmlings("watch", out, sizeof(out), NULL);

    teardown_test_env();

    ASSERT_STR(out, "hint", "should mention hint command");
    return 1;
}

/* ============================================================
 * MAIN
 * ============================================================ */

static void print_section(const char *name) {
    printf("\n" COLOR_DIM "─── %s ───" COLOR_RESET "\n", name);
}

int main(void) {
    getcwd(orig_dir, sizeof(orig_dir));

    printf("\n");
    printf("╔══════════════════════════════════════════╗\n");
    printf("║         asmlings test suite              ║\n");
    printf("╚══════════════════════════════════════════╝\n");

    print_section("Binary");
    RUN_TEST(binary_exists);
    RUN_TEST(binary_runs);

    print_section("CLI");
    RUN_TEST(help_shows_usage);
    RUN_TEST(help_h_works);
    RUN_TEST(help_long_works);
    RUN_TEST(unknown_cmd_shows_help);

    print_section("Exercise Detection");
    RUN_TEST(detects_exercises);
    RUN_TEST(exercises_sorted);
    RUN_TEST(ignores_non_s_files);

    print_section("Marker Detection");
    RUN_TEST(marker_blocks_pass);
    RUN_TEST(no_marker_allows_pass);

    print_section("Compilation & Execution");
    RUN_TEST(valid_code_passes);
    RUN_TEST(invalid_code_fails);
    RUN_TEST(wrong_exit_code_fails);
    RUN_TEST(correct_exit_code_passes);

    print_section("Hints");
    RUN_TEST(hint_shows_content);
    RUN_TEST(hint_specific_exercise);

    print_section("Watch Mode");
    RUN_TEST(watch_starts);
    RUN_TEST(watch_shows_first_incomplete);
    RUN_TEST(watch_detects_file_change);
    RUN_TEST(watch_detects_atomic_save);

    print_section("Progress");
    RUN_TEST(progress_counts_correct);
    RUN_TEST(progress_shows_percentage);
    RUN_TEST(all_complete_message);

    print_section("Output Verification");
    RUN_TEST(output_correct_passes);
    RUN_TEST(output_wrong_fails);
    RUN_TEST(output_shows_expected_actual);

    print_section("Predict Exercises");
    RUN_TEST(predict_unfilled_not_done);
    RUN_TEST(predict_correct_passes);
    RUN_TEST(predict_wrong_no_answer);

    print_section("Error Messages");
    RUN_TEST(shows_wrong_exit_message);
    RUN_TEST(shows_compilation_failed);
    RUN_TEST(shows_hint_tip);

    printf("\n══════════════════════════════════════════\n");
    printf("Results: ");
    if (tests_failed == 0) {
        printf(COLOR_GREEN "%d passed" COLOR_RESET ", 0 failed\n", tests_passed);
    } else {
        printf("%d passed, " COLOR_RED "%d failed" COLOR_RESET "\n", tests_passed, tests_failed);
    }
    printf("══════════════════════════════════════════\n\n");

    return tests_failed > 0 ? 1 : 0;
}
