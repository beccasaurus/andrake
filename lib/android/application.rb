# Represents an Android application, with the conventional 
# layout used by Android applications
#
class Android::Application

  # the root directory of the Application
  attr_accessor :root

  def initialize root_directory = File.dirname(__FILE__)
    @root = root_directory
  end

  # returns an Array of all of this Application's 
  # .java classes (Android::JavaClass)
  def classes
    Android::JavaClass.find_all root
  end

  # returns an Array of all of this Application's
  # .java classes that are activities (Android::Activity)
  def activities
    classes_by_type Android::Activity
  end

  # returns the resource JavaClass 'R'
  def resource_class
    classes.find {|klass| klass.name == 'R' }
  end

  protected

  # returns an Array of all of this Application's
  # .java classes that match the given type, eg: Android::Activity
  def classes_by_type type
    classes.select {|klass| klass.is_a? type }
  end

end
