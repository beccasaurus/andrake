require File.dirname(__FILE__) + '/../spec_helper'

# this should eventually be moved into a separate javaclass gem
describe JavaClass do

  def example name
    File.join File.dirname(__FILE__), 'examples', "#{name}.java"
  end

  it 'should have source_code_without_comments' do
    java = JavaClass.new example(:WikiNotes)
    comment = 'The WikiNotes activity is the default handler for displaying individual'
    java.source_code.should include(comment)
    java.source_code_without_comments.should_not include(comment)
  end

  it 'should get package names' do
    JavaClass.new(example(:WikiNotes)).package.should == 'com.google.android.wikinotes'
    JavaClass.new(example(:WikiNotes)).package_name.should == 'com.google.android.wikinotes'
  end

  it 'should have a full name (including package)'

  it 'should get superclass name' do
    JavaClass.new(example(:WikiNotes)).parent.should == 'Activity'
    JavaClass.new(example(:WikiNotes)).superclass.should == 'Activity'
  end

  it 'should get class names' do
    JavaClass.new(example(:WikiNotes)).name.should == 'WikiNotes'
    JavaClass.new(example(:WikiNotes)).class_name.should == 'WikiNotes'
  end

  it 'should get methods names'

end
