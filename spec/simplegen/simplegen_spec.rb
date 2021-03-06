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

  def clean_tmp_dir
    FileUtils.rm_r generation_path if File.directory?(generation_path)
  end

  before do
    SimpleGen.template_directories = []
    Dir[ File.join(generation_path_root, '*') ].select {|x| File.directory? x }.each do |generated_dir|
      FileUtils.rm_f generated_dir
    end
    clean_tmp_dir
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
    clean_tmp_dir
    SimpleGen.template_directories << template_dir # template-dir1
    File.exist?(File.join(generation_path, 'foo.xml')).should be_false
    SimpleGen[:app].generate! generation_path, :var => "RUBY VARIABLE"
    File.exist?(File.join(generation_path, 'foo.xml')).should be_true
    File.read(File.join(generation_path, 'foo.xml')).should include('hello from RUBY VARIABLE')
  end

  it 'should generate empty directories OK' do
    clean_tmp_dir
    SimpleGen.template_directories << template_dir # template-dir1
    File.exist?(File.join(generation_path, 'empty_dir')).should be_false
    SimpleGen[:empty_dirs].generate! generation_path
    File.exist?(File.join(generation_path, 'empty_dir')).should be_true
  end

  it 'templates should be override other templates' do
    clean_tmp_dir
    SimpleGen.template_directories << template_dir # template-dir1
    SimpleGen.template_directories << template_dir('template-dir2') # template-dir1
    SimpleGen[:empty_dirs].generate! generation_path
    File.exist?(File.join(generation_path, 'empty_dir')).should be_false
    File.exist?(File.join(generation_path, 'P0WNED')).should be_true
  end

  it 'should support dynamic directory naming' do
    clean_tmp_dir
    SimpleGen.template_directories << template_dir # template-dir1
    File.exist?(File.join(generation_path, '_chunky', 'bacon_', 'foo')).should be_false
    SimpleGen[:dynamic_dirname].generate! generation_path, :dynamic => 'chunky/bacon'
    File.exist?(File.join(generation_path, '_chunky', 'bacon_', 'foo')).should be_true
  end

  it 'should suppor dynamic file naming' do
    clean_tmp_dir
    SimpleGen.template_directories << template_dir # template-dir1
    File.exist?(File.join(generation_path, 'hello_there_file.rb')).should be_false
    SimpleGen[:dynamic_filename].generate! generation_path, :dynamic => 'hello_there'
    File.exist?(File.join(generation_path, 'hello_there_file.rb')).should be_true
    File.read(File.join(generation_path, 'hello_there_file.rb')).should include('my name should be hello_there_file.rb')
  end

  it "should generate template/with/many/dirs/... correctly" do
    # many_dirs => many/dirs/hello.txt.erb
    clean_tmp_dir
    SimpleGen.template_directories << template_dir # template-dir1
    File.exist?(File.join(generation_path, 'many')).should be_false
    File.exist?(File.join(generation_path, 'many', 'dirs')).should be_false
    SimpleGen[:many_dirs].generate! generation_path
    File.exist?(File.join(generation_path, 'many', 'dirs')).should be_true
    File.exist?(File.join(generation_path, 'many', 'dirs', 'hello.txt')).should be_true
    File.read(File.join(generation_path, 'many', 'dirs', 'hello.txt')).should 
      include("x => 5")
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

    SimpleGen[:app].files.first.source.should == "hello from <%= @var %>\n"
    SimpleGen[:app].files.first.render.should == "hello from \n" # missing variable
    SimpleGen[:app].files.first.render(:var => 5).should == "hello from 5\n"
  end

end
