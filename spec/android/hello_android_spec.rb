require File.dirname(__FILE__) + '/../spec_helper'

describe Android, 'HelloAndroid' do

  before do
    @app = Android::Application.new android_example(:HelloAndroid)
    FileUtils.rm @app.apk_file if @app.apk_file
  end

  it 'should have a name' do
    @app.name.should == 'HelloAndroid'
  end

  it 'should have 2 Java classes' do
    @app.classes.length.should == 2
  end

  it 'should have the names of the Java classes' do
    @app.classes.map(&:name).should include('R')
    @app.classes.map(&:name).should include('HelloAndroid')
  end

  it 'should have 1 Activity class' do
    @app.activities.length.should == 1
    @app.activities.first.name.should == 'HelloAndroid'
    @app.activities.first.should be_a_kind_of(Android::Activity)
    @app.activities.first.should be_a_kind_of(Android::JavaClass)
  end

  it 'should have 1 Resource class' do
    @app.resource_class.name.should == 'R'
    @app.resource_class.should be_a_kind_of(Android::JavaClass)
  end

  it 'should know the package names of the classes' do
    @app.activities.first.package.should == 'com.android.hello'
  end

  it 'should have 1 layout' do
    @app.layouts.length.should == 1
    @app.layouts.first.should be_a_kind_of(Android::Layout)
    @app.layouts.first.file_name.should == 'main.xml'
  end

  it 'should have string values'

  it 'should have 1 graphic'

  it 'should be buildable' do
    @app.apk_file.should be_nil
    @app.build.should be_true
    @app.apk_file.should_not be_nil
  end

end
