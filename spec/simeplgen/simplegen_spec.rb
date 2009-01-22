require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../../lib/simplegen'

describe SimpleGen do

  # get the path to an example template directory
  def template_dir name = 'template-dir1'
    root = File.join File.dirname(__FILE__), '..', '..'
    path = File.join root, 'examples', 'simplegen', name.to_s
    File.expand_path path
  end

  # get the path to an example directory
  def example name, template_dir_name = 'template-dir1'
    File.join template_dir(template_dir_name), name.to_s
  end

  before do
    SimpleGen.template_directories = []
  end

  it 'should read available generators from template directories' do
    SimpleGen.template_directories.should be_empty
    SimpleGen.templates.should be_empty

    SimpleGen.template_directories << template_dir
    SimpleGen.templates.should_not be_empty
    SimpleGen.templates.first.should be_a_kind_of(SimpleGen::Template)
    SimpleGen.templates.map {|x| x.name }.should include('app')
  end

  it "should generate 'app' correctly"

end
