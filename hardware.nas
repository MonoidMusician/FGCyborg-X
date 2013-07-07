##
# A class for buttons that can have one or both of double-click or hold down. For the former,
# if you tap the button twice within the specified time it will do a different function.
# For the latter, if you hold the button down for longer than the specified amount of time,
# it will run a function and then when it is released it will run another function.
#
# Depending on if hold down and/or double click is enabled for a button, they will run
# different functions. Both times can be functions, e.g.:
#
#    Button.new(hold_down_time:func if (mod == 0) 0.2 else 0);
#
# The above example checks to see if mod equals 1, if it does then hold_down_time is 0.2 and
# hold down is enabled, if it isn't then hold_down_time is disabled (since it's returning false).
#
# The variable double_click_type sets the method for detecting a double click. If equal to 1
# it becomes 'opportunistic' and runs the double_click_function when it is pressed twice within
# double_click_time; if equal to 0 it waits for two releases. In practice it makes no difference,
# but I left it in in case somebody wanted it.
#
#
# Used functions when hold down and/or double-click is enabled:
# (variable name)         {class's set function}      (description)
#
# Hold down enabled (hold_down_time is true, double_click_time is false):
# -----------------------------------------------------------------------
# regular_function        {setRegularFunction}        function when 'tapped' (held for less than hold_down_time).
# hold_down_function      {setHoldDownFunction}       function when held.
# hold_down_release       {setHoldDownRelease}        function when released after being held.
#
# Double click enabled (hold_down_time is false, double_click_time is true):
# --------------------------------------------------------------------------
# regular_function        {setRegularFunction}        function when the timer for double_click_time has expired without a double press.
# double_click_function   {setDoubleClickFunction}    function when pressed twice within double_click_time.
#
# None enabled (hold_down_time and double_click_time are false):
# --------------------------------------------------------------
# regular_down_function   {setRegularFunction}        function when pressed.
# regular_function        {setRegularPressFunction}   function when released.
#
# Both enabled (hold_down_time is true, double_click_time is true):
# -----------------------------------------------------------------
# regular_function        {setRegularFunction}        function when the timer for double_click_time has expired without a double tap and it hasn't been held.
# double_click_function   {setDoubleClickFunction}    function when tapped twice within double_click_time.
# hold_down_function      {setHoldDownFunction}       function when held.
# hold_down_release       {setHoldDownRelease}        function when released after being held.
#
# Bugs:
# * double_click_time has to be greater than or equal to hold_down_time
#

# A simple trace:
if (0) var trace = print;
else   var trace = func() {};

