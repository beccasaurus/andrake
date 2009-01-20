$:.unshift File.dirname(__FILE__)
%w( rubygems activeresource ).each {|lib| require lib }

class Andrake

end

class Andrake::App
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

class Andrake::Activity
  attr_accessor :name, :source
  
  # source = the source code of an activity ... we should support files!
  def initialize source
    @source = source
    @name   = /class (\w+) extends Activity/.match(source).captures.first
  end

  def to_s
    "<Andrake::Activity #{name} />"
  end

  # finds all activities for an Andrake::App (from the file system)
  def self.find_all app
    Dir[app.path '*.java'].inject([]) do |all, this|
      all << Andrake::Activity.new(File.read(this)) if is_an_activity?(this)
      all
    end
  end

  # returns true / false for whether the given file is an Activity
  def self.is_an_activity? file
    return false unless File.file? file
    return /class (\w+) extends Activity/.match(File.read(file)) != nil
  end

  # returns the name of the activity (from the source, should match the filename)
  def self.activity_name file
    /class (\w+) extends Activity/.match(File.read(file)).captures.first
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
