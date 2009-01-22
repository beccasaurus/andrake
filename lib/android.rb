$:.unshift File.dirname(__FILE__)
require 'fileutils'
require 'javaclass' # <--- should be moved to a gem, eventually
require 'rubygems'

class Android
  def self.gem_root
    lib = File.dirname __FILE__
    File.expand_path File.join(lib, '..')
  end

  def self.devices
    `adb devices`.sub("List of devices attached \n",'').split("\n")
  end
end

require 'android/extensions'
require 'android/application'
require 'android/javaclass'
require 'android/activity'
require 'android/layout'