var Button = {
	hold_down_flag:0, state:0, events:0,
	new:func(node=1,
	         hold_down_time=nil,     hold_down_function=nil,    regular_function=nil,      hold_down_release=nil,
	         double_click_time=nil,  double_click_function=nil, regular_down_function=nil, double_click_type=1) {
		m = {parents:[me]};
		m.setHoldDownTime(hold_down_time);
		m.setHoldDownFunction(hold_down_function);
		m.setRegularFunction(regular_function);
		m.setRegularPressFunction(regular_down_function);
		m.setHoldDownRelease(hold_down_release);
		m.setDoubleClickTime(double_click_time);
		m.setDoubleClickFunction(double_click_function);
		m.setDoubleClickType(double_click_type);
		if (node != 1) m.setNode(node);
		return m;
	},

	down:func {
		me.state = 1;
		# Cache values:
		double_click_time = me.double_click_time();
		hold_down_time = me.hold_down_time();
		if (double_click_time) {
			if (me.events == 0 or me.events == 2) me.events += 1;
			if (me.events == 3 and me.double_click_type == 1) {
				me.double_click_function(); me.events = 0
			} elsif (me.events <= 1) { #if it is our first click
				settimer(func {
					if (!me.double_click_time()) return;
					if (!me.hold_down_flag and me.events >= 2) {
						me.regular_function();
						trace("double_click_timer " ~ me.events);
					}
					me.events = 0;
				}, double_click_time);
			}
		} else {
			me.events = 0;
		}
		if (hold_down_time) {
			settimer(func {
				if (!me.hold_down_time()) return;
				if (me.state and me.events <= 2) {
					me.hold_down_function();
					me.hold_down_flag = 1;
					trace("hold_down_function()");
				} else {
					me.hold_down_flag = 0;
				}
			}, hold_down_time);
		} else {
			me.hold_down_flag = 0;
			if (!double_click_time) { #check for a regular button function
				me.regular_down_function();
			}
		}
	},

	up:func {
		me.state = 0;
		double_click_time = me.double_click_time();
		hold_down_time = me.hold_down_time();
		if (double_click_time) {
			if (me.events == 1 or me.events == 3) me.events += 1;
			if (me.events == 4 and me.double_click_type == 0) { me.double_click_function(); me.events = 0 }
		}
		if (me.hold_down_flag) {
			me.hold_down_release();
			me.hold_down_flag = 0;
		} elsif (!hold_down_time and !double_click_time) {
			me.regular_function();
		}
	},

	setNode:func(n) {
		if (typeof(n) == 'scalar') n = props.globals.getNode(n);
		if (!isa(n, props.Node)) die("invalid argument to Button.setNode of type "~typeof(n));
		if ((var a=n.getNode("double-click")) != nil) {
			if (a.getNode("time") != nil)
				me.double_click_time = (func {
					var b = a.getNode("time");
					func b.getValue();
				})();
			if (a.getNode("binding") != nil)
				me.double_click_function = (func {
					var b = a.getNode("binding");
					func props.runBinding(b, "__js"~Joystick.getIndex());
				})();
		}
		if ((var a=n.getNode("hold-down")) != nil) {
			if (a.getNode("time") != nil)
				me.hold_down_time = (func {
					var b = a.getNode("time");
					func b.getValue();
				})();
			if (a.getNode("binding") != nil)
				me.hold_down_function = (func {
					var b = a.getNode("binding");
					func props.runBinding(b, "__js"~Joystick.getIndex());
				})();
			if (a.getNode("mod-up/binding") != nil)
				me.hold_down_release = (func {
					var b = a.getNode("mod-up/binding");
					func props.runBinding(b, "__js"~Joystick.getIndex());
				})();
		}
		if ((var a=n.getNode("regular")) != nil) {
			if (a.getNode("binding") != nil)
				me.regular_function = (func {
					var b = a.getNode("binding");
					func props.runBinding(b, "__js"~Joystick.getIndex());
				})();
			if (a.getNode("mod-down/binding") != nil)
				me.regular_down_function = (func {
					var b = a.getNode("mod-up/binding");
					func props.runBinding(b, "__js"~Joystick.getIndex());
				})();
		}
	},

	setHoldDownTime:func(n) {
		if (n == nil) {me.hold_down_time = func{}; return;}
		if (typeof(n) == 'scalar') {
			var m = n;
			var n = func{return m};
		}
		if (typeof(n) == 'func') {
			me.hold_down_time = n;
		} else {
			die("argument to setHoldDownTime is not a function nor a scalar");
		}
	},
	setDoubleClickTime:func(n) {
		if (n == nil) {me.double_click_time = func{}; return;}
		if (typeof(n) == 'scalar') {
			var m = n;
			var n = func{return m};
		}
		if (typeof(n) == 'func') {
			me.double_click_time = n;
		} else {
			die("argument to setDoubleClickTime is not a function nor a scalar");
		}
	},
	setHoldDownFunction:func(n) {
		if (n == nil) {me.hold_down_function = func{}; return;}
		elsif (typeof(n) == 'func') {
			me.hold_down_function = n;
		} else {
			die("argument to setHoldDownFunction is not a function");
		}
	},
	setRegularFunction:func(n) {
		if (n == nil) {me.regular_function = func{}; return;}
		elsif (typeof(n) == 'func') {
			me.regular_function = n;
		} else {
			die("argument to setRegularFunction is not a function");
		}
	},
	setRegularPressFunction:func(n) {
		if (n == nil) {me.regular_down_function = func{}; return;}
		elsif (typeof(n) == 'func') {
			me.regular_down_function = n;
		} else {
			die("argument to setRegularPressFunction is not a function");
		}
	},
	setHoldDownRelease:func(n) {
		if (n == nil) {me.hold_down_release = func{}; return;}
		elsif (typeof(n) == 'func') {
			me.hold_down_release = n;
		} else {
			die("argument to setHoldDownRelease is not a function");
		}
	},
	setDoubleClickFunction:func(n) {
		if (n == nil) {me.double_click_function = func{}; return;}
		elsif (typeof(n) == 'func') {
			me.double_click_function = n;
		} else {
			die("argument to setDoubleClickFunction is not a function");
		}
	},
	setDoubleClickType:func(n) {
		if (n == nil) {me.double_click_type = 0; return;}
		else me.double_click_type = n;
	},
};

