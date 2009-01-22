require File.dirname(__FILE__) + '/../spec_helper'

describe Andrake, 'HelloAndroid' do
  
  before do
    @app = Andrake::Application.new andrake_example(:HelloAndroid)
  end

  it 'should have a name' do
    @app.name.should == 'HelloAndroid'
  end

  it 'should have 1 Java class' do
    @app.classes.length.should == 1
  end

  it 'should have the name/package of the Java class' do
    @app.classes.first.name.should == 'HelloAndroid'
    @app.classes.first.package.should == 'com.andrake_testing.helloandroid'
  end

  it 'should have 1 layout' do
    @app.layouts.length.should == 1
    @app.layouts.first.should be_a_kind_of(Android::Layout)
    @app.layouts.first.file_name.should == 'main.xml'
  end

end
