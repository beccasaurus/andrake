# represents a .java class file
#
# we're using *VERY* rudimentary parsing of the 
# .java source code, at the moment.
#
# we need to eventually write a much more intelligent 
# .java parser or, ideally, find a well-written .java 
# parser to take advantage of
#
class Android::JavaClass < JavaClass

  def self.find_all directory
    Dir[ File.join(directory, '**', '*.java') ].map do |file_path|
      java = JavaClass.new file_path
      # if a the .java class 'extends Foo' and there's a class called 
      # Android::Foo, we initialize an Android::Foo, else we initialize
      # a generic Android::JavaClass
      begin
        if java.superclass && Android.const_defined?(java.superclass.to_sym)
          Android.const_get(java.superclass).new file_path
        else
          Android::JavaClass.new file_path
        end
      rescue NameError
        Android::JavaClass.new file_path
      end
    end
  end

end
