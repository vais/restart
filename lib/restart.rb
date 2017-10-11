require 'restart/version'
require 'optparse'
require 'listen'

Restart::BANNER = <<-BANNER.freeze
USAGE: restart [options] <your shell command>

Runs your shell command, then re-runs it any time filesystem change is detected.

EXAMPLE: restart ruby test.rb

This will run "ruby test.rb", then re-run it after test.rb file changes (or any
other files change in current working directory or any subdirectories under it).

See http://github.com/vais/restart for more info.
Version: #{Restart::VERSION}

OPTIONS:
BANNER

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
    dirs.map do |dir|
      unless File.directory?(dir)
        raise OptionParser::InvalidArgument, "#{dir} is not a valid directory"
      end
      File.expand_path(dir)
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

options[:dir] = options[:dir].empty? ? [Dir.pwd] : options[:dir].uniq
options[:command] = ARGV.map { |s| s =~ /\s/ ? %("#{s}") : s }.join(' ')

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

listener_options = {}
listener_options[:only]   = options[:file]   unless options[:file].empty?
listener_options[:ignore] = options[:ignore] unless options[:ignore].empty?

process = Process.detach(spawn(options[:command]))

listener = Listen.to(*options[:dir], listener_options) do
  system("taskkill /t /f /pid #{process.pid} > nul 2>&1") if process.alive?
  system('cls') if options[:clear]
  print "\n\e[7m"
  print Time.now.strftime('%H:%M:%S')
  print ' '
  print options[:command]
  print "\e[0m\n\n"
  process = Process.detach(spawn(options[:command]))
end

trap('INT') do
  system("taskkill /t /f /pid #{process.pid} > nul 2>&1") if process.alive?
  listener.stop
  exit
end

listener.start
sleep
