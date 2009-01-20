# Andrake Testing - Super Insanely Simple Prototype!

class Andrake
  class << self
    def resources *args
      @resources ||= Andrake::ResourceManager.new
      yield(@resources) if block_given?
      @resources
    end
  end
end

class Andrake::ResourceManager
  attr_accessor :resources

  def resources
    @resources ||= {}
  end

  def [] resource_name
    resources[resource_name] ||= {}
  end

  def []= *args
    puts "[]= #{ args.inspect }"
  end

  def method_missing name, *args
    if args.empty?
      self[ name ]
    elsif args.first.is_a?Hash
      self[ name ].merge! args.first
    else
      raise "not sure what to do with #{name.inspect}(#{args.inspect})"
    end
  end

  def to_xml
    require 'yaml'
    puts resources.to_yaml
  end
end
