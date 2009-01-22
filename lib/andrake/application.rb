class Andrake::Application

  attr_accessor :root, :name, :activities, :resources

  def initialize root_directory
    @root = root_directory
    @name = File.basename root
    @activities ||= []
    init
    find_activities
  end

  # finds and runs the application's initialization code
  # (within the scope of the App)
  def init
    [ name, 'init', 'config/init' ].each do |possible_config_file|
      file_path = path "#{possible_config_file}.rb"
      if File.file?file_path
        puts "Loading Andrake::App configuration: #{ file_path }"
        eval File.read(file_path)
        break
      end
    end
  end

  # returns an array of Android .java classes
  def classes
    Android::JavaClass.find_all root
  end

  # returns an Array of all of this Application's
  # .xml layout files (Android::Layout)
  def layouts
    Android::Layout.find_all root
  end

  # outputs the AndroidManifest.xml
  def manifest_xml
    require 'builder'
    builder = Builder::XmlMarkup.new :indent => 2
    builder.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
    builder.manifest  'xmlns:android' => 'http://schemas.android.com/apk/res/android',
                      'package' => "com.andrake_testing.#{name.downcase}",
                      'android:versionCode' => '1',
                      'android:versionName' => '1.0.0' do |man|
                        man.application 'android:label' => '@string/app_name' do |app|
                          activities.each do |activity|
                            app.activity 'android:name' => ".#{activity.name}", 'android:label' => '@string/app_name' do |act|
                              # should do these only if the activity is the main activity
                              act.tag! 'intent-filter' do |intent|
                                intent.action   'android:name' => 'android.intent.action.MAIN'
                                intent.category 'android:name' => 'android.intent.category.LAUNCHER'
                              end
                            end
                          end
                        end
                      end
  end

  def resources *args
    @resources ||= Andrake::ResourceManager.new
    yield(@resources) if block_given?
    @resources
  end

  # finds activities for the app and concats them into #activities
  def find_activities
    # uhhh ... activity isn't letting me add another array to it?
    Andrake::Activity.find_all(self).each do |activity|
      activities << activity
    end
  end

  # get the path to files or directories relative to #root
  def path *files_or_directories
    File.join root, *files_or_directories
  end

  # build or 'compile' the Andrake app down to a 'typical' Android app
  def build
    puts "Building #{name} ..."
    require 'fileutils'
    if File.directory? path('.app')
      puts "Removing old build ..."
      FileUtils.rm_r path('.app')
    end
    puts "Creating new build ..."
    FileUtils.mkdir path('.app')
    FileUtils.mkdir path('.app', 'bin')
    FileUtils.mkdir path('.app', 'libs')
    File.open( path('.app', 'AndroidManifest.xml'), 'w') {|f| f << manifest_xml }

    FileUtils.mkdir path('.app', 'res') # should dynamically create the directories under res ...
    FileUtils.mkdir path('.app', 'res', 'values')

    File.open( path('.app', 'res', 'values', 'values.xml'), 'w') {|f| f << resources.to_xml }

    # for now, just copy layout files ...
    if File.directory? path('layout')
      FileUtils.cp_r path('layout'), path('.app', 'res', 'layout')
    end

    FileUtils.mkdir path('.app', 'src')
    FileUtils.mkdir path('.app', 'src', 'com')
    FileUtils.mkdir path('.app', 'src', 'com', 'andrake_testing')
    FileUtils.mkdir path('.app', 'src', 'com', 'andrake_testing', name.downcase)

    activities.each do |activity|
      File.open( path('.app', 'src', 'com', 'andrake_testing', 
                      name.downcase, "#{activity.name}.java"), 'w' ) do |f|
        f << activity.source
                      end
    end

    # finally, for now, let's copy over andrake/res to the directory
    # so we get an Ant script and stuff like that
    Dir[ File.join(File.dirname(__FILE__), '..', 'res', '*') ].each do |static_resource|
      FileUtils.cp static_resource, path('.app', File.basename(static_resource))
    end
  end

end
