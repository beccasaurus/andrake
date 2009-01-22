$:.unshift ::File.dirname(__FILE__)
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

    # as opposed to unix PATHs, the LAST template directory (with the same name) wins (if names conflict)
    def templates
      template_directories.inject([]) do |all_templates, template_dir|
        dirs = Dir[::File.join(template_dir, '*')].select {|x| ::File.directory? x }
        
        # delete templates that new templates will be overriding
        dirs.each do |dir|
          template_to_override = all_templates.find {|t| t.name == ::File.basename(dir) }
          all_templates.delete template_to_override if template_to_override
        end

        all_templates += dirs.map {|dir| SimpleGen::Template.new(dir) }
        all_templates
      end
    end

    def [] template_name
      templates.find {|t| t.name == template_name.to_s }
    end

    def get_filter name
      filter = nil
      [ name.to_s, name.to_s.to_sym, name.to_s.sub(/^_/,''), name.to_s.sub(/^_/,'').to_sym ].each do |possible_key|
        filter = SimpleGen.filters[possible_key] if SimpleGen.filters.keys.include?possible_key
      end
      filter
    end

    def filter_exists? name
      get_filter(name) != nil
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
    ::File.basename root
  end

  # THESE SHOULD BE private/protected
  # handles support for %var% in file and directory names
  def render_dynamic_path path, variables = { }
    path.gsub(/%(\w+)%/){|match|
      match_without_percentage_signs = match.gsub('%','') # can't seem to find a way to just get the (\w+)
      replace_dynamic_path_variables(match_without_percentage_signs, variables)
    }
  end
  def replace_dynamic_path_variables match, variables = { }
    replace_with = variables[match.to_s]
    if replace_with.nil? and not match.to_s.empty?
      replace_with = variables[match.to_s.to_sym] # try using a symbol
    end
    replace_with.to_s
  end

  def generate! root_path_for_generation = '.', variables = { }
    files.each do |file|
      relative_file_path = file.path.sub(root, '') # relative to the template
      relative_dirname   = ::File.dirname  relative_file_path
      dir_to_render_in   = ::File.join root_path_for_generation, relative_dirname
      file_to_render_in  = ::File.join dir_to_render_in, file.filename_to_generate

      # support %var% in file and directory names
      dir_to_render_in   = render_dynamic_path(dir_to_render_in,  variables)
      file_to_render_in  = render_dynamic_path(file_to_render_in, variables)

      # puts "relative_file_path => #{ relative_file_path }"
      # puts "dir_to_render_in   => #{ dir_to_render_in }"
      # puts "file_to_render_in  => #{ file_to_render_in }"

      FileUtils.mkdir_p dir_to_render_in
      ::File.open( file_to_render_in, 'w' ) {|f| f << file.render(variables) }
    end

    # make any directories that haven't been created (empty directories)
    directories.each do |dir|
      relative_dir_path = ::File.join root_path_for_generation, dir.sub(root, '')
      FileUtils.mkdir_p relative_dir_path unless ::File.directory? relative_dir_path
    end
  end

  # returns an Array of files (SimpleGen::Template::File)
  # for this SimpleGen::Template
  def files
    files_and_directories.select {|x| ::File.file? x }.map {|f| SimpleGen::Template::File.new f }
  end

  protected

  # returns an Array of all of the files and directories
  # in this SimpleGen::Template's #root directory
  #
  # currently ignores hidden files and folders
  #
  def files_and_directories
    Dir[ ::File.join(root, '**', '*') ]
  end

  def directories
    files_and_directories.select {|x| ::File.directory? x }
  end

end

# move to 'simplegen/template/file.rb'
class SimpleGen::Template::File

  attr_accessor :path

  def initialize file_path
    @path = file_path
  end

  def filename
    basename
  end

  def basename
    ::File.basename path
  end

  def extensions
    _extensions = basename.split('.')
    _filename_without_extension = _extensions.shift
    _extensions
  end

  def filename_without_extension
    _extensions = basename.split('.')
    _filename_without_extension = _extensions.shift
    _filename_without_extension
  end

  def filter_extensions
    extensions.select {|x| SimpleGen.filter_exists?(x) }
  end

  def nonfilter_extensions
    extensions - filter_extensions
  end

  def filename_to_generate
    (nonfilter_extensions.empty?) ? 
      filename_without_extension  : 
      (filename_without_extension + '.' + nonfilter_extensions.join('.'))
  end

  def filters
    filter_extensions.map {|x| SimpleGen.get_filter x }
  end

  def source
    File.read path
  end

  def render variables = { }
    _current_simplegen_template_file_output = source
    
    # put variables into binding, as instance variables (so they don't raise exceptions with missing)
    b = lambda {
      variables.each do |k, v|
        instance_variable_set "@#{k}", v
      end
      binding
    }

    filters.each do |filter|
      _current_simplegen_template_file_output = filter.call(_current_simplegen_template_file_output, b.call)
    end

    _current_simplegen_template_file_output
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
