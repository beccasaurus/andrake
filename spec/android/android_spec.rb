require File.dirname(__FILE__) + '/../spec_helper'

describe Android do

  it 'should do stuff'

  it 'should do more stuff' do
    1.should == 1
  end

  it 'should have custom matchers' do
    5.should_not build_ok
  end

end
