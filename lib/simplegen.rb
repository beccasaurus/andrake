$:.unshift File.dirname(__FILE__)
require 'rubygems'

class SimpleGen
  class << self
    attr_accessor :template_directories

    def templates
      puts "template_directories => #{ template_directories.inspect }"
      template_directories.inject([]) do |all_templates, template_dir|
        dirs = Dir[File.join(template_dir, '*')].select {|x| File.directory? x }
        all_templates += dirs.map {|dir| SimpleGen::Template.new(dir) }
        all_templates
      end
    end
  end
end

SimpleGen.template_directories ||= []

# move to simplegen/template.rb
class SimpleGen::Template

  attr_accessor :root

  def initialize template_directory = '.'
    @root = template_directory
  end

  def name
    File.basename root
  end

end
