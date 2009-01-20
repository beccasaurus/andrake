package com.android.basicui;

import android.app.Activity;
import android.os.Bundle;

//import android.content.Intent;
//import android.view.View;
//import android.widget.Button;
//import android.widget.EditText;

public class UiResult extends Activity {
    
	@Override
    public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		//Bundle extras = getIntent().getExtras();
        setContentView(R.layout.result);
    }
	
}