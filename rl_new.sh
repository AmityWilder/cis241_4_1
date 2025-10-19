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

if [ $do_build != 0 ]; then
    cargo build                                         # optionally build after so that the application is ready to run
fi
echo -e "$snippet" > './src/main.rs'                    # write snippet into main; after building so that raylib can have bindgen run

if [ $open_vim != 0 ]; then
    vim './src/main.rs'                                 # optionally open in vim to start editing
fi

# References used: (in reverse chronological order)
# - https://stackoverflow.com/questions/638975/how-do-i-tell-if-a-file-does-not-exist-in-bash
# - https://www.startpage.com/do/dsearch?q=bash+check+if+file+exists&cat=web&language=english
# - https://www.w3schools.com/bash/bash_loops.php
# - https://stackoverflow.com/questions/49110/how-do-i-write-a-for-loop-in-bash
# - https://www.startpage.com/do/dsearch?q=bash+loop&cat=web&language=english
# - https://stackoverflow.com/questions/16109652/bash-arrays-and-negative-subscripts-yes-or-no
# - https://www.startpage.com/do/dsearch?q=bash+subscript+array&cat=web&language=english
# - https://stackoverflow.com/questions/2953646/how-can-i-declare-and-use-boolean-variables-in-a-shell-script
# - https://www.startpage.com/do/dsearch?q=bash+store+boolean&cat=web&language=english
# - https://www.startpage.com/do/dsearch?q=linux+proton&cat=web&language=english
# - https://askubuntu.com/questions/385528/how-to-increment-a-variable-in-bash
# - https://www.startpage.com/do/dsearch?q=bash+increment+integer&cat=web&language=english
# - https://unix.stackexchange.com/questions/278502/accessing-array-index-variable-from-bash-shell-script-loop
# - https://stackoverflow.com/questions/3685970/check-if-a-bash-array-contains-a-value
# - https://www.startpage.com/do/dsearch?q=bash+get+element+of+array&cat=web&language=english
# - https://askubuntu.com/questions/166583/bash-for-loop-with-range
# - https://www.startpage.com/do/dsearch?q=bash+iterate+over+range&cat=web&language=english
# - https://www.quora.com/What-does-%E2%80%9C-%E2%80%9D-mean-in-Bash
# - https://www.startpage.com/do/dsearch?q=bash+dollarsign+at&cat=web&language=english
# - https://stackoverflow.com/questions/12711786/convert-command-line-arguments-into-an-array-in-bash
# - https://www.startpage.com/do/dsearch?q=bash+store+arguments+to+array&cat=web&language=english
# - https://stackoverflow.com/questions/21112707/check-if-a-string-matches-a-regex-in-bash-script
# - https://stackoverflow.com/questions/2237080/how-to-compare-strings-in-bash
# - https://superuser.com/questions/267163/what-does-the-little-squiggly-do-in-linux
# - https://www.startpage.com/do/dsearch?q=bash+squggle+equal&cat=web&language=english
# - https://unix.stackexchange.com/questions/78625/using-sed-to-find-and-replace-complex-string-preferrably-with-regex
# - https://stackoverflow.com/questions/20615217/bash-bad-substitution
# - https://www.startpage.com/do/dsearch?q=bash+bad+substitution&cat=web&language=english
# - https://www.gnu.org/software/sed/manual/html_node/Regular-Expressions.html
# - https://www.startpage.com/do/dsearch?q=bash+tr+snake+case&cat=web&language=english
# - https://stackoverflow.com/questions/13043344/search-and-replace-in-bash-using-regular-expressions
# - https://www.startpage.com/do/dsearch?q=bash+regex+substitute&cat=web&language=english
# - https://kodekloud.com/blog/regex-shell-script/
# - https://www.startpage.com/do/dsearch?q=bash+regex&cat=web&language=english
# - https://regex101.com/
# - https://askubuntu.com/questions/595269/use-sed-on-a-string-variable-rather-than-a-file
# - https://stackoverflow.com/questions/14885535/using-sed-with-command-line-argument
# - https://www.startpage.com/do/dsearch?q=linux+sed+argument&cat=web&language=english
# - https://www.geeksforgeeks.org/linux-unix/sed-command-in-linux-unix-with-examples/
# - https://www.startpage.com/do/dsearch?q=linux+sed&cat=web&language=english
# - https://www.w3schools.com/bash/bash_functions.php
# - https://www.startpage.com/do/dsearch?q=bash+function&cat=web&language=english
# - https://unix.stackexchange.com/questions/243100/command-line-argument-with-usage-message
# - https://www.startpage.com/do/dsearch?q=bash+give+usage+error&cat=web&language=english
# - https://vi.stackexchange.com/questions/3115/find-and-replace-using-regular-expressions
# - https://www.gnu.org/software/bash/manual/html_node/Arithmetic-Expansion.html
# - https://www.startpage.com/do/dsearch?q=bash+arithmetic+expansion&cat=web&language=english
# - https://www.w3schools.com/bash/bash_conditions.php
# - https://www.reddit.com/r/linux/comments/19884er/best_way_to_effectively_kill_a_process/
# - https://www.startpage.com/do/dsearch?q=linux+end+process&cat=web&language=english
# - https://www.startpage.com/do/dsearch?q=bash+condition&cat=web&language=english
# - https://askubuntu.com/questions/341178/how-do-i-get-details-about-a-package-which-isnt-installed
# - https://www.startpage.com/do/dsearch?q=apt+info&cat=web&language=english
# - https://stackoverflow.com/questions/637827/redirect-stderr-and-stdout-in-bash
# - https://www.startpage.com/do/dsearch?q=bash+read+stderr&cat=web&language=english
# - https://www.startpage.com/do/dsearch?q=cargo+bash+script+check+if+failed&cat=web&language=english
# - https://stackoverflow.com/questions/1101957/are-there-any-standard-exit-status-codes-in-linux
# - https://stackoverflow.com/questions/1378274/in-a-bash-script-how-can-i-exit-the-entire-script-if-a-certain-condition-occurs
# - https://www.startpage.com/do/dsearch?q=bash+end+script&cat=web&language=english
# - https://askubuntu.com/questions/819924/how-to-send-a-process-to-background-and-foreground
# - https://www.startpage.com/do/dsearch?q=bash+bring+background+process+to+foreground&cat=web&language=english
# - https://unix.stackexchange.com/questions/103555/how-do-i-unset-a-variable-at-the-command-line
# - https://www.startpage.com/do/dsearch?q=bash+remove+variable&cat=web&language=english
# - https://www.warp.dev/terminus/bash-printf
# - https://www.startpage.com/do/dsearch?q=bash+printf&cat=web&language=english
# - https://unix.stackexchange.com/questions/24647/why-is-echo-ignoring-my-quote-characters
# - https://unix.stackexchange.com/questions/189787/difference-between-echo-and-echo-e
# - https://www.startpage.com/do/dsearch?q=echo+%22-e%22&cat=web&language=english
# - https://superuser.com/questions/363646/create-a-file-with-newlines-in-bash
# - https://www.startpage.com/do/dsearch?q=bash+redirect+string+with+newlines+to+file&cat=web&language=english
# - https://www.gnu.org/software/bash/manual/html_node/Redirections.html
# - https://stackoverflow.com/questions/33863066/what-is-the-difference-between-double-and-single-bigger-than-in-linux-terminal
# - https://www.startpage.com/do/dsearch?q=bash+single+vs+double+greater+than&cat=web&language=english
# - https://stackoverflow.com/questions/11618696/shell-write-variable-contents-to-a-file
# - https://www.startpage.com/do/dsearch?q=bash+write+string+variable+to+file&cat=web&language=english
# - https://stackoverflow.com/questions/23929235/multi-line-string-with-extra-space-preserved-indentation
# - https://stackoverflow.com/questions/4676459/write-to-file-but-overwrite-it-if-it-exists
# - https://www.startpage.com/do/dsearch?q=bash+overwrite+file&cat=web&language=english
# - https://stackoverflow.com/questions/13869879/storing-passed-arguments-in-separate-variables-shell-scripting
# - https://www.startpage.com/do/dsearch?q=bash+store+arg+to+variable&cat=web&language=english
# - https://www.startpage.com/do/dsearch?q=bash+multiline+string&cat=web&language=english
# - https://stackoverflow.com/questions/6482377/check-existence-of-input-argument-in-a-bash-shell-script
# - https://www.startpage.com/do/dsearch?q=bash+test+if+argument+exists&cat=web&language=english
# - https://stackoverflow.com/questions/18096670/what-does-z-mean-in-bash
# - https://www.startpage.com/do/dsearch?q=bash+save+file&cat=web&language=english
# - https://www.cyberciti.biz/faq/unix-linux-bash-script-check-if-variable-is-empty/
# - https://www.startpage.com/do/dsearch?q=bash+script+test+if+empty+string&cat=web&language=english
# - https://www.startpage.com/do/dsearch?q=linux+set+permissions&cat=web&language=english
# - https://www.w3schools.com/bash/bash_script.php
# - https://www.startpage.com/do/dsearch?q=bash+path&cat=web&language=english
# - https://www.startpage.com/do/dsearch?q=shbang&cat=web&language=english
# - https://www.startpage.com/do/dsearch?q=create+file+command&cat=web&language=english
# - https://www.startpage.com/do/dsearch?q=git+create+local+repo&cat=web&language=english
