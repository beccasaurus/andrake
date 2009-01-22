package com.andrake_testing.helloandroid;

import android.app.Activity;
import android.os.Bundle;

import android.widget.TextView;

public class HelloAndroid extends Activity
{
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
	TextView tv = new TextView(this);
	tv.setText("just testing");
	TextView tv2 = new TextView(this);
	tv2.setText("just testing some more");
	//tv.setText("Hello from Android, without using Eclipse!");
        setContentView(R.layout.main);
    }
}
