# represents an Android layout .xml file
class Android::Layout

  attr_accessor :file_path

  def initialize file_path
    @file_path = file_path
  end

  def file_name
    File.basename file_path
  end
  alias name file_name

  def render stylesheets
    layout_xml = File.read file_path
    layout_xml = androidify_xml_attributes(layout_xml)
  end

  def androidify_xml_attributes xml
    require 'hpricot'
    doc = Hpricot(xml)
    doc.traverse_element {|e|
      if e.is_a?Hpricot::Elem
        puts e.name
        e.attributes.each do |k, v|
          unless k.include?':'
            puts "  #{ k.inspect }"
            value = e.remove_attribute k
            puts "value => #{value.inspect}"
            puts "android:#{k}, #{value}"
            puts "e.set_attribute 'android:#{k}', '#{value}'"
            e.set_attribute "android:#{k}", "#{value}"
          end
        end
      end
    }
    fix_case_sensitive_tags(doc.to_s)
  end

  def fix_case_sensitive_tags xml
    {
      'textcolor='     => 'textColor=',
      '<linearlayout'  => '<LinearLayout',
      '<textview'      => '<TextView',
      '<button'        => '<Button',

      # fix these ... should use regexp?
      '</linearlayout'  => '</LinearLayout',
      '</textview'      => '</TextView',
      '</button'        => '</Button'

    }.each do  |k, v|
      xml.gsub! k, v
    end
    xml
  end

  def self.find_all directory
    # find directories with 'layout' in the name ... really, we should just do directly to res/layout
    Dir[ File.join(directory, '**', '*layout*') ].directories.inject([]) do |layouts, dir|
      layout_xml_files = Dir[ File.join(dir, '**', '*.xml') ]
      layouts += layout_xml_files.map { |file_path| Android::Layout.new file_path }
      layouts
    end
  end

end
