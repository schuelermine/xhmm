# xhmm—extra home-manager modules

Extra home manager modules.

To import, use either flakes or import a file directly.

You are encouraged to look through the code yourself! Many options have been described via the description fields.

Current contents:

- `console`: Shell things
    - `fish`: Fish
        - Fish prompt
    - `less`: More options for `less`
        - ⚠️ Requires `program-variables`
    - `nano`: More options for `nano`
        - ⚠️ Requires `program-variables`
    - `program-variables`: Program variables
        - `$PAGER`
        - `$EDITOR`
        - `$VISUAL`
- `desktop`: Desktop configuration
    - `gnome`: GNOME configuration
        - Shell theme
        - GTK theme
        - Cursor theme
        - Extensions
        - Fonts
    - `fonts`: Alias for `home.packages` for fonts
- `languages`: Programming languages
    - `haskell`: Haskell
        - Cabal
        - GHC
        - GHCup
        - HLS
        - Stack
    - `python`: Python
        - Python
        - Mypy
        - Pip
        - Pytest
    - `rust`: Rust
        - Cargo
        - Clippy
        - RLS
        - Rust analyzer
        - Rustc
        - Rustfmt
        - Rustup
        - Expose rust source location for language servicess
