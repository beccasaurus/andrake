root = File.dirname(__FILE__) + '/../'
require File.join(root, 'lib', 'android')
require File.join(root, 'lib', 'andrake')
require 'spec'

Spec::Runner.configure do |config|

  # Spec Helper methods
  
  def root
    File.dirname(__FILE__) + '/../'
  end

  def example_dir
    File.join root, 'examples'
  end

  def examples
    Dir[ File.join(example_dir, '*/*') ].directories
  end

  def android_examples
    Dir[ File.join(example_dir, 'android', '*') ].directories
  end

  def andrake_examples
    Dir[ File.join(example_dir, 'andrake', '*') ].directories
  end

  def android_example name
    File.join example_dir, 'android', name.to_s
  end

  def andrake_example name
    File.join example_dir, 'andrake', name.to_s
  end

  def print_spec_helpers
    %w( root example_dir examples android_examples andrake_examples ).each do |method|
      puts "#{method} => #{send(method).inspect}"
    end
  end

end
