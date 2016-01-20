package com.advanstar.cvc.cvcbeacons;

import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import android.graphics.Typeface;

import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import android.app.Dialog;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;

import android.app.DownloadManager.Request;
import android.net.http.*;

import android.util.Log;

import com.android.volley.RequestQueue;
import com.android.volley.toolbox.Volley;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.Response;
import com.android.volley.VolleyError;

import org.json.*;

import android.content.Intent;
import android.content.SharedPreferences;



public class MainActivity extends ActionBarActivity {
    public static final String PREFS_NAME = "CVCPrefsFile";
    Button btnClick;
    EditText phoneNumber;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        TextView tx = (TextView)findViewById(R.id.textview1);

        Typeface custom_font = Typeface.createFromAsset(getAssets(),  "fonts/Lato-Regular.ttf");

        tx.setTypeface(custom_font);

        phoneNumber = (EditText)findViewById(R.id.edit_phone_number);

        btnClick = (Button) findViewById(R.id.submit_button) ;
        btnClick.setOnClickListener(new Button.OnClickListener() {
            public void onClick(View v) {


                // Instantiate the RequestQueue.
                RequestQueue queue = Volley.newRequestQueue(getApplicationContext());
                String url ="http://sms.as2.guidance.com/beaconsms/getpin/" + phoneNumber.getText().toString() + "/1/1";

                // Request a string response from the provided URL.
                StringRequest stringRequest = new StringRequest(com.android.volley.Request.Method.GET, url,
                        new Response.Listener<String>() {
                            @Override
                            public void onResponse(String response) {

                                try {

                                    JSONObject resp_json_obj = new JSONObject(response);

                                    Log.d("My App", resp_json_obj.toString());

                                    AlertDialog.Builder alertDialog = new AlertDialog.Builder(MainActivity.this);

                                    if(resp_json_obj.getInt("success") == 1) {
                                        alertDialog.setTitle("Success");
                                        alertDialog.setMessage(resp_json_obj.getString("message"));
                                        alertDialog.setPositiveButton("ok", new OnClickListener() {
                                            @Override
                                            public void onClick(DialogInterface dialog, int which) {

                                                SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
                                                SharedPreferences.Editor editor = settings.edit();
                                                editor.putString("phone", phoneNumber.getText().toString());
                                                editor.commit();

                                                startActivity(new Intent(MainActivity.this, PinConfirmation.class));
                                            }
                                        });

                                    } else {
                                        alertDialog.setTitle("Error");
                                        alertDialog.setMessage(resp_json_obj.getString("message"));
                                        alertDialog.setPositiveButton("ok", new OnClickListener() {
                                            @Override
                                            public void onClick(DialogInterface dialog, int which) {
                                                // Whatever...
                                            }
                                        });

                                    }

                                    alertDialog.create();
                                    alertDialog.show();


                                } catch (Throwable t) {
                                    Log.e("My App", "Could not parse malformed JSON: \"" + response + "\"");

                                    AlertDialog.Builder alertDialog = new AlertDialog.Builder(MainActivity.this);
                                    alertDialog.setTitle("Error");
                                    alertDialog.setMessage("An error occurred. Please try again later.");
                                    alertDialog.setPositiveButton("ok", new OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface dialog, int which) {
                                            // Whatever...
                                        }
                                    });
                                    alertDialog.create();
                                    alertDialog.show();

                                }

                                //Log.i("myTab","Response is: "+ response.substring(0,500));
                            }
                        }, new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        Log.i("myTab", "That didn't work!");
                    }
                });
                // Add the request to the RequestQueue.
                queue.add(stringRequest);

            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
