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

  # returns a formatted String displaying information 
  # about this Application
  def info
%{Name: #{name}
#{classes.length} classes: #{classes.map(&:name).join(', ')}
#{activities.length} activities: #{activities.map(&:name).join(', ')}
#{layouts.length} layouts: #{layouts.map(&:name).join(', ')}
APK: #{apk_file}
}
  end

  # the MAIN Activity for this Android application
  #
  # TODO right now this is just getting the first Activity 
  #      that has an intent-filter defined!
  def main_activity
    require 'hpricot'
    doc = Hpricot(manifest_xml)
    name = ( doc / :activity ).find {|activity| ( activity / 'intent-filter' )}['android:name']
    name.sub! /^\./, ''
    activities.find {|a| a.name == name }
  end

  def manifest_xml
    file_path = File.join root, 'AndroidManifest.xml'
    File.read file_path
  end

  # runs this Android application (on the default device)
  def run
    package = main_activity.package_name # TODO need to actually figure out which 
    cmd = "adb shell am start -n #{package}/#{package}.#{main_activity.name}"
    puts cmd
    puts `#{cmd}`
  end

  # installs this Android application (on the default device)
  def install
    cmd = "adb install '#{apk_file}'" if apk_file
    puts cmd
    puts `#{cmd}`
  end

  # uninstalls this Android application (on the default device)
  def uninstall
    cmd = "adb uninstall #{ main_activity.package }"
    puts cmd
    puts `#{cmd}`
  end

  # reinstalls this Android application (on the default device)
  def reinstall
    uninstall
    install
  end

  # returns true if the directory appears to be an Android application,
  # else returns false
  #
  # specifically, we check to see if there's an AndroidManifest.xml
  #
  # TODO go up the directory tree to find a root!  go up to root 
  #      looking for an AndroidManifest.xml
  def self.is_application? directory
    return File.file? File.join(directory, 'AndroidManifest.xml')
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
