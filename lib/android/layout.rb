# represents an Android layout .xml file
class Android::Layout

  attr_accessor :file_path

  def initialize file_path
    @file_path = file_path
  end

  def file_name
    File.basename file_path
  end

  def self.find_all directory
    # find directories with 'layout' in the name
    Dir[ File.join(directory, '**', '*layout*') ].directories.inject([]) do |layouts, dir|
      layout_xml_files = Dir[ File.join(dir, '**', '*.xml') ]
      layouts += layout_xml_files.map { |file_path| Android::Layout.new file_path }
      layouts
    end
  end

end