# #################################################################################
# Specific button bindings
# #################################################################################

var button2 = Button.new(Joystick.getChild("button", 1));
var button3 = Button.new(Joystick.getChild("button", 2));

# For continuous flaps, will do more advanced things with them later
button8 = Button.new(regular_down_function:func{controls.flapsDown(-1)}, regular_function:func{controls.flapsDown(0)});
button9 = Button.new(regular_down_function:func{controls.flapsDown(1)}, regular_function:func{controls.flapsDown(0)});

##
# A class to manage the release of a scroll wheel function
# (e.g. stop flaps movement) after the wheel has not moved
# for the length of timeout. Call reset() to indicate movement,
# i.e. every scroll wheel event other than mod-up.  Access
# the "running" member to check if it has timed out.
#
var scroll = {
	new: func(timeout, fn, arg...) {
		var loopid = var running = 0;
		return _gen_new();
	},
	reset: func {
		var this_loop = me.loopid += 1;
		me.running = 1;
		settimer(func {
			# If it has not changed:
			if (this_loop == me.loopid) {
				# Call our release function.
				call(me.fn, me.arg);
				me.running = 0;
			}
		}, me.timeout);
	},
};

##
# A class to manage joystick axes. Features:
# EWMA: integrates a lowpass filter to reduce noise/jitter.
# Overshoot: instead of setting the lowpass with the value
#   of the axis, we can aim for a spot just beyond that
#   so that we actually get there in a "timely" fashion
#   (since a moving average models an exponential function
#   starting at the old value and having an asymptote
#   approaching the new value).
# Jamming: the axis can be diabled to stop it from, e.g.
#   messing with the autopilot (since it usually gets set
#   about every frame even if it did not move much).
# Trim (near center): for things like throttles, this allows
#   trimming of the value when the axis is close to the
#   center but does not affect the outside range.
# Outer dead band: dead band for the outer region of the axis:
#   anything near +1 and -1 get clipped to those values.
# Standard functions like offset, bead band, factor and power
# are implemented. For throttles, input the standard (-1,1) range
# to have trim work properly, instead of the range (0,1).
#
var Axis = {
	new:func(node=nil, #master uber-node for settings
	         EWMA=0, power=1, reverse=0, offset=0, #axis movement properties
	         dead_band=0, overshoot=0, hysteresis=0, trim=0,
	         outer_dead_band=0, factor=1, exp=0, outer_trim=0,
	         function=nil, prop=nil) { #update properties
		var lowpass = aircraft.lowpass.new(EWMA);
		var jammed = var jammed_hash = nil;
		var axisvalue = var aim = 0;
		var functions = [nil, nil]; #some functions to execute
		var time_of_last_move = systime(); #used to increase hysteresis with time
		var m = _gen_new("EWMA"); #we do not want "EWMA" as a member, so put it as an argument
		# The property can override any of these settings:
		if (node != nil) setlistener(node, func {
			var node_name = func(sym) return string.replace(sym, "_", "-");
			var namespace = closure(caller(0)[1]);
			foreach (var sym; keys(namespace)) {
				if (node.getNode(node_name(sym)) != nil) {
					var val = node.getNode(node_name(sym)).getValue();
					if (val == nil) continue;
					sym == "outer_dead_band"? m.setOuterDeadBand(val):
					sym == "hysteresis"? m.setHysteresis(val):
					sym == "outer_trim"? m.setOuterTrim(val):
					sym == "overshoot"? m.setOvershoot(val):
					sym == "dead_band"? m.setDeadBand(val):
					sym == "reverse"? m.setReverse(val):
					sym == "offset"? m.setOffset(val):
					sym == "factor"? m.setFactor(val):
					sym == "power"? m.setPower(val):
					sym == "trim"? m.setTrim(val):
					sym == "EWMA"? m.setEWMA(val):
					sym == "exp"? m.setExp(val):
						              continue;
				}
			}
		}, 1, 2);
		m.set(0); m.update(); #finish initialization and "tie" it to the property(ies)
		return m;
	},
	# This is uneccesary to call on input reinit, since the property tree
	# under /input is flashed (deleted) anyways.
	del:func {
		foreach (var l; me.listeners)
			removelistener(l);
		me.listeners = [];
	},

	# Un-optimized (aka legible) form:
	filter:func(value) {
		var old = me.get();
		var value = me._transform(value);
		me.axisvalue = value;
		if (me.lowpass.coeff) {
			me.aim = value+math.sgn(value-old)*me.overshoot; #FIXME: this definitely needs a better implementation of overshoot
			return me.lowpass.filter(me.aim);
		} else {
			me.aim = value;
			return me.lowpass.set(value);
		}
	},
	# Optimized form:
	filter:func(value) {
		var old = me.get();
		if (me.lowpass.coeff)
			return me.lowpass.filter(me.aim = (me.axisvalue = me._transform(value))+math.sgn(me.axisvalue-old)*(me.overshoot));
		else
			return me.lowpass.set(me.aim = me.axisvalue = me._transform(value));
	},

	get:func me.lowpass.get(),

	# Un-optimized:
	set:func(value) {
		var value = me._transform(value);
		me.aim = value;
		return me.lowpass.set(value);
	},
	# Optimized:
	set:func(value) {
		return me.lowpass.set(me.aim = me.axisvalue = me._transform(value));
	},

	push:func(value=nil) {
		if (value == nil) value = cmdarg().getNode("setting").getValue();
		#var value = me._transform(value); #transformation is handled in me.filter()
		if (value >= me.get()-me._hysteresis() and
		    value <= me.get()+me._hysteresis()) #if it isn't any different
			return nil;
		me.time_of_last_move = systime();
		return me.runfunction(me.filter(value)); #returns the value set, after transformations
	},

	update:func {
		var previous = me.get();
		var value = me.lowpass.filter(me.aim);
		#FIXME: I am not convinced that this works well:
		if (me.aim  >  me.axisvalue  #figure out which direction we are going
		    ? value >= me.axisvalue  #and whether it went past the aim value
		    : value <= me.axisvalue)
			#me.aim = me.axisvalue;  #if so, aim directly for the axis
			me.value = me.axisvalue; #if so, set us to be right there
		if (math.abs(previous - value) > 0.03*getprop("/sim/time/delta-sec"))
			printlog("warn",
			   sprintf("value is changing too much prev: %4f, curr: %4f, "
			   "aim: %4f, axis: %4f",
			           previous, me.value, me.aim, me.axisvalue));

		me.runfunction(value);
		if (value > previous+me._hysteresis() or value < previous-me._hysteresis())
			me.time_of_last_move = systime();
		return value;
	},

	runfunction:func(n=nil) {
		if (n == nil) n = me.get();
		if (me.getJammed()) return;
		foreach (var fn; me.functions)
			if (fn != nil) call(fn, [n], me);
		var prop = typeof(me.prop) == 'func' ? me.prop() : me.prop;
		if (prop and me.prop_active())
			setprop(prop, n);
		return n;
	},

	_transform:func(value) {
		value += me.offset; #this is "hardware" offset -- not output offset
		if (me.reverse) value *= -1; #and harware reverse
		# First the tricky part: instead of the center of the
		# imaginary line drawn by F(x) being (0,0), we make it
		# be (0,trim) and draw two lines going to that point
		# from both (-1,-1) and (1,1) to make our new F(x)
		if (me.trim) var value = value*(1+math.sgn(value)*me.trim)+me.trim;
		# Check if within dead band range now that it is properly
		# calibrated (i.e. after offset and trim):
		if (math.abs(value) <= me.dead_band)
			return 0;
		if (math.abs(value) >= 1-me.outer_dead_band)
			return me.factor*math.sgn(value);
		# If we were to leave it alone, then there would be a jump
		# around the dead band areas, since in that dead band it
		# would be 0, but above it we aren't correcting and the
		# line coming out of the dead band zone would show a sudden
		# "jump". To correct this, start the line at the edge of the
		# dead band zone and add some to the slope so that it reaches
		# 1 at 1-outer_dead_band.
		value -= math.sgn(value)*me.dead_band;
		value *= 1/(1-me.dead_band-me.outer_dead_band);
		# And finally apply the power and then factor transformations:
		if (value > 0)
			value = math.pow( value, me.power);
		else
			value =-math.pow(-value, me.power);
		if (me.exp and me.exp != 1) {
			# Exponential equation: (b^x-1)/(b-1)
			value = math.sgn(value) * (math.pow(me.exp, math.abs(value)) - 1) /
			        (me.exp - 1);
		}
		return me.factor * value;
	},

	_hysteresis:func() {
		return math.min(math.max((systime()-me.time_of_last_move)/4, 0.1), 1)*me.hysteresis;
	},

	# Low key setter functions; getters are known
	# under the name of "raw access" ;-)
	setEWMA:func(n=0) {
		if (n < 0) die("lowpass coefficient must be non-negative");
		me.lowpass.coeff = n;
	},
	setExp: func(n=1) me.exp = math.pow(n, 4),
	setTrim: func(n=0) me.trim = n,
	setPower: func(n=1) me.power = n,
	setFactor: func(n=1) me.factor = n,
	setOffset:  func(n=0) me.offset = n,
	setReverse:  func(n=0) me.reverse = !!n,
	setDeadBand:  func(n=0) me.dead_band = math.max(n, 0),
	setOvershoot:  func(n=0) me.overshoot = math.max(n, 0),
	setOuterTrim:   func(n=0) me.outer_trim = n,
	setHysteresis:   func(n=0) me.hysteresis = math.max(n, 0),
	setOuterDeadBand: func(n=0) me.outer_dead_band = math.max(n, 0),
	# This function is called with one argument
	# (the current value) every time the axis changes
	setFunction:func(n=nil) {
		if (typeof(n) == 'func') me.functions[0] = n;
		else me.functions[0] = nil;
	},
	# This property is changed with the axis if the is_active
	# function returns true. The prop can also be a function
	# that returns the property.
	setProp:func(n=nil, is_active=nil) {
		if (typeof(n) == 'func')
			me.prop = n;
		elsif (isa(n, props.Node))
			me.prop = n.getPath();
		else
			me.prop = (n == nil ? "" : n);
		me.prop_active = typeof(is_active) == 'func' ? is_active : func {1};
	},
	# Manually set/reset this axis as being jammed:
	setJammed:func(n=0) {
		me.jammed = n;
	},
	# Or set a name for the controls_functions entry, which integrates
	# both the jammed capabilities and the property setting.
	setControlName:func(n) {
		me.jammed = nil;
		me.jammed_hash = control_functions[n];
		var min = contains(me.jammed_hash, "min") ? me.jammed_hash.min : -1;
		var max = contains(me.jammed_hash, "max") ? me.jammed_hash.max :  1;
		me.functions[1] = func(val) {
			me.jammed_hash.set("axis", val)
		};
	},
	getJammed:func {
		if (me.jammed == nil and me.jammed_hash != nil)
			return !(me.jammed_hash.isControl("axis") and me.jammed_hash.isActive());
		else
			return !!me.jammed;
	},
};

# Alternative control:
#   elevator  : + throttle 
#               - brake
#   aileron   = rudder/tiller
#   throttle1 : > 0.66 none
#               < 0.66 spoilers
#               < 0.33 thrust reverser and spoilers

