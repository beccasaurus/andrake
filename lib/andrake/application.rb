class Andrake::Application

  attr_accessor :root, :name, :activities, :resources

  def initialize root_directory
    @root = root_directory
    @name = File.basename File.expand_path(root)
    @activities ||= []
    init
    find_activities
    load_xml_resources
  end

  def stylesheets
    Dir[ File.join(root, '**', '*.css') ] +
    Dir[ File.join(root, '**', '*.sass') ]
  end

  # resource directories that are NOT layouts or values
  def misc_resources
    misc = Dir[ File.join(root, 'res', '*') ]
    misc = misc.map {|dir| File.basename dir }
    misc = misc - %w( values value layout layouts )
    misc
  end

  # meh
  def delete_android_app
    FileUtils.rm_r path('.app') if File.directory? path('.app')
  end

  def load_xml_resources
    values = File.join root, 'res', 'values'
    if File.directory? values
      require 'hpricot'
      require 'activesupport'
      Dir[ File.join(values, '**', '*.xml' ) ].each do |xml_resource_file|
        doc = Hpricot(File.read(xml_resource_file))
        resource_node = ( doc / 'resources' )[0]
        resource_node.children.each do |node|
          if node.is_a?Hpricot::Elem
            tag_type  = node.name.pluralize
            tag_name  = node[:name]
            tag_value = node.innerText
            resources[tag_type.to_sym][tag_name.to_sym] = tag_value
          end
        end
      end
    end
  end

  def android_app
    if File.directory? path('.app')
      @android_app ||= Android::Application.new path('.app')
      @android_app.name = self.name
      @android_app
    else
      nil
    end
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
    if activities.empty?
      raise "Whoa, there's a problem ... we don't have any activities - we can't build a manifest.  #{ File.expand_path(root) }"
    end
    require 'builder'
    builder = Builder::XmlMarkup.new :indent => 2
    builder.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
    builder.manifest  'xmlns:android' => 'http://schemas.android.com/apk/res/android',
                      'package' => main_activity.package.downcase,
                      'android:versionCode' => '1',
                      'android:versionName' => '1.0.0' do |man|
      man.application 'android:label' => '@string/app_name' do |app|
        activities.each do |activity|

          if main_activity.name == activity.name

            app.activity 'android:name' => ".#{activity.name}", 'android:label' => '@string/app_name' do |act|
              act.tag! 'intent-filter' do |intent|
                intent.action   'android:name' => 'android.intent.action.MAIN'
                intent.category 'android:name' => 'android.intent.category.LAUNCHER'
              end
            end

          else
            app.activity 'android:name' => ".#{activity.name}" do
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

  def main_activity
    Android::Application.new(root).main_activity
  end

  # finds activities for the app and concats them into #activities
  # (just uses Android::Application's activities now)
  def find_activities
    @activities = Android::Application.new(root).activities
  end

  # get the path to files or directories relative to #root
  def path *files_or_directories
    File.join root, *files_or_directories
  end

  # build or 'compile' the Andrake app down to a 'typical' Android app
  def build
    raise "You can't build an automatically generated .app directory!" if File.basename(File.dirname(path('.'))) == '.app'

    require 'fileutils'
    if File.directory? path('.app')
      puts "Removing old build ..."
      FileUtils.rm_r path('.app')
    end
    puts "Creating new build ..."
    FileUtils.mkdir path('.app')
    FileUtils.mkdir path('.app', 'bin')
    FileUtils.mkdir path('.app', 'libs')

    if File.file? path('AndroidManifest.xml')
      FileUtils.cp path('AndroidManifest.xml'), path('.app', 'AndroidManifest.xml')
    else
      puts "Outputting Generated AndroidManifest ..."
      File.open( path('.app', 'AndroidManifest.xml'), 'w') {|f| f << manifest_xml }
    end

    FileUtils.mkdir path('.app', 'res') # should dynamically create the directories under res ...
    FileUtils.mkdir path('.app', 'res', 'values')

    File.open( path('.app', 'res', 'values', 'values.xml'), 'w') {|f| f << resources.to_xml }

    if misc_resources
      misc_resources.each do |misc_resource_dirname|
        FileUtils.cp_r path('res', misc_resource_dirname), path('.app', 'res', misc_resource_dirname)
      end
    end

    layouts.each do |layout|
      FileUtils.mkdir_p path('.app', 'res', 'layout')
      File.open( path('.app', 'res', 'layout', layout.name), 'w' ){|f| f << layout.render(stylesheets) }
    end

    classes.each do |klass|
      package_path = path( '.app', 'src', *(klass.package_name.split('.')) )
      FileUtils.mkdir_p package_path
      FileUtils.cp klass.file_path, File.join(package_path, "#{ klass.name }.java")
    end

    #activities.each do |activity|
    #  File.open( path('.app', 'src', 'com', 'andrake_testing', 
    #                  name.downcase, "#{activity.name}.java"), 'w' ) do |f|
    #    f << activity.source
    #                  end
    #end

    # finally, for now, let's copy over andrake/res to the directory
    # so we get an Ant script and stuff like that
    Dir[ File.join(File.dirname(__FILE__), '..', 'res', '*') ].each do |static_resource|
      FileUtils.cp static_resource, path('.app', File.basename(static_resource))
    end

    puts "BUILD: #{ android_app.build.inspect }"
    android_app
  end

end
