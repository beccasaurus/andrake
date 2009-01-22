package com.android.basicui;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.*;

//import android.app.AlertDialog;
//import android.app.Dialog;

// this is literally a copy of BasicUI, cause i know it works ... trying to launch it as another view ...
public class AnotherView extends Activity implements OnClickListener {
	//private static final int ACTIVITY_EDIT=1;
	protected static TextView txt; 

	@Override
		public void onCreate(Bundle savedInstanceState) {
			super.onCreate(savedInstanceState);
			setContentView(R.layout.main);

			txt = (TextView) findViewById(R.id.txt);
			txt.setText("I AM ANOTHER VIEW updated!!!!");

			Button click_me = (Button) findViewById(R.id.my_button);
			click_me.setOnClickListener(this);
		}

	public void onClick(View v) {
		txt.setText("I AM ANOTHER VIEW clicked! ... trying to goto another view ...");
		// startActivityForResult(new Intent( this, UiResult.class ), ACTIVITY_EDIT);
	}

	protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
		//
	}

}
