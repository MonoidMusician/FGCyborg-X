return;# For some documentation, see functions.nas
#
# Roughly ranked in order of size; aircraft are almost always
# in alphebetical order of folder name.
#
# Sections:
#	Bombers!
#	Airliners
#	Transport
#	Regional/commercial turboprops
#	Fighter/attack
#	Military props
#	General aviation
#	Trainers/aerobatic jets
#	Aerobatic props
#	Ultralight/(hang-)gliders
#	Historical
#	Helicopters
#	VTOL (vertical take-off and landing)

var path = getprop("/sim/model/path");
var model = split("/", split(".", path)[0])[-1]; #get the actual filename without folders or the extension


# ======================================== BOMBERS! ======================================== #

if (model == "b36d") { #Consolidated B36 D Peacemaker

	addmode("Throttle L/R (10 engines)", "throttle[0-4,5-9]");
	addmode("Piston / Jet Throttle",     "throttle[2-7,0,1,8,9]");
	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "b29-model") { #Boeing B-29 Superfortress

	addmode("Throttle L/R (4 engines)", "throttle[0-3]");
	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "a26") { #A 26 Invader

	addmode("2 Engines", "throttle[0-1]");
	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "ant20") { #Tupolev ANT 20 Maxime Gorky

	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "lancaster") { #Avro Lancaster

	addmode("4 Engines", ["throttle[0]", "throttle[1]"],
	                     ["throttle[2]", "throttle[3]"]);
	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "B-1B") { #Rockwell B-1B Lancer

	addmode("4 Engines", ["throttle[0]", "throttle[1]"],
	                     ["throttle[2]", "throttle[3]"]);
	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "b2-spirit") { #Northrop B-2 Spirit

	addmode("4 Engines", ["throttle[0]", "throttle[1]"],
	                     ["throttle[2]", "throttle[3]"]);
	addmode("Throttle / Spoilers",  "controls.throttleAxis()", "/controls/flight/spoilers");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [brakes.spoilers,func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "BAC-TSR2-model") { #BAC TSR2 Prototype

	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [brakes._speedbrake,func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

# ======================================== AIRLINERS ======================================== #

} elsif (model == "707" or model == "boeing747-400-jw" or model == "747-400") { #Beoing 707; Boeing 747-400; Boeing 747-400

	addmode("4 Engines", ["throttle[0]", "throttle[1]"],
	                     ["throttle[2]", "throttle[3]"]);
	addmode("Throttle / Flaps",    "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Spoilers", "controls.throttleAxis()", "/controls/flight/speedbrake");
	if (model == "707") {
		addmode("Throttle / Spoilers", "controls.throttleAxis()", "/controls/flight/speedbrake");
		brakes.down = [func{},func{},func{}]; brakes.up = [brakes._spoilers,brakes.thrust_reverser,func{}];
	} else {
		addmode("Throttle / Spoilers", "controls.throttleAxis()", "/controls/flight/spoilers");
		brakes.down = [func{},func{},func{}]; brakes.up = [brakes.spoilers,brakes.thrust_reverser,func{}];
	}
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "717-200" or model == "737-100" or model == "737-200" or
         model == "777-200ER" or model == "787" or model == "CRJ-200") { #Boeing 717-200; Boeing 737-100; Boeing 737-200; Boeing 777-200ER; Boeing 787-8

	addmode("2 Engines",  "throttle[0]", "throttle[1]");
	addmode("Throttle / Flaps",    "controls.throttleAxis()", "controls.flapsAxis()");
	if (model == "717-200") {
		addmode("Throttle / Spoilers", "controls.throttleAxis()", "/controls/flight/speedbrake");
		brakes.down = [func{},func{},func{}]; brakes.up = [brakes._spoilers,brakes.thrust_reverser,func{}];
	} elsif (model == "777-200ER") {
		addmode("Throttle / Spoilers", "controls.throttleAxis()", ["/controls/flight/speedbrake", "bool"]);
		brakes.down = [func{},func{},func{}]; brakes.up = [brakes._spoilers,func {
			controls.toggleAutoSpoilers();
			if (allow_popupTips) gui.popupTip("Spoilers "~["RETRACTED", "on AUTO"][getprop("/controls/flight/speedbrake-lever")]);
		},brakes.thrust_reverser];
	} elsif (model == "787") {
		addmode("Throttle / Spoilers", "controls.throttleAxis()", ["/controls/flight/speedbrake", "bool"]);
		props.globals.initNode("/controls/flight/spoiler", 0, "INT"); #bug, the 787 doesn't initalize this as of FG v.2.6
		brakes.down = [func{},func{},func{}]; brakes.up = [func {
			if (getprop("/controls/flight/spoiler") > 0)
				setprop("/controls/flight/spoiler", getprop("/controls/flight/spoiler")-1);
			if (allow_popupTips) gui.popupTip("Spoilers set to "~["NONE", "AUTO", "AUTO or 2/3", "FULL"][getprop("/controls/flight/spoiler")]);
		},func {
			if (getprop("/controls/flight/spoiler") < 3)
				setprop("/controls/flight/spoiler", getprop("/controls/flight/spoiler")+1);
			if (allow_popupTips) gui.popupTip("Spoilers set to "~["NONE", "AUTO", "AUTO or 2/3", "FULL"][getprop("/controls/flight/spoiler")]);
		},brakes.thrust_reverser];
	} else {
		addmode("Throttle / Spoilers", "controls.throttleAxis()", "/controls/flight/spoilers");
		brakes.down = [func{},func{},func{}]; brakes.up = [brakes.spoilers,func{},func{}];
	}
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "L-1011-500" or model == "727-230") { #Lockheed L-1011-500TriStar; Boeing 727-230

	addmode("Throttle / Flaps", "throttle[0,1,2]", "controls.flapsAxis()");
	addmode("Throttle / Spoilers", "controls.throttleAxis()", "/controls/flight/speedbrake");
	addmode("3 Engines", ["throttle[0]","average2"], ["throttle[2]", "average2"]);
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [brakes._spoilers,brakes.thrust_reverser,func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "CRJ-200") { #Bombardier CRJ-200

	addmode("Throttle / Flaps", "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Spoilers", "controls.throttleAxis()", """
		var last = getprop(\"/controls/flight/spoiler\");
		if (arg[0] < 0.25)
			setprop(\"/controls/flight/spoiler\", 0);
		elsif (arg[0] < 0.5)
			setprop(\"/controls/flight/spoiler\", 1);
		elsif (arg[0] < 0.75)
			setprop(\"/controls/flight/spoiler\", 2);
		else setprop(\"/controls/flight/spoiler\", 3);
		if (allow_popupTips and getprop(\"/controls/flight/spoiler\") != last)
			gui.popupTip(\"Spoilers set to \"~[\"NONE\", \"AUTO\", \"AUTO or 2/3\", \"FULL\"][getprop(\"/controls/flight/spoiler\")]);
	""");
	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	props.globals.initNode("/controls/flight/spoiler", 0, "INT");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{
		if (getprop("/controls/flight/spoiler") > 0) {
			setprop("/controls/flight/spoiler", getprop("/controls/flight/spoiler")-1);
			if (allow_popupTips) gui.popupTip("Spoilers set to "~["NONE", "AUTO", "AUTO or 2/3", "FULL"][getprop("/controls/flight/spoiler")]);
		}
		setprop("/controls/flight/speedbrake", getprop("/controls/flight/spoiler")/3);
	},func{
		if (getprop("/controls/flight/spoiler") < 3) {
			setprop("/controls/flight/spoiler", getprop("/controls/flight/spoiler")+1);
			if (allow_popupTips) gui.popupTip("Spoilers set to "~["NONE", "AUTO", "AUTO or 2/3", "FULL"][getprop("/controls/flight/spoiler")]);
		}
		setprop("/controls/flight/speedbrake", getprop("/controls/flight/spoiler")/3);
	},func {
		reversethrust.togglereverser();
		if (allow_popupTips and getprop(throttle1) < 0.01)
			gui.popupTip(sprintf("Thrust Reversers %s", ["RETRACTED","EXTENDED"][reverser]));
	}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

# ======================================== TRANSPORT ======================================== #

} elsif (model == "trimotor") { #Ford 4.AT Trimotor

	addmode("Throttle / Starter", "controls.throttleAxis()",
	        ["/controls/engines/engine[0]/starter", "bool", nil,
	         "/controls/engines/engine[1]/starter", "bool", nil,
	         "/controls/engines/engine[2]/starter", "bool", nil]);
	addmode("3 engines", ["throttle[0]", "average2"], ["throttle[2]", "average2"]);
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 0; tailhook_enabled = 0; has_flaps = 0;

} elsif (model == "Albatross") { #Grumman Albatross

	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Flaps", "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "AC-130") { #AC-130

	addmode("Throttle / Pitch", "controls.throttleAxis()", "controls.propellerAxis()");
	addmode("Throttle / Flaps", "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("4 Engines", ["throttle[0]", "throttle[1]"],
	                     ["throttle[2]", "throttle[3]"]);
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "AN-225-model") { #Antonov AN-225 heavy/outsize cargo aircraft

	addmode("6 Engines", ["throttle[0]", "throttle[1]", "throttle[2]"],
	                     ["throttle[3]", "throttle[4]", "throttle[5]"]);
	addmode("Throttle / Spoilers", "controls.throttleAxis()", "/controls/flight/spoilers");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},          func{setprop("/controls/flight/spoilers", 1)},func{}];
	brakes.up =   [brakes.spoilers, func{setprop("/controls/flight/spoilers", 0)}, brakes.thrust_reverser];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

# ======================================== REGIONAL/COMMERICAL TURBOPROPS ======================================== #

} elsif (model == "ATR-72-500") { #ATR 72-500

	addmode("2 Engines",  "throttle[0]", "throttle[1]");
	addmode("Throttle / Flaps", "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [brakes._spoilers,brakes.thrust_reverser,func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "c160") { #C 160 Transall

	addmode("2 Engines",  "throttle[0]", "throttle[1]");
	addmode("Throttle / Pitch", "throttle", "propeller_pitch");
	addmode("Throttle / Flaps", "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [brakes.spoilers,brakes.thrust_reverser,func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

# ======================================== FIGHTER/ATTACK ======================================== #

} elsif (model == "SU-37-model") { #Sukhoi SU-37 type aircraft

	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Flaps & Slats", "controls.throttleAxis()", ["controls.flapsAxis()", "/controls/flight/slats", 4, 0, "/controls/flight/elevator-trim", -0.1, 0]);
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func {
		if (!control_functions.speedbrake.isControl("button")) return;
		var spoilers = getprop("/controls/flight/spoilers");
		setprop("/controls/flight/spoilers", !spoilers);
		var spoilers = getprop("/controls/flight/spoilers");
		if (allow_popupTips) gui.popupTip(sprintf("Speedbrake %s", ["RETRACTED","EXTENDED"][spoilers]));
	},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

	# Set afterburners to 'AUTO' (not always on, but able to be on)
	setprop("/controls/engines/engine[0]/reheat", 1);
	setprop("/controls/engines/engine[1]/reheat", 1);

} elsif (model == "F-22-Raptor") { #F-22 Raptor

	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Flaps & Slats", "controls.throttleAxis()", ["controls.flapsAxis()", "/controls/flight/slats", 4, 0]);
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [brakes.speedbrake,func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "FA-18") { #F/A-18 Hornet

	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Flaps", "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	var override = 0;
	brakes.down = [func{},func{
		override = getprop("/fdm/jsbsim/fcs/fbw-override");
		setprop("/fdm/jsbsim/fcs/fbw-override", 2);
	},func{}];
	brakes.up = [brakes.speedbrake,func{
		setprop("/fdm/jsbsim/fcs/fbw-override", override);
	},func{}];
	retractable_gear = 1; tailhook_enabled = 1; has_flaps = 1;

} elsif (model == "A-6E-model") { #Grumman A-6E

	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Flaps",    "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Spoilers", "controls.throttleAxis()", "/controls/flight/spoilers");
	addmode("Throttle / Mixture",  "controls.throttleAxis()", "controls.mixtureAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}];
	brakes.up = [brakes.speedbrake,brakes.spoilers,func{}];
	retractable_gear = 1; tailhook_enabled = 1; has_flaps = 1;

	# A hack to allow the stepped flaps to work properly :-)
	setprop("/sim/flaps/setting[0]", 0);
	setprop("/sim/flaps/setting[1]", 0.75);
	setprop("/sim/flaps/setting[2]", 1);

} elsif (model == "A-10-model") { #Fairchild A-10

	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Flaps",    "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Spoilers", "controls.throttleAxis()", "/controls/flight/spoilers");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}];
	brakes.up = [brakes.spoilers,func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "f-14b" or model == "F-14X") { #Grumman F-14b

	addmode("Throttle / Brakes", "controls.throttleAxis()", ["/controls/flight/DLC", -1]);
	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [brakes.speedbrake,func{
		var DLC = getprop("/controls/flight/DLC");
		setprop("/controls/flight/DLC", !DLC);
		DLC = getprop("/controls/flight/DLC");
		if (allow_popupTips) gui.popupTip(sprintf("DLC at %s", ["Zero","Full"][DLC]));
	},func{}];
	retractable_gear = 1; tailhook_enabled = 1; has_flaps = 1;
	control_functions.flaps.prop = "/controls/flight/flapscommand";
	control_functions.DLC.isActive = func() {
		return !!getprop("/controls/flight/DLC-engaged");
	};

} elsif (model == "f16" or model == "f16afti") { #General Dynamics F-16

	addmode("Throttle / Brakes & Speedbrake", "controls.throttleAxis()", ["brake-cmd", "/controls/flight/speedbrake", "bool", -0.3]);
	addmode("Throttle / Flaps", "controls.throttleAxis()", "controls.flapsAxis()");
	brakes.down = [func{},func{},func{}]; brakes.up = [brakes.speedbrake,func{},func{}];
	retractable_gear = 1; tailhook_enabled = 1; has_flaps = (model == "f16afti");

} elsif (model == "alphajet") { #Dassault/Dornier Alphajet

	addmode("Throttle / Flaps", "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [brakes._speedbrake,func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "RafaleB17-model" or model == "RafaleT08-model") { #Dassault Rafale B Escadron de chasse 1/7 provence; Dassault Rafale B Tigermeet 2008

	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Flaps", "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "a4f") { #Douglas A4F Skyhawk

	addmode("Throttle / Flaps", "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Spoilers", "controls.throttleAxis()", "/controls/flight/spoilers");
	addmode("Throttle / Speedbrake", "controls.throttleAxis()", "/controls/flight/speedbrake");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [brakes.speedbrake,brakes.spoilers,func{}];
	retractable_gear = 1; tailhook_enabled = 1; has_flaps = 1;

} elsif (model == "FA-XX") { #Boeing F/A-XX

	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Flaps", "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [brakes.speedbrake,func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "buccaneer-model") { #Blackburn Buccaneer S2

	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Flaps & Aileron Droop", "controls.throttleAxis()", ["controls.flapsAxis()", "/controls/flight/aileron-droop", -1]);
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [brakes.speedbrake,func{},func{}];
	retractable_gear = 1; tailhook_enabled = 1; has_flaps = 1;

# ======================================== MIL. PROPS ======================================== #

} elsif (model == "f7f") { #Grumman F7F Tigercat

	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Pitch", "controls.throttleAxis()", "controls.propellerAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "PC-9M") { #Pilatus PC-9M

	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [brakes.speedbrake,func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "AD-6") { #Douglas AD-6 Skyraider

	addmode("Throttle / Pitch",  "controls.throttleAxis()", "controls.propellerAxis()");
	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{setprop("/fdm/jsbsim/systems/armament/release", 1)}]; brakes.up = [brakes.speedbrake,func{},func{setprop("/fdm/jsbsim/systems/armament/release", 0)}];
	retractable_gear = 1; tailhook_enabled = 1; has_flaps = 1;

} elsif (model == "a6m2-anim") { #A6M2 Zero

	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	addmode("Throttle / Flaps", "controls.throttleAxis()", "controls.flapsAxis()");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 1; has_flaps = 1;

} elsif (model == "Beaufighter") { #Beaufighter

	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Flaps", "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 1; has_flaps = 1;

# ======================================== G-AVIATION ======================================== #

} elsif (model == "pa24-250-CIII" or model == "pa24-250-CIIB") { #Piper Commanche 250, CIII autopilot; Piper Commanche 250, CIIB autopilot

	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Pitch",  "controls.throttleAxis()", "controls.propellerAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "a24") { #Aeroprakt A 24 Viking

	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Gear",  "controls.throttleAxis()", ["/controls/gear/gear-down", "-bool"]);
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "aerostar") { #Aerostar Super 700

	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "AG-14" or model == "an2-model" or model == "arup-s2") { #Anderson-Greenwood AG-14; Legendary Russian AN-2; Arup S2

	addmode("Throttle / Mixture",  "controls.throttleAxis()", "controls.mixtureAxis()");
	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 0; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "allegroF" or model == "allegroW") { #Allegro 2000 (Float); Allegro 2000 (Wheels)

	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	if (model == "allegroW")
		addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 0; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "B1900D") { #Beechcraft b1000d

	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Pitch",  "controls.throttleAxis()", "controls.propellerAxis()");
	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "model17") { #Beechcraft Staggerwing

	addmode("Throttle / Mixture",  "controls.throttleAxis()", "controls.mixtureAxis()");
	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "hv220") { #Bernard HV 220

	addmode("Throttle", "controls.throttleAxis()", "controls.propellerAxis()");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 0; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "bugatti") { #Bugatti model 100P

	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "bv141") { #Blohm und Voss BV141

	addmode("Throttle / Pitch",  "controls.throttleAxis()", "controls.propellerAxis()");
	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "bv170") { #Blohm und Voss BV170

	addmode("3 Engines", ["throttle[0]","average2"], ["throttle[2]", "average2"]);
	addmode("Throttle / Pitch",  "controls.throttleAxis()", "controls.propellerAxis()");
	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "cl415") { #Bombardier 415

	addmode("2 Engines", "throttle[0]", "throttle[1]");
	addmode("Throttle / Pitch",  "controls.throttleAxis()", "controls.propellerAxis()");
	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "c172p") { #Cessna 172P Skyhawk (1981 model)

	addmode("Throttle / Mixture",  "controls.throttleAxis()", "controls.mixtureAxis()");
	addmode("Throttle / Flaps",  "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func {
		setprop("/controls/lighting/landing-lights", var v = !getprop("/controls/lighting/landing-lights"));
		if (allow_popupTips) gui.popupTip("Landing light "~v?"on":"off");
	},func{},func{}];
	retractable_gear = 0; tailhook_enabled = 0; has_flaps = 1;

# ======================================== TRAINERS/AEROBATIC JETS ======================================== #

} elsif (model == "l39") { #Aero Vodochody L-39 Albatros

	addmode("Throttle / Flaps", "controls.throttleAxis()", "controls.flapsAxis()",);
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

# ======================================== AEROBATIC PROPS ======================================== #

} elsif (model == "ZivkoEdge540") { #Zivko Edge 540

	addmode("Throttle / Pitch",  "controls.throttleAxis()", "controls.propellerAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 0; tailhook_enabled = 0; has_flaps = 1;

# ======================================== ULTRALIGHT/(HANG-)GLIDERS ======================================== #

} elsif (model == "Dragonfly") { #Moyes Dragonfly

	addmode("Throttle & Starter / Brakes", ["controls.throttleAxis()", "/controls/engines/engine/starter", "bool"], "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 0; tailhook_enabled = 0; has_flaps = 0;

} elsif (model == "ask13" or model == "ask21") { #Schleicher ASK 13 Glider; Schleicher ASK 21 Glider

	if (model == "ask21")
		addmode("Speedbrake / Brakes", ["controls.throttleAxis()", -1], "brake-cmd");
	else
		addmode("Speedbrake / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 0; tailhook_enabled = 0; has_flaps = 0;

} elsif (model == "ask21mi") { #Schleicher ASK 21 mi

	addmode("Throttle / SLS Unit & Starter", "controls.throttleAxis()", """
		var starter = arg[0] > 0.85;
		var SLS = arg[0] > 0.2;
		setprop(\"/controls/engines/engine/starter\", starter);
		if (ask21mi.doorsystem.passenger.target == SLS)
			ask21mi.doorsystem.passengerexport();
	""");
	addmode("Speedbrake / Brakes", ["/controls/flight/spoilers", -1], "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 0; tailhook_enabled = 0; has_flaps = 0;

} elsif (model == "JT-5B") { #JT-5B Autogyro (YASim)

	addmode("Throttle / Composite (Rotorbreak | none | Starter)", "controls.throttleAxis()", """
		var starter = arg[0] > 0.85;
		var brake = arg[0] > 0.2 or in_air() ? 0 : (0.2-arg[0])/0.2;
		setprop(\"/controls/engines/engine/starter\", starter);
		setprop(\"/controls/rotor/brake\", brake);
	""");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 0; tailhook_enabled = 0; has_flaps = 0;

# ======================================== HISTORICAL ======================================== #

} elsif (model == "14bis") { #14bis Santos DUMONT

	addmode("Throttle / Starter", "controls.throttleAxis()", ["/controls/engines/engine/starter", "bool"]);

# ======================================== HELIS ======================================== #

} elsif (model == "H21-piasecki" or model == "ka50" or model == "dauphin" or model == "ch53e-model" or model == "CH47" or
         model == "bell222x" or model == "aircrane" or model == "uh1" or model == "uh60" or model == "R22" or model == "Lynx-WG13" or
         model == "mi24" or model == "superfrelon") {

	addmode("Collective", ["controls.throttleAxis()", -1], "controls.propellerAxis()");
	tailhook_enabled = 0; has_flaps = 0;

} elsif (model == "bo105") {

	addmode("Throttle & Power", ["controls.throttleAxis()", 1, 0], """
	            # Raw Access:
	            setprop(\"/controls/engines/engine[0]/power\", bo105.engines.engine[0].power=arg[0]);
	            setprop(\"/controls/engines/engine[1]/power\", bo105.engines.engine[1].power=arg[0]);
	        """);

# ======================================== VTOL ======================================== #

} elsif (model == "harrier-model") { #British Aerospace Harrier

	addmode("Throttle / Vector", "controls.throttleAxis()", ["controls.mixtureAxis()", 0.4, 0.3]);
	addmode("Throttle / Flaps",  "controls.throttleAxis()",  "controls.flapsAxis()");
	addmode("Throttle / Flaps & Vector", "controls.throttleAxis()", ["controls.mixtureAxis()", 0.4, 0.3, "controls.flapsAxis()"]);
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [brakes._spoilers,func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 1;

} elsif (model == "F-35B") { #Lockheed Martin F-35B Lightning II

	addmode("Throttle / Mixture", "controls.throttleAxis()", ["f35.tiltAxis()", 0.8, nil]);
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [brakes.speedbrake,func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 0;

} elsif (model == "v22") { #Bell Boeing V-22 Osprey

	addmode("Throttle / Engines", ["controls.throttleAxis()", -1], "v22.tiltAxis()");
	addmode("Throttle / Brakes", "controls.throttleAxis()", "brake-cmd");
	brakes.down = [func{},func{},func{}]; brakes.up = [func{},func{},func{}];
	retractable_gear = 1; tailhook_enabled = 0; has_flaps = 0;

# ======================================== DEFAULT ======================================== #
# [gasp] the horror! ;-)

} else {

	addmode("Throttle / Pitch", "controls.throttleAxis()", "controls.propellerAxis()");
	addmode("2 Engines",  "throttle[0]", "throttle[1]");
	addmode("3 Engines", ["throttle[0]","average2"], ["throttle[2]", "average2"]);
	addmode("4 Engines", "throttle[0,1]", "throttle[2,3]");
#	addmode("5 Engines", ["throttle[0],1]", "average4"],
#	                     ["throttle[2,3]", "average4"]);
	addmode("Collective",        ["controls.throttleAxis()", -1], "controls.propellerAxis()"); #reverse throttle
	addmode("Throttle / Mixture", "controls.throttleAxis()", "controls.mixtureAxis()");
	addmode("Throttle / Flaps",   "controls.throttleAxis()", "controls.flapsAxis()");
	addmode("Throttle / Brakes",  "controls.throttleAxis()", "brake-cmd");
}

if (!tailhook_enabled) {
	control_functions.tailhook.isActive = func 0;
	control_functions.tailhook.isControl = func(name) 0;
}
if (!retractable_gear) {
	control_functions.gear.isActive = func 0;
	control_functions.gear.isControl = func(name) 0;
}
if (!has_flaps) {
	control_functions.flaps.isActive = func 0;
	control_functions.flaps.isControl = func(name) 0;
}

