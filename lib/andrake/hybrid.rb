# When I started coding, I had different ideas about
# what Android versus Andrake applications look like
#
# Now, I want to be able to start with an 'Android' 
# application and DRY things up and seamlessly get 
# to what might be called an 'Andrake' application
#
# For now, to get this done, I'm going to say that 
# every Android || Andrake application is really 
# just an Andrake::Hybrid application.
#
# meh, I'll figure it out!
#
# For right now, this is a bit of a hack so I can 
# do some useful prototyping.
#
class Andrake::Hybrid

  attr_accessor :root

  def initialize root_directory = '.'
    @root = root_directory
  end

  # returns a string with information about this application
  def info
    resource_string = andrake_app.resources.resources.keys.map do |resource_key|
    "  #{resource_key} resources: #{ andrake_app.resources[resource_key].keys.join(', ') }"
    end.join("\n")
    %[
Android Application information:

  name: #{ name }
  #{classes.length} classes: #{classes.map(&:name).join(', ')}
  #{activities.length} activities: #{activities.map(&:name).join(', ')}
  #{layouts.length} layouts: #{layouts.map(&:name).join(', ')}
  APK: #{apk_file}
#{ resource_string }

]
  end

  def method_missing name, *args
    android_app.send name, *args
  end

  def path *args
    File.join root, *args
  end

  def name
    (File.exists?path('AndroidManifest.xml')) ? android_app.name : andrake_app.name
  end

  def android_app
    @android_app ||= Android::Application.new(root)
  end

  def andrake_app
    @andrake_app ||= Andrake::Application.new(root)
  end

end
