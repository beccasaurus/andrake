require File.dirname(__FILE__) + '/../spec_helper'

describe Andrake, 'HelloAndroid' do
  
  before do
    @app = Andrake::Application.new andrake_example(:HelloAndroid)
  end

  it 'should have a name' do
    @app.name.should == 'HelloAndroid'
  end

end
