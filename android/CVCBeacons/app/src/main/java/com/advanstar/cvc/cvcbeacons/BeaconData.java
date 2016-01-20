package com.advanstar.cvc.cvcbeacons;

import android.util.Log;
import java.io.Serializable;

/**
 * Created by marc on 1/1/16.
 */
public class BeaconData implements Serializable {
    private String id;
    private int distance, proximity;

    public BeaconData(String new_id, int new_distance, int new_proximity) {
        id = new_id;
        distance = new_distance;
        proximity = new_proximity;
    }

    public String getID() {
        return id;
    }

    public int getDistance() {
        return distance;
    }

    public int getProximity() {
        return proximity;
    }

    public void writeToLog() {
        Log.i("BeaconData", id + ":" + String.valueOf(distance) + ":" + String.valueOf(proximity));
    }

}


