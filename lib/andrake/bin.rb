require 'optparse'
require 'simplecli'

class Andrake::Bin
  include SimpleCLI

  def usage *args
    puts <<doco

  andrake == %{ Android Development Companion }

    Usage:
      andrake command [options]

    Examples:
      andrake info

    Further help:
      andrake commands         # list all available commands
      andrake help <COMMAND>   # show help for COMMAND
      andrake help             # show this help message

doco
  end 

  def info_help
    <<doco
Usage: #{ script_name } info

  Summary:
    Display information about the current Android application
  end
doco
  end
  def info
    puts Andrake::Hybrid.new.info
  end

end
