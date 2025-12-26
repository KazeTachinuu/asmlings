# Syscall numbers
.equ SYS_READ,              0
.equ SYS_WRITE,             1
.equ SYS_OPEN,              2
.equ SYS_CLOSE,             3
.equ SYS_NANOSLEEP,         35
.equ SYS_FORK,              57
.equ SYS_EXECVE,            59
.equ SYS_EXIT,              60
.equ SYS_WAIT4,             61
.equ SYS_UNLINK,            87
.equ SYS_INOTIFY_INIT,      253
.equ SYS_INOTIFY_ADD_WATCH, 254

# File flags
.equ O_RDONLY,              0
.equ O_WRONLY_CREAT_TRUNC,  0x241   # O_WRONLY | O_CREAT | O_TRUNC
.equ FILE_PERM_RW,          0644    # rw-r--r--

# inotify flags (CLOSE_WRITE | MOVED_TO | CREATE)
.equ IN_WATCH_MASK,         0x00000188

# Limits
.equ MAX_EXERCISES,         64
.equ MAX_PATH,              256
.equ EXERCISE_SIZE,         264     # MAX_PATH + 8 (state + padding)
.equ INOTIFY_BUF_SIZE,      4096
.equ PROGRESS_WIDTH,        20

# Buffer sizes
.equ SOURCE_BUFFER_SIZE,    65536
.equ HINT_BUFFER_SIZE,      4096
.equ EXPECTED_BUF_SIZE,     4096
.equ OUTPUT_MAX_LEN,        4095    # max output to capture (buffer is 4096)

# Exercise states
.equ STATE_NOT_DONE,        0
.equ STATE_PASSED,          1
.equ STATE_FAILED,          2
.equ STATE_WRONG_EXIT,      3
.equ STATE_WRONG_OUTPUT,    4
.equ STATE_WRONG_PREDICT,   5
.equ STATE_TIMEOUT,         6
.equ STATE_WRONG_STDERR,    7

# Syscalls for pipes
.equ SYS_PIPE,              22
.equ SYS_DUP2,              33
.equ SYS_KILL,              62

# Signals
.equ SIGKILL,               9

# Wait flags
.equ WNOHANG,               1

# Default timeout in milliseconds (0 = no timeout)
.equ DEFAULT_TIMEOUT,       0

# Poll events
.equ POLLIN,                0x0001
.equ POLLHUP,               0x0010
.equ SYS_POLL,              7
