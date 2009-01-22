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
      android info

    Further help:
      android commands         # list all available commands
      android help <COMMAND>   # show help for COMMAND
      android help             # show this help message

doco
  end 

  def current_application
    if Android::Application.is_application? '.'
      Android::Application.new '.'
    else
      puts "Current directory doesn't appear to be the root of an Android application."
      exit
    end
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
    puts current_application.info
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
    current_application.build
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
    current_application.reinstall
    current_application.run
  end

end
