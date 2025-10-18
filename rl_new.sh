# Generates a new Rust crate with Raylib, inserts a starter snippet, and builds the crate so that Raylib is ready to use.
# Usage:
# ./script.sh <DIR> <NAME> [SNIPPET]

#!/bin/bash

usage_err() {
    local err=$1
    echo -e "Error: $err

Usage: script.sh <DIR> <NAME> [SNIPPET]

Arguments:
  <DIR>:     Directory to create project in
  <NAME>:    Name of the project
  [SNIPPET]: Optional path to a text file containing the snippet to use for main.rs
"
    exit 1
}

# display error message if arguments are invalid
if [ $# -lt 2 ]
then
    usage_err "Not enough arguments (expected 2-3, got $#)"
elif [ $# -gt 3 ]
then
    usage_err "Too many arguments (expected 2-3, got $#)"
fi

dir="$1"                                                # give a name to the first positional argument
echo "dir: \"$dir\""                                    # for debugging/feedback

name="$2"                                               # give a name to the second positional argument
echo "name: \"$name\""                                  # for debugging/feedback

if [ -n "$3" ]                                          # the third positional argument is optional - check if it exists
then                                                    # snippet argument exists - load it
    local snippet_path="$3"                             # snippet argument is a path to the file, not a literal snippet
                                                        # (passing a full snippet literal to the cli would be very cumbersome,
                                                        # and not worth supporting)
    echo "snippet path: \"$snippet_path\""              # for debugging/feedback
    printf -v name "$name"                              # make $name available to printf in next line (to my understanding)
    snippet=$(printf "$(cat $snippet_path)")            # using printf here so that snippet can reference name
    echo -e "snippet: ```\n$snippet\n```"               # for debugging/feedback
else                                                    # snippet argument is excluded - use the hardcoded default
    echo 'using default snippet'                        # for debugging/feedback
    snippet="#![cfg_attr(not(debug_assertions), windows_subsystem = \"windows\")]
#![deny(clippy::undocumented_unsafe_blocks, clippy::missing_safety_doc)]

use raylib::prelude::*;
#[allow(clippy::enum_glob_use, unused_imports, reason = \"all variants of these enums are prefixed\")]
use {KeyboardKey::*, MouseButton::*};

fn main() {
    let (mut rl, thread) = init()
        .title(\"$name\")
        .size(1280, 720)
        .resizeable()
        .vsync()
        .build();

    rl.set_target_fps(get_monitor_refresh_rate(get_current_monitor()));
    rl.set_exit_key(None);
    rl.maximize_window();
    let _font = rl.get_font_default();

    while !rl.window_should_close() {
        // -----------------------------------
        // Tick
        // -----------------------------------

        // [INSERT CODE HERE]

        // -----------------------------------
        // Draw
        // -----------------------------------

        let mut d = rl.begin_drawing(&thread);
        d.clear_background(Color::BLACK);

        // [INSERT CODE HERE]

        #[cfg(debug_assertions)] {
            d.draw_fps(0, 0);
        }
    }
}
"
fi

path="$dir/$(echo "$name" | sed -r 's/([a-z])([A-Z])| /\1_\2/g' | sed -r 's/([A-Z])/\L\1/g')"
echo $path                                              # for debugging/feedback

cargo new "$path"                                       # create the project
cd "$path"                                              # allows us to use paths relative to our project for the rest of the script
cargo add raylib thiserror anyhow arrayvec smallvec tinyvec \
    -F raylib/with_serde serde -F serde/derive          # add useful crates I tend to use
echo -e "$snippet" > './src/main.rs'                    # write snippet into main
cargo build                                             # build after so that the application is ready to run
vim './src/main.rs'                                     # open in vim to start editing
