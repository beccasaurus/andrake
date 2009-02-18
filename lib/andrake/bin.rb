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
      andrake info             # prints app info
      andrake build            # build app
      andrake emulate          # run app in emulator

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

  def build_help
    <<doco
Usage: #{ script_name } build

  Summary:
    build the current Android application
  end
doco
  end
  def build
    Andrake::Hybrid.new.build
  end

  def emulate_help
    <<doco
Usage: #{ script_name } emulate

  Summary:
    run the current Android application in the emulator
  end
doco
  end
  def emulate
    Andrake::Hybrid.new.build_and_run
  end

end
