$:.unshift File.dirname(__FILE__)
%w( rubygems ).each {|lib| require lib }

class Andrake

end

class Andrake::App
  attr_accessor :root, :name, :activities

  def initialize root_directory
    @root = root_directory
    @name = File.basename root
    @activities ||= []
    init
    find_activities

    puts "#{name} loaded with #{activities.length} activities: #{ activities.map {|a| a.name}.inspect }"
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
