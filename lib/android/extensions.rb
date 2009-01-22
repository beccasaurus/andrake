# little helpful class extensions
class Array
  def directories
    select {|x| File.directory? x }
  end
  def files
    select {|x| File.file? x }
  end
end
