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
