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
.equ SYS_GETDENTS64,        217
.equ SYS_INOTIFY_INIT,      253
.equ SYS_INOTIFY_ADD_WATCH, 254

# File flags
.equ O_RDONLY,              0

# inotify flags
.equ IN_CLOSE_WRITE,        0x00000008
.equ IN_MOVED_TO,           0x00000080
.equ IN_CREATE,             0x00000100
.equ IN_WATCH_MASK,         0x00000188  # CLOSE_WRITE | MOVED_TO | CREATE

# Limits
.equ MAX_EXERCISES,         32
.equ MAX_PATH,              256
.equ EXERCISE_SIZE,         264     # MAX_PATH + 8 (state + padding)
.equ DIRENT_BUFFER_SIZE,    4096
.equ INOTIFY_BUF_SIZE,      4096
.equ PROGRESS_WIDTH,        20

# Exercise states
.equ STATE_NOT_DONE,        0
.equ STATE_PASSED,          1
.equ STATE_FAILED,          2
.equ STATE_WRONG_EXIT,      3
