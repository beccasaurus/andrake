# for parsing Java .java files
class JavaClass

  attr_accessor :file_path

  def initialize file_path
    @file_path = file_path
  end

  def class_name
    match = /public .*class (\w+)/.match(source_sans_comments)
    if match
      match.captures.first
    else
      match = /class (\w+)/.match(source_sans_comments)
      match.captures.first if match
    end
  end
  alias name class_name

  def package_name
    /package (.*);/.match(source_sans_comments).captures.first
  end
  alias package package_name

  def super_class
    match = /public .*class \w+ extends (\w+)/.match(source_sans_comments)
    if match then match.captures.first else nil end
  end
  alias superclass super_class
  alias parent super_class

  def source_code
    File.read file_path
  end
  alias source source_code

  def source_code_without_comments
    # regular expression to find all comments, from: http://ostermiller.org/findcomment.html
    regular_expression = Regexp.new('(/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+/)|(//.*)')
    source.gsub(regular_expression, '')
  end
  alias source_without_comments source_code_without_comments
  alias source_sans_comments source_code_without_comments

  def self.parse java_file
    JavaClass.new java_file
  end

end
