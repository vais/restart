require "restart/version"

Restart::BANNER = <<-BANNER
USAGE: restart [options] <your shell command>

Runs your shell command, then re-runs it any time filesystem change is detected.

EXAMPLE: restart ruby test.rb

This will run "ruby test.rb", then re-run it after test.rb file changes (or any
other files change in current working directory or any subdirectories under it).

See http://github.com/vais/restart for more info.
Version: #{ Restart::VERSION }

OPTIONS:
BANNER

require 'optparse'
options = {}

option_parser = OptionParser.new(Restart::BANNER, 28, '  ') do |opts|

  options[:dir] = []
  opts.on(
    '-d', '--dir DIR[,DIR...]',
    Array,
    'Directory tree to watch for filesystem changes.',
    'Examples:',
    '  restart -d app rackup',
    '  restart -d .,../test,../lib rake test',
    '  restart -d .,../test -d../lib rake test',
    '  restart -d . -d ../test -d ../lib rake test',
    '  '
  ) do |dirs|
    dirs.each do |dir|
      unless File.directory?(dir)
        fail OptionParser::InvalidArgument, "#{ dir } is not a valid directory"
      end
    end
    options[:dir] += dirs
  end

  options[:file] = []
  opts.on(
    '-f', '--file EXT[,EXT...]',
    Array,
    'Only watch files with given extension, plus files',
    'with matching name that do not have an extension.',
    'Examples:',
    '  restart -f Rakefile rake',
    '  restart -f rb ruby test.rb',
    '  restart -f rb,yml ruby app.rb',
    '  restart -f rb -f yml ruby app.rb',
    '  '
  ) do |exts|
    options[:file] += exts.map do |ext|
      s = Regexp.quote(ext.sub(/^\./, ''))
      /\.#{ s }$|^#{ s }$/i
    end
  end

  options[:ignore] = []
  opts.on(
    '-i', '--ignore REGX[,REGX...]',
    Array,
    'Ignore file paths matching regular expression.',
    'Examples:',
    '  restart -i /foo/bar/',
    '  restart -i \.pid$,\.coffee$',
    '  restart -i \.pid$ -i \.coffee$',
    '  '
  ) do |patterns|
    options[:ignore] += patterns.map do |pattern|
      Regexp.new(pattern)
    end
  end

  options[:clear] = false
  opts.on('-c', '--clear', 'Clear screen between each run.') do
    options[:clear] = true
  end

  options[:explain] = false
  opts.on('-e', '--explain', 'Show current values for all options and quit.') do
    options[:explain] = true
  end

  opts.on('-v', '--version', 'Display version and quit.') do
    puts Restart::VERSION
    exit
  end

  opts.on('-h', '--help', 'Display this help message and quit.') do
    puts opts
    exit
  end
end

option_parser.order!
options[:dir] << '.' if options[:dir].empty?
options[:command] = ARGV.map{|s| s =~ /\s/ ? %Q{"#{ s }"} : s}.join(' ')
if options[:explain]
  require 'pp'
  options.delete(:explain)
  pp options
  exit
end
if options[:command].empty?
  puts option_parser
  exit
end

require 'listen'
restarting = false
process = Process.detach(spawn(options[:command]))

begin
  require 'win32api'
  ctrl_c = Win32API.new('Kernel32', 'GenerateConsoleCtrlEvent', 'II', 'I')
  killer = proc do
    ctrl_c.call(0, 0)
    sleep 0.1
    if process.alive?
      Process.kill(:KILL, process.pid)
    end
  end
  clear = proc do
    system 'cls'
  end
rescue LoadError
  killer = proc do
    Process.kill(:INT, -Process.getpgrp)
    sleep 0.1
    if process.alive?
      Process.kill(:KILL, process.pid)
    end
  end
  clear = proc do
    system 'clear'
  end
end

trap('INT') do
  exit unless restarting || process.alive?
end

listener_options = {}
unless options[:file].empty?
  listener_options[:only] = options[:file]
end
unless options[:ignore].empty?
  listener_options[:ignore] = options[:ignore]
end
listener = Listen.to(*options[:dir], listener_options) do
  restarting = true
  killer.call
  restarting = false
  clear.call if options[:clear]
  print "\n\e[7m#{ Time.now.strftime('%H:%M:%S') } #{ options[:command] }\e[0m\n\n"
  process = Process.detach(spawn(options[:command]))
end

listener.start
sleep
