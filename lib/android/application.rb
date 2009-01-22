# Represents an Android application, with the conventional 
# layout used by Android applications
#
class Android::Application

  # the root directory of the Application
  attr_accessor :root

  def initialize root_directory = File.dirname(__FILE__)
    @root = File.expand_path root_directory
  end

  # returns the String name of this Application
  #
  # currently simply returns the directory name, 
  # whereas it really should parse the AndroidManifest.xml
  def name
    File.basename root
  end

  # returns an Array of all of this Application's 
  # .java classes (Android::JavaClass)
  def classes
    Android::JavaClass.find_all root
  end

  # returns an Array of all of this Application's
  # .xml layout files (Android::Layout)
  def layouts
    Android::Layout.find_all root
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

  # returns the String path to this Application's built .apk file
  def apk_file
    if File.file? File.join root, 'bin', "#{name}.apk"
      File.join root, 'bin', "#{name}.apk"
    elsif File.file? File.join root, 'bin', "#{name}-debug.apk"
      File.join root, 'bin', "#{name}-debug.apk"
    else 
      nil
    end
  end

  # actually builds the Application to an APK
  #
  # returns false if the APK wasn't properly created
  #
  def build
    write_build_xml_template
    require 'open3'
    build_command = %{cd '#{root}' && ant}
    @build_output = Open3.popen3 build_command
    return (@build_output[1].read.include?('BUILD SUCCESSFUL')) ? true : false
  end

  protected

  # creates a build.xml Ant script in this Application's root directory
  def write_build_xml_template
    build_xml = File.join root, 'build.xml'
    unless File.file? build_xml
      require 'erb'
      template = File.read File.join(Android.gem_root, 'templates', 'build.xml.erb')
      rendered = ERB.new(template).result(proc { @app = self; proc{}}.call)
      File.open(build_xml, 'w'){|f| f << rendered }
    end
  end

  # returns an Array of all of this Application's
  # .java classes that match the given type, eg: Android::Activity
  def classes_by_type type
    classes.select {|klass| klass.is_a? type }
  end

end
