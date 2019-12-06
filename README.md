# Anypaste Emacs integration

Easily upload buffers or regions to pastebin sites using [Anypaste](https://anypaste.xyz).

[![asciicast](https://asciinema.org/a/KR865EJWAn8tLnIUXxSOod24Q.svg)](https://asciinema.org/a/KR865EJWAn8tLnIUXxSOod24Q)

## Setup

Before you can use anypaste.el, [install Anypaste](https://anypaste.xyz/#installation).

Then, put anypaste.el in your load path and load it in your `.init.el` file. Eg, you could put anypaste.el into ~/.emacs.d then add `(load "/home/my-username/.emacs.d/anypaste.el")` to your ~/.emacs.d/init.el file.

## Usage

`M-x anypaste` to upload the current buffer. If a region is selected, upload that region instead. Add a prefix argument (`C-u M-x anypaste`) for manual plugin selection (choose which site to upload to). Add two prefix arguments (`C-u C-u M-x anypaste`) to choose the tags to pass to `anypaste -t` (see Anypaste documentation for more information).

## Customization

Set the following variables to change anypaste.el's behavior:

+ `anypaste-program`: The path to the anypaste executable (but Emacs can usually find it by default).
+ `anypaste-default-tags`: A list of tags to use by default (only used when tags are not set manually by `C-u C-u`).
+ `anypaste-buffer-name`: Where to put Anypaste's output.
+ `anypaste-erase-buffer`: If non-nil, erases the Anypaste output buffer every time there's a new upload. Nil by default.
