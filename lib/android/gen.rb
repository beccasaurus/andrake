require 'optparse'
require 'simplecli'

# Android Generator Script
#
# currently seperate from the main android tool.
# i may merge the two back together eventually.
#
class Android::Gen
  include SimpleCLI

  def usage *args
    puts <<doco

  android-gen == %{ Android Generator Tool }

    Usage:
      android-gen command [options]

    Examples:
      android-gen app HelloAndroid
      android-gen templates

    Further help:
      android-gen commands         # list all available commands
      android-gen help <COMMAND>   # show help for COMMAND
      android-gen help             # show this help message

doco
  end 

  def app_help
    <<doco
Usage: #{ script_name } app [NAME]

  Summary:
    Generate a new Android application
  end
doco
  end
  def app *args
    app_name = args.last
    if app_name.nil? or app_name.empty?
      puts help_for(:app)
    else
      puts "would generate app: #{ app_name }"
    end
  end

end
