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

  # the root directory where we'll be generating stuff to test
  def generation_path_root
    root = File.join File.dirname(__FILE__), '..', '..'
    path = File.join root, 'examples', 'simplegen', 'generate_here'
    File.expand_path path
  end

  # gets the path where we'll generate stuff
  def generation_path name = 'generated-by-specs'
    File.join generation_path_root, name.to_s
  end

  before do
    SimpleGen.template_directories = []
    Dir[ File.join(generation_path_root, '*') ].select {|x| File.directory? x }.each do |generated_dir|
      FileUtils.rm_f generated_dir
    end
  end

  it 'should read available generators from template directories' do
    SimpleGen.template_directories.should be_empty
    SimpleGen.templates.should be_empty

    SimpleGen.template_directories << template_dir
    SimpleGen.templates.should_not be_empty
    SimpleGen.templates.first.should be_a_kind_of(SimpleGen::Template)
    SimpleGen.templates.map {|x| x.name }.should include('app')
    app_template = SimpleGen.templates.find {|t| t.name == 'app' }
    SimpleGen[:app].root.should == app_template.root # helper shortcut, if helpful
  end

  it "should generate 'app' correctly" do
    SimpleGen.template_directories << template_dir # template-dir1
    File.exist?(File.join(generation_path, 'foo.xml')).should be_false
    SimpleGen[:app].generate! generation_path, :var => "RUBY VARIABLE"
    #File.exist?(File.join(generation_path, 'foo.xml')).should be_true
    #File.read(File.join(generation_path, 'foo.xml')).should include('hello from RUBY VARIABLE')
  end

  it 'filter should work properly' do
    # ruby comes with ERB so we should always have it defined
    SimpleGen.filters.keys.should include(:erb)
    SimpleGen.filters[:erb].should be_a_kind_of(SimpleGen::Filter)
  end

  it 'should know how to render a file ... and we should have SimpleGen::Filters' do
    SimpleGen.template_directories << template_dir # template-dir1
    SimpleGen[:app].files.should_not be_empty
    SimpleGen[:app].files.first.should be_a_kind_of(SimpleGen::Template::File)

    SimpleGen.filter_exists?(:erb).should be_true
    SimpleGen.filter_exists?('erb').should be_true
    SimpleGen.filter_exists?(:_erb).should be_true
    SimpleGen.filter_exists?('_erb').should be_true
    
    SimpleGen[:app].files.first.filename.should == 'foo.xml._erb'
    SimpleGen[:app].files.first.path.should include('app/foo.xml._erb')
    SimpleGen[:app].files.first.basename.should == 'foo.xml._erb'
    SimpleGen[:app].files.first.extensions.should == ['xml', '_erb']
    SimpleGen[:app].files.first.filename_without_extension.should == 'foo'
    SimpleGen[:app].files.first.nonfilter_extensions.should == ['xml']
    SimpleGen[:app].files.first.filter_extensions.should == ['_erb']
    #SimpleGen[:app].files.first.

    #SimpleGen[:app].files.first.filters.length.should == 1
    #SimpleGen[:app].files.first.filters.first.should be_a_kind_of(SimpleGen::Filter)
    #SimpleGen[:app].files.first.filters.first.name.downcase.should == 'erb'
  end

end
