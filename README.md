# Restart

On MS Windows, restart runs your shell command, then re-runs it any time filesystem change is detected.

EXAMPLE: `restart ruby test.rb`

This will run `ruby test.rb`, then re-run it after the test.rb file changes (or any other files change in current working directory or any subdirectories under it).

## Installation

`gem install restart`

It is _highly recommended_ that you also install the [wdm](https://rubygems.org/gems/wdm) gem, which enables [listen](https://rubygems.org/gems/listen) to receive filesystem event notifications from Windows instead of polling the filesystem for changes:

`gem install wdm`

## Usage

```
restart [options] <your shell command>

OPTIONS:
  -d, --dir DIR[,DIR...]       Directory tree to watch for filesystem changes.
                               Examples:
                                 restart -d app rackup
                                 restart -d .,../test,../lib rake test
                                 restart -d .,../test -d../lib rake test
                                 restart -d . -d ../test -d ../lib rake test

  -f, --file EXT[,EXT...]      Only watch files with given extension, plus files
                               with matching name that do not have an extension.
                               Examples:
                                 restart -f Rakefile rake
                                 restart -f rb ruby test.rb
                                 restart -f rb,yml ruby app.rb
                                 restart -f rb -f yml ruby app.rb

  -i, --ignore REGX[,REGX...]  Ignore file paths matching regular expression.
                               Examples:
                                 restart -i \.pid$,\.coffee$
                                 restart -i \.pid$ -i \.coffee$

  -c, --clear                  Clear screen between each run.
  -e, --explain                Show current values for all options and quit.
  -v, --version                Display version and quit.
  -h, --help                   Display this help message and quit.
```
