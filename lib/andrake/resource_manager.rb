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

  # this is pretty icky, but it's just a prototype!
  def to_xml
    require 'builder'
    builder = Builder::XmlMarkup.new :indent => 2
    builder.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
    builder.resources do |res|
      resources.each  do |type, values|
        type = type.to_s.singularize
        values.each   do |value|
          name, value = value.first, value.last
          eval "res.#{type} #{value.inspect}, :name => #{name.inspect}"
        end
      end
    end
  end

end
