# selectmaketarget.vim

This plugin simplifies building a target different from the default target. 
Press F9 to get a list of possible targets. Hit Enter on the target name you 
want to build. Now pressing F10 will build this target. If available it uses 
vim-dispatch. Subsequent F10 key presses first abort a build, if it still runs.

## Installation

    mkdir -p ~/.vim/pack/mattkretz/start
    cd ~/.vim/pack/mattkretz/start
    git clone https://github.com/mattkretz/vim-selectmaketarget

## License

Copyright © Matthias Kretz.  Distributed under the same terms as Vim itself.
See `:help license`.
