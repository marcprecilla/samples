package com.advanstar.cvc.cvcbeacons;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import org.altbeacon.beacon.*;
import org.altbeacon.beacon.powersave.BackgroundPowerSaver;
import org.json.*;

import java.util.ArrayList;
import java.io.IOException;

import android.util.Log;
import android.os.RemoteException;


import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import java.util.Collection;
import java.util.Date;

public class BeaconListener extends ActionBarActivity implements BeaconConsumer {
    public static final String PREFS_NAME = "CVCPrefsFile";
    Button btnClick;
    public static final String TAG = "BeaconsEverywhere";
    private BeaconManager beaconManager;
    public Region region = new Region("myBeacons", Identifier.parse("2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"), null, null);
    private BackgroundPowerSaver backgroundPowerSaver;
    public String phoneNumber;
    public String pinNumber;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_beacon_listener);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        TextView tx = (TextView)findViewById(R.id.textview3);

        Typeface custom_font = Typeface.createFromAsset(getAssets(), "fonts/Lato-Regular.ttf");

        tx.setTypeface(custom_font);

        SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
        phoneNumber = settings.getString("phone", "");
        pinNumber = settings.getString("pin", "");

        btnClick = (Button) findViewById(R.id.range_button) ;

        btnClick.setOnClickListener(new Button.OnClickListener() {
            public void onClick(View v) {
                String buttonText = btnClick.getText().toString();
                if(buttonText == "Start Searching") {
                    btnClick.setText("Stop Searching");
                    try {
                        beaconManager.startMonitoringBeaconsInRegion(region);
                    } catch (RemoteException e) {
                        e.printStackTrace();
                    }
                } else {
                    btnClick.setText("Start Searching");
                    try {
                        beaconManager.stopMonitoringBeaconsInRegion(region);
                        beaconManager.stopRangingBeaconsInRegion(region);
                    } catch (RemoteException e) {
                        e.printStackTrace();
                    }
                }
            }
        });

        // Instantiate the RequestQueue.
        RequestQueue queue = Volley.newRequestQueue(getApplicationContext());
        String url ="http://sms.as2.guidance.com/beaconsms/getallbeacons";

        // Request a string response from the provided URL.
        StringRequest stringRequest = new StringRequest(com.android.volley.Request.Method.GET, url,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {

                        ArrayList new_beacon_range_data = new ArrayList();

                        try {
                            JSONArray json_beacon_range_data = new JSONArray(response);

                            for (int i = 0; i < json_beacon_range_data.length(); i++) {
                                JSONObject current_item = json_beacon_range_data.getJSONObject(i);
                                BeaconData beacon_data_item = new BeaconData(current_item.getString("id"),current_item.getInt("distance"),current_item.getInt("proximity"));
                                new_beacon_range_data.add(beacon_data_item);
                            }

                        } catch (JSONException e) {
                            Log.i("JSON", "That didn't work!");
                        }


                        try {
                            SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
                            SharedPreferences.Editor editor = settings.edit();
                            editor.putString("beacon_range_data", ObjectSerializer.serialize(new_beacon_range_data));
                            editor.commit();
                        } catch (IOException e) {
                            Log.i("IO", "That didn't work!!");
                            e.printStackTrace();
                        }

                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Log.i("Volley", "That didn't work!");
            }
        });
        // Add the request to the RequestQueue.
        queue.add(stringRequest);


        backgroundPowerSaver = new BackgroundPowerSaver(this);

        beaconManager = BeaconManager.getInstanceForApplication(this);

        beaconManager.getBeaconParsers().add(new BeaconParser()
                .setBeaconLayout("m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25"));

        beaconManager.bind(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        beaconManager.unbind(this);
    }

    @Override
    public void onBeaconServiceConnect() {

        beaconManager.setMonitorNotifier(new MonitorNotifier() {
            @Override
            public void didEnterRegion(Region region) {
                try {
                    Log.d(TAG, "didEnterRegion");
                    beaconManager.startRangingBeaconsInRegion(region);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void didExitRegion(Region region) {
                try {
                    Log.d(TAG, "didExitRegion");
                    beaconManager.stopRangingBeaconsInRegion(region);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void didDetermineStateForRegion(int i, Region region) {

            }
        });

        beaconManager.setRangeNotifier(new RangeNotifier() {
            @Override
            public void didRangeBeaconsInRegion(Collection<Beacon> beacons, Region region) {
                for(Beacon oneBeacon : beacons) {
                    String beaconUuid = oneBeacon.getId1() + "-" + oneBeacon.getId3();
                    BeaconData targetBeaconData = getBeaconData(beaconUuid);
                    if(oneBeacon.getDistance() < targetBeaconData.getDistance() && canAskForBeaconMessage(beaconUuid)) {

                        // Instantiate the RequestQueue.
                        RequestQueue queue = Volley.newRequestQueue(getApplicationContext());
                        String url ="http://sms.as2.guidance.com/beaconsms/sendsms/" + phoneNumber + "/" + beaconUuid + "/" + pinNumber;

                        // Request a string response from the provided URL.
                        StringRequest stringRequest = new StringRequest(com.android.volley.Request.Method.GET, url,
                                new Response.Listener<String>() {
                                    @Override
                                    public void onResponse(String response) {

                                        Log.i("Advanstar","Message response: " + response);
                                    }
                                }, new Response.ErrorListener() {
                            @Override
                            public void onErrorResponse(VolleyError error) {
                                Log.i("Volley", "That didn't work!");
                            }
                        });
                        // Add the request to the RequestQueue.
                        queue.add(stringRequest);

                        Log.d(TAG, "distance: " + oneBeacon.getDistance() + " id:" + oneBeacon.getId1() + "/" + oneBeacon.getId2() + "/" + oneBeacon.getId3());
                    }
                }
            }
        });


        // Instantiate the RequestQueue.
        RequestQueue queue = Volley.newRequestQueue(getApplicationContext());
        String url ="http://sms.as2.guidance.com/beaconsms/beacon-uuid";

        // Request a string response from the provided URL.
        StringRequest stringRequest = new StringRequest(com.android.volley.Request.Method.GET, url,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {

                        region = new Region("myBeacons", Identifier.parse(response), null, null);
                        try {
                            beaconManager.startMonitoringBeaconsInRegion(region);
                        } catch (RemoteException e) {
                            e.printStackTrace();
                        }

                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Log.i("Volley", "That didn't work!");
            }
        });
        // Add the request to the RequestQueue.
        queue.add(stringRequest);



    }

    public BeaconData getBeaconData(String id) {
        BeaconData targetBeaconData = new BeaconData("1",1,1);
        SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
        ArrayList beaconRangeData = new ArrayList();
        try {
            beaconRangeData = (ArrayList) ObjectSerializer.deserialize(settings.getString("beacon_range_data", ObjectSerializer.serialize(new ArrayList())));
            for(Object item : beaconRangeData){
                BeaconData item_as_beacon_data = BeaconData.class.cast(item);
                //item_as_beacon_data.writeToLog();
                if(id == item_as_beacon_data.getID()) {
                    targetBeaconData = item_as_beacon_data;
                    break;
                }
            }
        } catch (Throwable t) {
            Log.e("My App", "Get Beacon Data: \"" + t.toString() + "\"");
        }
        return targetBeaconData;
    }

    public boolean canAskForBeaconMessage(String id) {
        long WAIT_PERIOD_IN_MILLIS=30000;//30 seconds
        SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
        Date last_reset_date = new Date(settings.getLong("time", 0));

        Date now = new Date();
        if((now.compareTo(last_reset_date)) < 0) {
            return false;
        } else {
            long t= now.getTime();
            Date next_reset_date = new Date(t + WAIT_PERIOD_IN_MILLIS);

            SharedPreferences.Editor editor = settings.edit();
            editor.putLong("time", next_reset_date.getTime());
            editor.commit();
            return true;
        }

    }


}
