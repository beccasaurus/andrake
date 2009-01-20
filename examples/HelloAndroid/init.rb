puts "hello from init.rb"
puts "name => #{name}"

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
