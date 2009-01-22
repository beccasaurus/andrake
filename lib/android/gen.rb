require 'optparse'
require 'simplecli'
require 'simplegen'
require 'rubygems'
require 'activesupport' # for now, for alias_method_chain

class OptionParser

  class << self
    attr_accessor :dynamic_options
  end
  OptionParser.dynamic_options ||= { }

  def complete_with_ambiguous_option_handling *args
    begin
      complete_without_ambiguous_option_handling *args 
    rescue
      puts "AMBIGUOUS FAIL!  #{ args.inspect }"
      long_arg = "--#{ args[1] }"
      puts "long: #{long_arg}"
      self.on("--#{long_arg} [X]"){ |x| puts "handled #{long_arg}" }
      complete_without_ambiguous_option_handling *args 
    end
  end
  alias_method_chain :complete, :ambiguous_option_handling
end

gem_root = File.expand_path File.join(File.dirname(__FILE__), '..', '..')
android_gen_template_dir = File.join gem_root, 'templates', 'android-gen'
SimpleGen.template_directories << android_gen_template_dir
SimpleGen.template_directories << File.expand_path("~/.android/templates")

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

  SimpleGen.templates.each do |template|
    name = template.name

    define_method "#{name}_help" do
    <<doco
Usage: #{ script_name } #{ name }

  Summary:
    Generate Template: #{ name }
  end
doco
    end

    define_method name do |*args|
      options = {}
      opts = OptionParser.new do |opts|
        opts.on('--foo [X]'){ |x| options[:foo] = x }
      end
      opts.parse! args

      puts "WILL GENERATE template: #{ name } with variables: ... #{ options.inspect }"
    end

  end

end
