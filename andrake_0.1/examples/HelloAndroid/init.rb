puts "hello from init.rb"
puts "name => #{name}"

=begin
activities << Andrake::Activity.new(<<SOURCE)
  package com.android.helloagain;

  import android.app.Activity;
  import android.os.Bundle;
  import android.widget.TextView;

  public class AnotherActivity extends Activity
  {
      @Override
      public void onCreate(Bundle savedInstanceState)
      {
          super.onCreate(savedInstanceState);
          setContentView(R.layout.main);
      }
  }
SOURCE
=end

resources[:colors][:blue] = '#666'
# resources.colors.blue = '#0000ff'

resources do |res|

  res[:strings].merge!({
    :hello => 'Hello World from Andrake',
    :app_name => 'I Can Haz Test?'
  })

  res.colors :white  => '#ffffff',
             :red    => '#f00',
             :green  => '#f0f0',
             :yellow => '#ffffff00'
end

resources[:strings][:externalized_string] = 'Externalized String'

resources do |res|
  res.strings :externalized_string => 'overriden external string'
end
