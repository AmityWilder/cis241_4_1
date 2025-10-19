# Generates a new Rust crate with Raylib, inserts a starter snippet, and builds the crate so that Raylib is ready to use.
# Example: ./script.sh <DIR> <NAME> [OPTIONS]

#!/bin/bash

usage_err() {                                           # optionally display an error message, then the help message, and exits
    local err="$1"
    if [ -n "$err" ]; then
        echo -e "$0: $err\n"
    fi
    echo -e "Usage: $0 <DIR> <NAME> [OPTIONS]

Arguments:
  <DIR>   Directory to create project in
  <NAME>  Name of the project

Options:
  -b, --build           Build the project after initializing
  -v, --vim             Open main.rs in vim after initializing
  -s, --snippet <PATH>  Provide a path to a text file containing the snippet to use for main.rs
  -h, --help            Display this message
"
    exit 1
}

if [ $# -lt 2 ]; then                                   # display error message if arguments are invalid
    usage_err "Not enough positional arguments (expected 2, got $#)"
fi

dir="$1"                                                # give a name to the first positional argument
echo "dir: \"$dir\""                                    # for debugging/feedback

name="$2"                                               # give a name to the second positional argument
echo "name: \"$name\""                                  # for debugging/feedback

args=("$@")                                             # store arguments in an array so we can index them
do_build=0                                              # default to 0 (false) in case no argument mentions building
open_vim=0                                              # default to 0 (false) in case no argument mentions vim
i=2                                                     # start at 2 because the first two arguments are positional
while [ $i -lt $# ]; do
    arg=${args[$i]}
    echo "arg $i: $arg"

    if [ "$arg" = '--snippet' ] || [[ "$arg" =~ ^-[a-z]*s[a-z]*$ ]]; then
        echo 'snippet'
        ((i++))                                         # next argument will be the snippet path - consume it
        if [ $i -ge $# ] || [[ "$arg" =~ ^-[a-z]*s[a-z] ]]; then
            usage_err "Snippet argument must be immediately followed by a path argument"
        fi
        snippet_path=${args[$i]}
    fi

    if [ "$arg" = '--build' ] || [[ "$arg" =~ ^-[a-z]*b[a-z]*$ ]]; then
        echo 'do build'
        do_build=1
    fi

    if [ "$arg" = '--vim' ] || [[ "$arg" =~ ^-[a-z]*v[a-z]*$ ]]; then
        echo 'vim'
        open_vim=1
    fi

    if [ "$arg" = '--help' ] || [[ "$arg" =~ ^-[a-z]*h[a-z]*$ ]]; then
        echo 'help'
        usage_err
    fi

    ((i++))
done

if [ -n "$snippet_path" ] 
then                                                    # snippet argument exists - load it
    echo "snippet path: \"$snippet_path\""              # for debugging/feedback
    if [ ! -f $snippet_path ]; then
        usage_err "File \"$snippet_path\" not found"
    fi
    snippet=$(printf "$(cat $snippet_path)" "$name")    # using printf here so that snippet can reference name with %s (but only once)
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

if [ $do_build != 0 ]; then
    cargo build                                         # optionally build after so that the application is ready to run
fi

if [ $open_vim != 0 ]; then
    vim './src/main.rs'                                 # optionally open in vim to start editing
fi
