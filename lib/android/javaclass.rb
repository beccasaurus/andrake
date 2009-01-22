# represents a .java class file
#
# we're using *VERY* rudimentary parsing of the 
# .java source code, at the moment.
#
# we need to eventually write a much more intelligent 
# .java parser or, ideally, find a well-written .java 
# parser to take advantage of
#
class Android::JavaClass
  
  attr_accessor :file_path

  def initialize file_path
    @file_path = file_path
  end

  def name
    parsed.class_name
  end

  def source
    File.read file_path
  end
  alias source_code source

  def self.find_all directory
    Dir[ File.join(directory, '**', '*.java') ].map do |file_path|
      java = JavaClass.new file_path
      # if a the .java class 'extends Foo' and there's a class called 
      # Android::Foo, we initialize an Android::Foo, else we initialize
      # a generic Android::JavaClass
      if java.superclass && Android.const_defined?(java.superclass.to_sym)
        Android.const_get(java.superclass).new file_path
      else
        Android::JavaClass.new file_path
      end
    end
  end

  protected

  # returns a parsed JavaClass object with 
  # the class name, superclass, etc etc etc
  def parsed
    @parsed ||= ::JavaClass.parse(file_path)
  end

end
