require 'optparse'
require 'simplecli'

class Android::Bin
  include SimpleCLI

  def usage *args
    puts <<doco

  android == %{ Android Development Companion }

    Usage:
      android command [options]

    Examples:
      android ...

    Further help:
      android commands         # list all available commands
      android help <COMMAND>   # show help for COMMAND
      android help             # show this help message

doco
  end 

  def foo_help
    <<doco
Usage: #{ script_name } foo [OPTIONS] [THING]

  Options:
    -l, --list            List all available themes

  Arguments:
    THING                 A thing

  Summary:
    Command for managing #{ script_name } stuff
  end
doco
  end
  def foo *args
    options = {}
    opts = OptionParser.new do |opts|
      opts.on('-l','--list'){ options[:list] = true }
      opts.on('-p','--path'){ options[:path] = true }
    end
    opts.parse! args

    thing = args.last
  end

end
