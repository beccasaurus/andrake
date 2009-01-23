require File.dirname(__FILE__) + '/../spec_helper'

describe 'Basic UI' do

  Dir[ File.join(example_dir, 'different_states_of_andrakeness', '*') ].each do |version_of_basicui|
    it "#{File.basename(version_of_basicui)} should build OK" do
      puts "Trying to build #{version_of_basicui}"
      Andrake::Application.new(version_of_basicui).should build_ok
    end
  end
  
end
