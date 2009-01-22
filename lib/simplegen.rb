$:.unshift File.dirname(__FILE__)
require 'fileutils'
require 'rubygems'

class SimpleGen
  class << self

    # paths to look for templates in
    attr_accessor :template_directories
    
    # filtering engines for templates, eg. ERB
    #
    # these should be procs (or something callable)
    #
    # see SimpleGen::Filter
    #
    # this is a Hash, key = the filter name, which will be used for the file extension, eg. 'erb'
    attr_accessor :filters

    def templates
      template_directories.inject([]) do |all_templates, template_dir|
        dirs = Dir[File.join(template_dir, '*')].select {|x| File.directory? x }
        all_templates += dirs.map {|dir| SimpleGen::Template.new(dir) }
        all_templates
      end
    end

    def [] template_name
      templates.find {|t| t.name == template_name.to_s }
    end
  end
end

SimpleGen.filters              ||= {}
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

  def generate! root_path_for_generation = '.', variables = { }
    puts files_and_directories.inspect
    puts files.inspect
  end

  protected

  # returns an Array of all of the files and directories
  # in this SimpleGen::Template's #root directory
  #
  # currently ignores hidden files and folders
  #
  def files_and_directories
    Dir[ File.join(root, '**', '*') ]
  end

  def files
    files_and_directories.select {|x| File.file? x }
  end

  def directories
    files_and_directories.select {|x| File.directory? x }
  end

end

# move to 'simplegen/filter.rb'
#
# note, a filter doesn't have to be a SimpleGen::Filter, it can be 
# a Proc, it just needs to respond to #call
class SimpleGen::Filter

  attr_accessor :proc

  def initialize &block
    @proc = block
  end

  def call text, binding = TOPLEVEL_BINDING
    @proc.call text, binding
  end

  # include an ERB filter, out of the box, as it comes with the ruby standard library
  def self.erb_filter
    # at the moment, there's no reason why this isn't just a simple proc
    # ... we might do something fancy with SimpleGen::Filter at some point ...
    # really, though, things should just be simple procs for now
    SimpleGen::Filter.new do |text, binding|
      require 'erb'
      ERB.new(text).result(binding)
    end
  end

end

# add ERB filter by default, if not defined
SimpleGen.filters[:erb] = SimpleGen::Filter.erb_filter unless SimpleGen.filters.keys.include?(:erb)
