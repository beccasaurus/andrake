require File.dirname(__FILE__) + '/../spec_helper'

describe Android, 'HelloAndroid' do

  before do
    @app = Android::Application.new android_example(:HelloAndroid)
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

  it 'should know the package names of the classes'

  it 'should have 1 layout'

  it 'should have string values'

  it 'should have 1 graphic'

end
