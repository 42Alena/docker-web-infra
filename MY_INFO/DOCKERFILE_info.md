
# ENTRYPOINT ["/init_db.sh"]
- ENTRYPOINT: first thing the container runs.
- It runs /init_db.sh as the main process (PID 1).
- `ENTRYPOINT` = “Start this script first.”

Very important: inside the script " .sh" must end with:  `exec "$@"`
- `exec "$@"` (end of .sh) = “Now hand over control.”
- That line “hands the steering wheel” to CMD below.


# CMD ["mariadbd"]
- CMD = “Here’s the actual server to run.”
- CMD: the program that starts after the script finishes.
- Our script will exec this → it becomes the main server process.
- No & , no background — it runs in front.
