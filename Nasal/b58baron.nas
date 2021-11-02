var beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
aircraft.light.new("sim/model/b58baron/lighting/beacon", [0.025, 1.5], beacon_switch);

# Strobe lights
var strobe_switch = props.globals.getNode("controls/lighting/strobe", 1);
aircraft.light.new("sim/model/b58baron/lighting/strobe", [0.015, 1.985], strobe_switch);

aircraft.data.add(
	"instrumentation/comm[0]/volume",
	"instrumentation/comm[0]/frequencies/selected-mhz",
	"instrumentation/comm[0]/frequencies/standby-mhz",
	"instrumentation/comm[0]/test-btn",
	"instrumentation/nav[0]/audio-btn",
	"instrumentation/nav[0]/power-btn",
	"instrumentation/nav[0]/frequencies/selected-mhz",
	"instrumentation/nav[0]/frequencies/standby-mhz",
);

# Set heading offset
var magnetic_variation = getprop("/environment/magnetic-variation-deg");
setprop("/instrumentation/heading-indicator/offset-deg", -magnetic_variation);

# Set alt alert of KAP 140 autopilot to 20_000 ft to get rid of annoying beep
setlistener("/autopilot/KAP140/settings/target-alt-ft", func (n) {
    if (n.getValue() == 0) {
        kap140.altPreselect = 20000;
        setprop("/autopilot/KAP140/settings/target-alt-ft", kap140.altPreselect);
    }
});


##########################################
# Click Sounds
##########################################

var click = func (name, timeout=0.1, delay=0) {
    var sound_prop = "/sim/model/b58baron/sound/click-" ~ name;

    settimer(func {
        # Play the sound
        setprop(sound_prop, 1);

        # Reset the property after 0.2 seconds so that the sound can be
        # played again.
        settimer(func {
            setprop(sound_prop, 0);
        }, timeout);
    }, delay);
};

##########################################
# Autostart
##########################################

var autostart = func (msg=1) {
    if (getprop("/engines/engine[0]/running")) {
        if (msg)
            gui.popupTip("Engine 1 already running", 5);
        return;
    }
    if (getprop("/engines/engine[1]/running")) {
        if (msg)
            gui.popupTip("Engine 2 already running", 5);
        return;
    }

    # Filling fuel tanks
    setprop("/consumables/fuel/tank[0]/selected", 1);
    setprop("/consumables/fuel/tank[1]/selected", 1);

    # Setting levers and switches for startup
    setprop("/controls/engines/engine[0]/magnetos", 3);
    setprop("/controls/engines/engine[0]/magnetos", 3);
    setprop("/controls/engines/engine[0]/throttle", 0.2);
    setprop("/controls/engines/engine[1]/throttle", 0.2);
    setprop("/controls/engines/engine[0]/mixture", 0.95);
    setprop("/controls/engines/engine[1]/mixture", 0.95);
    setprop("/controls/flight/elevator-trim", 0.0);
    setprop("/controls/switches/master-bat", 1);


    # All set, starting engine
    setprop("/controls/engines/engine[0]/starter", 1);
    setprop("/engines/engine[0]/auto-start", 1);
    setprop("/controls/engines/engine[1]/starter", 1);
    setprop("/engines/engine[1]/auto-start", 1);
    
    var engine_running_check_delay = 5.0;
    settimer(func {
        if (!getprop("/engines/engine[0]/running")) {
            gui.popupTip("The autostart failed to start the engine. You must lean the mixture and start the engine manually.", 5);
        }
    	setprop("/controls/engines/engine[0]/starter", 0);
    	setprop("/engines/engine[0]/auto-start", 1);
    	setprop("/controls/engines/engine[1]/starter", 0);
    	setprop("/engines/engine[1]/auto-start", 1);
    }, engine_running_check_delay);

};

var reset_system = func {
    if (getprop("/fdm/jsbsim/running")) {
        b58baron.autostart(0);
    }
};


#Proppeller heater amps

var prop_amps = maketimer(0.01, func {
    var prop_deice_amps = getprop("/instrumentation/anti-ice/prop-heat-amps");
    var prop_deice_on = getprop("/controls/anti-ice/prop-heat");

    if ( (prop_deice_amps < 15) and (prop_deice_on == 1) ) {
       setprop("/instrumentation/anti-ice/prop-heat-amps", prop_deice_amps + 0.5);
       }
    else if ( (prop_deice_amps > 0) and (prop_deice_on == 0) ) {
       setprop("/instrumentation/anti-ice/prop-heat-amps", prop_deice_amps - 0.5);
       }
});
prop_amps.start();

##########################################
# SetListerner must be at the end of this file
##########################################

    setlistener("/engines/engine[0]/running", func (node) {
        var autostart = getprop("/engines/engine[0]/auto-start");
        var cranking  = getprop("/engines/engine[0]/cranking");
        if (autostart and cranking and node.getBoolValue()) {
            setprop("/controls/engines/engine[0]/starter", 0);
            setprop("/engines/engine[0]/auto-start", 0);
        }
    }, 0, 0);

    setlistener("/engines/engine[1]/running", func (node) {
        var autostart = getprop("/engines/engine[1]/auto-start");
        var cranking  = getprop("/engines/engine[1]/cranking");
        if (autostart and cranking and node.getBoolValue()) {
            setprop("/controls/engines/engine[1]/starter", 0);
            setprop("/engines/engine[1]/auto-start", 0);
        }
    }, 0, 0);
 

