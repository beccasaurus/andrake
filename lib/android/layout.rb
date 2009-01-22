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
    layout_xml = get_xml
    layout_xml = apply_css(layout_xml, stylesheets)
    layout_xml = androidify_xml_attributes(layout_xml)
  end

  # get the xml for the layout ... if not .xml, we have to convert -> xml
  def get_xml
    if file_path[/\.xml$/]
      File.read file_path
    elsif file_path[/\.haml$/]
      require 'haml'
      Haml::Engine.new(File.read(file_path)).to_html
    else
      raise "Don't know how to get XML for #{ file_path }"
    end
  end

  def read_css_file css_file
    if css_file[/\.sass$/]
      require 'sass'
      Sass::Engine.new(File.read(css_file)).to_css
    elsif css_file[/\.css$/]
      File.read css_file
    else
      ""
    end
  end

  def apply_css xml, css_files
    return xml if css_files.empty?

    require 'css_parser'
    parser = CssParser::Parser.new
    css_files.each do |css_file|
      parser.add_block! read_css_file(css_file)
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

    # make sure that something has xmlns:android="http://schemas.android.com/apk/res/android"
    doc.traverse_element do |first_element|
      if first_element.is_a?Hpricot::Elem
        unless first_element.attributes.keys.include?'xmlns:android'
          first_element.set_attribute 'xmlns:android', 'http://schemas.android.com/apk/res/android'
        end
        break
      end
    end

    doc.traverse_element {|e|
      if e.is_a?Hpricot::Elem
        
        # fix ID
        if e.attributes.keys.include?'id'
          id = e[:id]
          unless id.include? '@+id/'
            e.set_attribute 'id', "@+id/#{id}"
          end
        end

        # fix attributes (prepend 'android:')
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
      layout_xml_files = Dir[ File.join(dir, '**', '*.xml') ] + Dir[ File.join(dir, '**', '*.haml') ]
      layouts += layout_xml_files.map { |file_path| Android::Layout.new file_path }
      layouts
    end
  end

end
