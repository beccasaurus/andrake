$:.unshift File.dirname(__FILE__)
require 'fileutils'
require 'javaclass' # <--- should be moved to a gem, eventually

class Android
  def self.gem_root
    lib = File.dirname __FILE__
    File.expand_path File.join(lib, '..')
  end
end

require 'android/extensions'
require 'android/application'
require 'android/javaclass'
require 'android/activity'
require 'android/layout'
