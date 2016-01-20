package com.advanstar.cvc.cvcbeacons;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONObject;

public class PinConfirmation extends ActionBarActivity {
    public static final String PREFS_NAME = "CVCPrefsFile";
    Button btnClick;
    EditText pinNumber;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pin_confirmation);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        TextView tx = (TextView)findViewById(R.id.textview2);

        Typeface custom_font = Typeface.createFromAsset(getAssets(),  "fonts/Lato-Regular.ttf");

        tx.setTypeface(custom_font);

        pinNumber = (EditText)findViewById(R.id.edit_pin_number);

        btnClick = (Button) findViewById(R.id.submit_pin_button) ;


        btnClick.setOnClickListener(new Button.OnClickListener() {
            public void onClick(View v) {

                SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
                String phoneNumber = settings.getString("phone", "");

                // Instantiate the RequestQueue.
                RequestQueue queue = Volley.newRequestQueue(getApplicationContext());
                String url ="http://sms.as2.guidance.com/beaconsms/confirmpin/" + phoneNumber + "/" + pinNumber.getText().toString();
                Log.i("Volley",url);

                // Request a string response from the provided URL.
                StringRequest stringRequest = new StringRequest(com.android.volley.Request.Method.GET, url,
                        new Response.Listener<String>() {
                            @Override
                            public void onResponse(String response) {

                                try {

                                    JSONObject resp_json_obj = new JSONObject(response);

                                    Log.d("My App", resp_json_obj.toString());

                                    AlertDialog.Builder alertDialog = new AlertDialog.Builder(PinConfirmation.this);

                                    if(resp_json_obj.getInt("success") == 1) {
                                        alertDialog.setTitle("Success");
                                        alertDialog.setMessage(resp_json_obj.getString("message"));
                                        alertDialog.setPositiveButton("ok", new DialogInterface.OnClickListener() {
                                            @Override
                                            public void onClick(DialogInterface dialog, int which) {

                                                SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
                                                SharedPreferences.Editor editor = settings.edit();
                                                editor.putString("pin", pinNumber.getText().toString());
                                                editor.commit();

                                                startActivity(new Intent(PinConfirmation.this, BeaconListener.class));
                                            }
                                        });

                                    } else {
                                        alertDialog.setTitle("Error");
                                        alertDialog.setMessage(resp_json_obj.getString("message"));
                                        alertDialog.setPositiveButton("ok", new DialogInterface.OnClickListener() {
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

                                    AlertDialog.Builder alertDialog = new AlertDialog.Builder(PinConfirmation.this);
                                    alertDialog.setTitle("Error");
                                    alertDialog.setMessage("An error occurred. Please try again later.");
                                    alertDialog.setPositiveButton("ok", new DialogInterface.OnClickListener() {
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

}
