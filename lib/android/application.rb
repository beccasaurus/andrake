# Represents an Android application, with the conventional 
# layout used by Android applications
#
class Android::Application

  # the root directory of the Application
  attr_accessor :root, :name

  def initialize root_directory = File.dirname(__FILE__)
    @root = File.expand_path root_directory
  end

  # returns the String name of this Application
  #
  # currently simply returns the directory name, 
  # whereas it really should parse the AndroidManifest.xml
  def name
    @name ||= File.basename(File.expand_path(root))
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
    puts "build"
    self.name = File.basename(File.expand_path(File.join('.'))) if self.name == '.app'
    puts "Building #{self.name}"
    write_build_xml_template
    check_build_dependencies
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
    main = ''
    if File.file? File.join(root, 'AndroidManifest.xml')
      puts "Getting Main Activity from AndroidManifest.xml"
      require 'hpricot'
      doc = Hpricot(File.read(File.join(root, 'AndroidManifest.xml')))
      name = ''
      ( doc / :activity ).each do |activity|
        if ( activity / 'intent-filter' ).length > 0
          name = activity['android:name']
          break
        end
      end
      name.sub! /^\./, ''
      main = activities.find {|a| a.name == name }
    else
      puts "Trying to figure out Main Activity name"
      main = activities.find {|a| a.name.downcase == self.name.downcase }
      main = activities.find {|a| a.name.downcase == "#{ self.name.downcase }activity" } unless main
      main = activities.find {|a| self.name.downcase.include? a.name.downcase } unless main
      main = activities.find {|a| a.name.downcase.include? self.name.downcase } unless main
      raise "Hmm ... couldn't figure out which the main activity is ... activities: #{ activities.map {|a| a.name}.inspect }" unless main
    end

    puts "Main Activity: #{ main.name }"
    main
  end

  def manifest_xml
    file_path = File.join root, 'AndroidManifest.xml'
    File.read file_path
  end

  # runs this Android application (on the default device)
  def run
    puts "run"
    self.name = File.basename(File.expand_path(File.join('.'))) if self.name == '.app'
    puts "Main Activity: #{ main_activity.name }"
    package = main_activity.package_name # TODO need to actually figure out which 
    cmd = "cd '#{root}' && adb shell am start -n #{package}/#{package}.#{main_activity.name}"
    puts cmd
    make_sure_a_device_is_present
    puts `#{cmd}`
  end

  # installs this Android application (on the default device)
  def install
    puts "install"
    build
    cmd = "cd '#{root}' && adb install '#{apk_file}'" if apk_file
    puts cmd
    make_sure_a_device_is_present
    puts `#{cmd}`
  end

  # uninstalls this Android application (on the default device)
  def uninstall
    puts "uninstall"
    bin_dir = File.join root, 'bin'
    FileUtils.rm_r bin_dir if File.directory? bin_dir
    cmd = "cd '#{root}' && adb uninstall #{ main_activity.package }"
    puts cmd
    make_sure_a_device_is_present
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

  # makes sure that all of the dependencies needed to build this 
  # Android Application are present
  def check_build_dependencies
    libs = File.join root, 'libs'
    FileUtils.mkdir libs unless File.directory? libs
  end

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

  # if no device is present, start up an emulator
  def make_sure_a_device_is_present
    unless Android.devices.length > 0
      require 'open3'
      Open3.popen3 'emulator'
    end
  end

end
