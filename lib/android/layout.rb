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
    layout_xml = apply_css(layout_xml, stylesheets)
    layout_xml = androidify_xml_attributes(layout_xml)
  end

  def apply_css xml, css_files
    return xml if css_files.empty?

    require 'css_parser'
    parser = CssParser::Parser.new
    css_files.each do |css_file|
      parser.add_block! File.read(css_file)
    end

    require 'hpricot'
    doc = Hpricot(xml)
    parser.each_selector do |selector, declarations, specificity|
      doc.search(selector.downcase).each do |element|
        if element.is_a? Hpricot::Elem
          rules = declarations.split(';').map {|r| r.split(':').map {|x| x.strip }}
          rules.each do |attribute, value|
            element.set_attribute attribute, value
          end
        end
      end
    end

    doc.to_s
  end

  def androidify_xml_attributes xml
    require 'hpricot'
    doc = Hpricot(xml)
    doc.traverse_element {|e|
      if e.is_a?Hpricot::Elem
        e.attributes.each do |k, v|
          unless k.include?':'
            value = e.remove_attribute k
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
