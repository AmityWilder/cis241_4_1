# `rl_new.sh`

Generates a new Rust crate with Raylib, inserts a starter snippet, and builds the crate so that Raylib is ready to use.

Essentially, this script runs `cargo new <DIR>/<NAME>` with some extra features.

A custom `main.rs` template (snippet) can be provided as a path to a file with the `-s`/`--snippet` option.
The snippet can include exactly one instance of `%s` which will be overwritten with the `<NAME>` argument.
If the `-s` option is absent, a default snippet will be used.

The `<NAME>` argument will be converted to snake\_case when running `cargo new`.

The generated project will include the following dependencies:
- [`raylib`](https://crates.io/crates/raylib)
  - `with_serde`
- [`thiserror`](https://crates.io/crates/thiserror)
- [`anyhow`](https://crates.io/crates/anyhow)
- [`arrayvec`](https://crates.io/crates/arrayvec)
- [`smallvec`](https://crates.io/crates/smallvec)
- [`tinyvec`](https://crates.io/crates/tinyvec)
- [`serde`](https://crates.io/crates/serde)
  - `derive`

The project can also, upon creation, be built with the `-b`/`--build` option, and opened in Vim with the `-v`/`--vim` option.

## Help

**Usage:** `rl_new.sh <DIR> <NAME> [OPTIONS]`

**Arguments:**

| Argument | About |
|----------|-------|
| `<DIR>`  | Directory to create project in |
| `<NAME>` | Name of the project |

**Options:**

| Optional argument          | About |
|----------------------------|-------|
| `-b`, `--build`            | Build the project after initializing |
| `-v`, `--vim`              | Open main.rs in vim after initializing |
| `-s`, `--snippet` `<PATH>` | Provide a path to a text file containing the snippet to use for main.rs |
| `-h`, `--help`             | Display this message |
