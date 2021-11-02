#Electrical System
var electricsystem=func{
    	var master_bat = getprop("/controls/switches/master-bat");
    	var master_alt_l = getprop("/controls/switches/master-alt_l");
    	var master_alt_r = getprop("/controls/switches/master-alt_r");
	var battery_status = getprop("/systems/electrical/battery-status");
	var new_battery_status = battery_status;
	var external_volts = 0;
	var avionics_status = getprop("/controls/switches/master-avionics");

	# external power source connected
    if (getprop("/controls/electric/external-power"))
    {
        external_volts = 28;
    }
	
	var engine_l_rpm = getprop("/engines/engine[0]/rpm");
	var engine_r_rpm = getprop("/engines/engine[1]/rpm");

	var ideal_rpm = 500;	
	var ideal_volts = 28;
	var ideal_amps = 60;
	var factor_l = engine_l_rpm/ideal_rpm;
	if (factor_l > 1.0) {
		factor_l = 1.0;
	}

	var factor_r = engine_r_rpm/ideal_rpm;
	if (factor_r > 1.0) {
		factor_r = 1.0;
	}


 	var alternator_l_volts = ideal_volts * factor_l;
	var alternator_l_amps = ideal_amps * factor_l;
 
 	var alternator_r_volts = ideal_volts * factor_r;
	var alternator_r_amps = ideal_amps * factor_r;


       if ( master_alt_l == 0 ){
 		var alternator_l_volts = 0;
		var alternator_l_amps = 0;
	}

       if ( master_alt_r == 0 ){
 		var alternator_r_volts = 0;
		var alternator_r_amps = 0;
	}


    # determine power source
    	var bus_volts = 0.0;
	var battery_volts = (24.0 * battery_status)/100;
    	var power_source = nil;	


    if ( master_bat ) {
        bus_volts = battery_volts;        
	power_source = "battery";
#        gui.popupTip("Battery is power source!");
    }
    if ( master_alt_l and ( alternator_l_volts > bus_volts) ) {
        bus_volts = alternator_l_volts;
        power_source = "alternator_l";
#        gui.popupTip("Alternator is power source!");
        #print("Alternator is power source!");
    }
    if ( master_alt_r and ( alternator_r_volts > bus_volts) ) {
        bus_volts = alternator_r_volts;
        power_source = "alternator_r";
#        gui.popupTip("Alternator is power source!");
        #print("Alternator is power source!");
    }
    if ( external_volts > bus_volts ) {
        bus_volts = external_volts;
        power_source = "external";
#        gui.popupTip("external is power source!");
    }

    if ( power_source == "battery" ) {
		new_battery_status = battery_status - 0.0001;
	}

    if ( power_source == "alternator_l" or power_source == "alternator_r" or power_source == "external") {
		new_battery_status = battery_status + 0.0001;
		if ( new_battery_status > 100.0 ) {
			new_battery_status = 100.0;
		}
	}

    # Flaps
    if ( getprop("/controls/circuit-breakers/flaps") ) {
        setprop("/systems/electrical/outputs/flaps", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/flaps", 0.0);
    }

    # Comm-Nav
    if ( getprop("/controls/circuit-breakers/radio1") and avionics_status ) {
        setprop("/systems/electrical/outputs/comm[0]", bus_volts);
        setprop("/systems/electrical/outputs/nav[0]", bus_volts);
        setprop("/systems/electrical/outputs/audio-panel", bus_volts);

    } else {
        setprop("/systems/electrical/outputs/comm[0]", 0.0);
        setprop("/systems/electrical/outputs/nav[0]", 0.0);
        setprop("/systems/electrical/outputs/audio-panel", 0.0);
    }

    # Comm-Nav
    if ( getprop("/controls/circuit-breakers/radio2") and avionics_status ) {
        setprop("/systems/electrical/outputs/comm[1]", bus_volts);
        setprop("/systems/electrical/outputs/nav[1]", bus_volts);

    } else {
        setprop("/systems/electrical/outputs/comm[1]", 0.0);
        setprop("/systems/electrical/outputs/nav[1]", 0.0);
    }
    
    # Transponder
    if ( getprop("/controls/circuit-breakers/flaps") ) {
        setprop("/systems/electrical/outputs/transponder", bus_volts);
        setprop("/systems/electrical/outputs/autopilot", bus_volts);
        setprop("/systems/electrical/outputs/adf", bus_volts);

    } else {
        setprop("/systems/electrical/outputs/transponder", 0.0);
        setprop("/systems/electrical/outputs/autopilot", 0.0);
        setprop("/systems/electrical/outputs/adf", 0.0);
    }

    # Dme
    if ( getprop("/controls/circuit-breakers/flaps") ) {
        setprop("/systems/electrical/outputs/dme", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/dme", 0.0);
    }
        
    # Pitot Heat Power
    if ( getprop("/controls/circuit-breakers/pitot-heat" ) ) {
        setprop("/systems/electrical/outputs/pitot-heat", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/pitot-heat", 0.0);
    }

    # Instrument Power: ignition, fuel, oil temperature
    if ( getprop("/controls/circuit-breakers/instr") ) {
        setprop("/systems/electrical/outputs/instr-ignition-switch", bus_volts);
        if ( bus_volts > 12 ) {
            # starter
            if ( getprop("controls/switches/starter") ) {
                setprop("systems/electrical/outputs/starter", bus_volts);
            } else {
                setprop("systems/electrical/outputs/starter", 0.0);
            }
        } else {
            setprop("systems/electrical/outputs/starter", 0.0);
        }
    } else {
        setprop("/systems/electrical/outputs/instr-ignition-switch", 0.0);
        setprop("/systems/electrical/outputs/starter", 0.0);
    }
    
    # Interior lights
    if ( getprop("/controls/circuit-breakers/instr_lt") ) {
        setprop("/systems/electrical/outputs/instrument-lights", bus_volts);
        setprop("/systems/electrical/outputs/cabin-lights", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/instrument-lights", 0.0);
        setprop("/systems/electrical/outputs/cabin-lights", 0.0);
    }    

    # Landing Light Power
    if ( getprop("/controls/circuit-breakers/landing_lt") ) {
        setprop("/systems/electrical/outputs/landing-light", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/landing-light", 0.0 );
    }    
        
    # Taxi Lights Power
    # Notice taxi lights also use landing lights breaker. It is not a bug.
    if ( getprop("/controls/circuit-breakers/landing_lt") ) {
        setprop("/systems/electrical/outputs/taxi-light", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/taxi-light", 0.0);
    }

    # Beacon Power
    if ( getprop("/controls/circuit-breakers/beacon_lt") ) {
        setprop("/systems/electrical/outputs/beacon", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/beacon", 0.0);
    }
    
    # Nav Lights Power
    if ( getprop("/controls/circuit-breakers/nav_lt") ) {
        setprop("/systems/electrical/outputs/nav-lights", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/nav-lights", 0.0);
    }

    # Strobe Lights Power
    if ( getprop("/controls/circuit-breakers/strobe_lt") ) {
        setprop("/systems/electrical/outputs/strobe", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/strobe", 0.0);
    }

    # Turn Coordinator and directional gyro Power
    if ( getprop("/controls/circuit-breakers/turn-coordinator") ) {
        setprop("/systems/electrical/outputs/turn-coordinator", bus_volts);
        setprop("/systems/electrical/outputs/DG", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/turn-coordinator", 0.0);
        setprop("/systems/electrical/outputs/DG", 0.0);
    }

	setprop("/systems/electrical/suppliers/battery", battery_volts);
	setprop("/systems/electrical/suppliers/alternator_l", alternator_l_volts);
	setprop("/systems/electrical/suppliers/alternator_r", alternator_r_volts);
	setprop("/systems/electrical/amps_l", alternator_l_amps);
	setprop("/systems/electrical/amps_r", alternator_r_amps);
	setprop("/systems/electrical/volts", bus_volts);
	setprop("/systems/electrical/battery-status", new_battery_status);

	settimer(electricsystem, 0);
}

setlistener("sim/signals/fdm-initialized", electricsystem);



