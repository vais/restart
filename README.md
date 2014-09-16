# Restart

Runs your shell command, then re-runs it any time filesystem change is detected.

EXAMPLE: `restart ruby test.rb`

This will run `ruby test.rb`, then re-run it after the test.rb file changes (or any other files change in current working directory or any subdirectories under it).

## Installation

`gem install restart`

## Windows Installation

The process of installing this gem involves building native extensions because of its dependency on the [listen](https://rubygems.org/gems/listen) gem. If you have not already installed [DevKit](http://rubyinstaller.org/add-ons/devkit/) from [RubyInstaller.org](http://rubyinstaller.org), you will need to get it installed and working on your system before installing any gems that depend on building native extensions. To get started, [download DevKit](http://rubyinstaller.org/downloads/), and follow [these step-by-step installation instructions](https://github.com/oneclick/rubyinstaller/wiki/Development-Kit).

Once DevKit is installed and working, you are ready to install this gem:

`gem install restart`

It is _highly recommended_ that you also install the [wdm](https://rubygems.org/gems/wdm) gem, which enables [listen](https://rubygems.org/gems/listen) to receive filesystem event notifications from Windows instead of polling the filesystem for changes (you DO NOT want to use polling):

`gem install wdm`

That's all - you should now be able to start using the `restart` command.

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
                                 restart -i /foo/bar/
                                 restart -i \.pid$,\.coffee$
                                 restart -i \.pid$ -i \.coffee$

  -c, --clear                  Clear screen between each run.
  -e, --explain                Show current values for all options and quit.
  -v, --version                Display version and quit.
  -h, --help                   Display this help message and quit.
```
