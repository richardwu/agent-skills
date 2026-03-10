# Scripts

## noz

Prevents a MacBook from sleeping, even on battery power or when the lid is closed.

### Usage

```bash
# Prevent sleep for 300 seconds (default)
./noz

# Prevent sleep for 600 seconds
./noz 600
```

### How it works

1. Disables battery sleep via `pmset -b disablesleep 1` and `pmset -b sleep 0` (requires `sudo`)
2. Waits for the specified timeout or until you press Enter
3. Restores the original battery sleep settings on exit (Enter, timeout, or Ctrl-C)
4. On timeout, also triggers `pmset sleepnow` to put the machine to sleep immediately
