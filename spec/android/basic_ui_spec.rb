require File.dirname(__FILE__) + '/../spec_helper'

describe Android, 'BasicUI' do

  before do
    @app = Android::Application.new android_example(:BasicUI)
    FileUtils.rm @app.apk_file if @app.apk_file
  end

  it 'should have a name' do
    @app.name.should == 'BasicUI'
  end

  it 'should have 4 Java classes' do
    @app.classes.length.should == 4
  end

  it 'should have the names of the Java classes' do
    %w( BasicUI R UiResult AnotherView ).each do |klass|
      @app.classes.map(&:name).should include(klass)
    end
  end

  it 'should have 3 activities' do
    @app.activities.length.should == 3
  end

  it 'should know which activity is the main activity' do
    @app.main_activity.should be_a_kind_of(Android::Activity)
    @app.main_activity.name.should == 'BasicUI'
  end

end
