// package com.android.basicui; <--- not necessary, auto-added to all activities

// import android.app.Activity; <-- not necessary

// short version
import_android view.View, content.Intent, os.Bundle, widget.*

/* long version:
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.*;
*/

public class BasicUI extends Activity implements OnClickListener {
	private static final int ACTIVITY_EDIT=1;

	protected static TextView txt; 

	@Override
		public void onCreate(Bundle savedInstanceState) {
			super.onCreate(savedInstanceState);

			// set UI element instances
			//Button _my_button = (Button) findViewById(R.id.my_button);

			// set the view for this particular activity - it's called 'main'
			setContentView(R.layout.main);

			// this stuff ONLY WORKS (so far as i can tell) **AFTER** setContentView
			//TextView txt = (TextView) findViewById(R.id.txt);
			txt = (TextView) findViewById(R.id.txt);
			txt.setText("updated!!!!");

			Button click_me = (Button) findViewById(R.id.my_button);

			click_me.setOnClickListener(this);

			/*
			   click_me.setOnClickListener(new View.OnClickListener(){
			   public void onClick(View v){
			   txt.setText("clicked! ... trying to goto another view ...");

			   Intent i = new Intent(this, UiResult.class);
			   startActivityForResult(i, 2);

			//Intent i = new Intent( BasicUI.this, UiResult.class );
			//i.putExtra("foo", "bar");
			//startActivityForResult(i, 0);
			//startActivityForResult( i, 12345 ); // where 0 is the "activity" ... an ENUM value

			//Dialog foo = new AlertDialog.Builder(BasicUI.this)
			//.setTitle("title from INLINE!")
			//.setMessage("INLINE messsage!")
			//.create();
			//foo.show();
			   }
			   });
			   */
		}

	public void onClick(View v) {
		//Dialog foo = new AlertDialog.Builder(BasicUI.this)
		//.setTitle("title")
		//.setMessage("messsage!")
		//.create();
		//foo.show();

		txt.setText("clicked! ... trying to goto another view ...");

		startActivityForResult(new Intent( this, UiResult.class ), ACTIVITY_EDIT);

		//Intent i = new Intent(BasicUI.this, UiResult.class);
		//startActivityForResult(i, ACTIVITY_EDIT);

		//startActivityForResult(
		//       new Intent(Intent.ACTION_PICK,
		//       new Uri("content://contacts")),
		//       PICK_CONTACT_REQUEST);
	}

	protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
		//
	}

}
