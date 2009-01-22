$:.unshift File.dirname(__FILE__)
require 'android'

class Andrake
  def self.gem_root
    lib = File.dirname __FILE__
    File.expand_path File.join(lib, '..')
  end
end

require 'andrake/application'
require 'andrake/activity'
require 'andrake/resource_manager'
