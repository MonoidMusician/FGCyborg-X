##
# A file that implements various utilities/functions for joysticks
#
# Call using io.load_nasal(file, cmdarg().getNode("module").getValue());
# or equivalent (i.e. load into the namespace of the joystick, __jsN).
# Alternative idea: load into a namespace under the joystick's one:
#
#     //Inside namespace __jsN, e.g. a <nasal><script> section
#     var functions = {}; #namespace to load functions.nas into, a local variable
#                         #to make it a hash member of the __jsN namespace, so the
#                         #variables in functions.nas can be accessed with
#                         #functions.flapscontrol(), etc.
#     var file = io.load(filename);
#     var code = compile(file);
#     bind(code, caller(0)[0], bind(func{}, globals))
#     call(code, nil, caller(0)[0], functions);
#
# This allows access to joystick variables like Joystick without
# "polluting" the actual joystick namespace.
#

# If we need to initialize our own values (usually done in joystick .xmls), set to 1:
if (0) (func{ #do not pollute namespace with temporary variables
	#var this_namespace = caller(0)[0];
	var this_namespaces_name = cmdarg().getNode("module").getValue();
	var this_namespace = globals[this_namespaces_name];
	#debug.dump(this_namespace);
	var init_variable = func(namespace, lvalue, value=nil) {
		if (!contains(namespace, lvalue)) {
			namespace[lvalue] = value;
			printlog("debug", "functions.nas: initialized variable ", lvalue, " in namespace ", this_namespaces_name, " to value ", debug.string(value));
		}
	}
	var root = cmdarg().getParent().getPath();
	init_variable(this_namespace, "getlocalprop", func(n) {return getprop(root~n) });
	init_variable(this_namespace, "setlocalprop", func(n,t) {return setprop(root~n, t) });
})();

# Extensions (hints to the developers ;-) )
controls.trigger1 = func(b) setprop("/controls/armament/trigger1", b);

var _make_extension = func(namespc, fname, fn, objs...) { #objs: objects inside the namespace
	var _n = globals[namespc];
	foreach (var name; objs) {
		if (_n == nil) return;
		_n = _n[name];
	}
	if (_n[fname] != nil) return;
	_n[fname] = bind(fn, globals[namespc], bind(func {}, globals));
};
# @brief Toggle a normalized [0,1] property
# @param switch The value above which to consider the property "on"
#        (e.g. for spoilers, if the value is very small we want to
#        consider it 'off')
_make_extension("controls", "toggle", func(prop, switch=0.15) {
	if (isa(prop, props.Node)) prop = prop.getPath();
	var val = getprop(prop);
	setprop(prop, val <= switch);
});
_make_extension("props", "toggle", func(switch=0.15) {
	me.setValue(me.getValue() <= switch);
}, "Node");
# Hack until I get changes to the source...
# Remove this and replace with simply props.Node.getValue(node)
# for versions >= 2.11.
_make_extension("props", "getNodeValue", func {
	if (!size(arg)) return me.getValue();
	var _node = _getNode(me._g, arg);
	return _node==nil ? nil : wrap(_getValue(_node, []));
}, "Node");

# Make a nicely formatted flaps/slats/etc display
string.formatflaps = func(flaps) {
	# FIXME: requires exact arguments for 0.25, etc.
	if (flaps <= 0.03)         "retracted";
	elsif (flaps == 0.25)      "at one-fourth";
	elsif (int(10*flaps) == 3) "at one-third";
	elsif (flaps == 0.5)       "at one-half";
	elsif (int(10*flaps) == 6) "at two-thirds";
	elsif (flaps == 0.75)      "at three-fourths";
	elsif (flaps >= 0.97)      "at full";
	elsif (flaps <= 0.12)      "at 1 tenth";
	else "at " ~ substr(flaps*10~"", 0, 1) ~ " tenths";
};

####################
## Throttle modes ##
####################

##
# Make a new throttle "object" (executable function) using modes from <root>, which can either be a
# global path to the root (e.g. /input/joysticks/js[0]) or a props.Node object containing the throttle
# modes. The generated function must be called with the current throttle value (0 to 1) and the current
# mode. If the mode is not specified then it looks at root/throttle-mode, which can either be a number
# or a path (local path from root) to the real throttle mode.
#
# Each mode is stored under root/throttle[n]/mode[m], where <n> is the <throttle number> that was passed
# and <m> is the iterator to walk through all entries. As can be seen below, in the Property Tree graph,
# each mode can contain <function> nodes and associated <min> and <max> nodes. This function can either
# be one of several designated special values, the name of a member of the control_functions hash (e.g.
# "aileron"), a Nasal script (detected by the presence of parenthesis), or the name of a property in
# the global property tree.
#
# In addition, the name of the control_function can include an optional index in brackets to specify which
# index to use for those controls, like throttle, that use props.setAll and have a property of the form
# "%s/%s[,]/%s", where the "[,]" will be replaced with "[%d]" for the correct index.  Also note that
# there can be multiple indices separated by commas (e.g. throttle[0,1,2,3]) or ranges using a hyphen
# (e.g. throttle[0-3]).
#
# Usage:   var fn = throttle(<throttle number>, <root>);
#          fn(<value from 0 to 1> [, <mode>]);
#
# Examples:
#
#   var throttle1 = throttle(0, "/input/joysticks/js[0]");
#   # Inside <binding> node:
#   throttle1(cmdarg().getNode("setting").getValue(), getlocalprop("throttle-mode"));
#
# Property Tree:
# root/mode[m]/throttle[n]/function[0] <required>
# root/mode[m]/throttle[n]/min[0]  <optional, value when input is at 0>
# root/mode[m]/throttle[n]/max[0]  <optional, value when input is at 1>
# root/mode[m]/throttle[n]/function[1] <optional, for doing something in parallel>
# root/mode[m]/throttle[n]/min[1]  <optional, for function[1]>
# root/mode[m]/throttle[n]/max[1]  <optional, for function[1]>
# [...]
#
var throttle = func(n, root) {
	if (typeof(root) == 'scalar')
		var root = props.globals.getNode(root);
	if (!isa(root, props.Node)) die("no root node");
	var cache = []; #a cache of values for multi-prop arguments
	                #(so that we can keep using a foreach loop)
	var modes = [];
	foreach (var mode; root.getChildren("mode")) {
		var mode = mode.getChild("throttle", n, 1);
		if (mode == nil) continue;
		var funcs = [];
		foreach (var function; mode.getChildren("function")) {
			if (function == nil or !function.getValue()) continue;
			var start_cache=0; #if we have just started a cache, set this to 1.
			append(funcs, (func { #hack to get a new closure to save
			                      #values, we immediately evaluate it.
				var min = mode.getNodeValue("min["~function.getIndex()~"]", 0);
				var max = mode.getNodeValue("max["~function.getIndex()~"]", 0);
				var function = function.getValue();
				# If min is "bool" then the axis is now a boolean property,
				# and max controls the "dead-band" around 0.5.
				# If max is < 0 or min is "-bool", then the axis is reversed
				# and max is normalized to be positive.
				if (min == "bool" or min == "-bool") {
					if (max == nil) {var max =  0.2; var reversed = 0}
					elsif (max < 0) {var max = -max; var reversed = 1}
					else var reversed = 0;
					if (min == "-bool") reversed = 1;
					return func(val) {
						if (val < 0.5-max) {
							setprop(function, reversed);
						} elsif (val > 0.5+max) {
							setprop(function, 1-reversed);
						}
					}
				} else {
					# A big block of implicit return:
					if (function == "average2") func(val) {
						setprop("/controls/engines/engine[1]/throttle",
						   (getprop("/controls/engines/engine[0]/throttle") +
							getprop("/controls/engines/engine[2]/throttle")) /2);
					} elsif (function == "average4") func(val) {
						setprop("/controls/engines/engine[2]/throttle",
						   (getprop("/controls/engines/engine[0]/throttle") +
							getprop("/controls/engines/engine[4]/throttle")) /2);
					# Most of these retained for backwards compatability:
					} elsif (function == "controls.throttleAxis()") {
						if (min==nil) var min=0;
						if (max==nil) var max=1;
						return func(val) {
							if (!control_functions.throttle.isControl("axis") or !control_functions.throttle.isActive()) return;
							var val2 = val*(max-min)+min;
							foreach(var e; controls.engines)
								if(e.selected.getValue())
									setprop("/controls/engines/engine[" ~ e.index ~ "]/throttle", val2);
						}
					} elsif (function == "controls.propellerAxis()") {
						if (min==nil) var min=0;
						if (max==nil) var max=1;
						return func(val) {
							if (!control_functions.propeller_pitch.isControl("axis") or !control_functions.propeller_pitch.isActive()) return;
							var val2 = val*(max-min)+min;
							foreach(var e; controls.engines)
								if(e.selected.getValue())
									setprop("/controls/engines/engine[" ~ e.index ~ "]/propeller-pitch", val2);
						}
					} elsif (function == "controls.mixtureAxis()") {
						if (min==nil) var min=0;
						if (max==nil) var max=1;
						return func(val) {
							if (!control_functions.mixture.isControl("axis") or !control_functions.mixture.isActive()) return;
							var val2 = val*(max-min)+min;
							foreach(var e; controls.engines)
								if(e.selected.getValue())
									setprop("/controls/engines/engine[" ~ e.index ~ "]/mixture", val2);
						}
					} elsif (function == "controls.conditionAxis()") {
						if (min==nil) var min=0;
						if (max==nil) var max=1;
						return func(val) {
							if (!control_functions.condition.isControl("axis") or !control_functions.condition.isActive()) return;
							var val2 = val*(max-min)+min;
							foreach(var e; controls.engines)
								if(e.selected.getValue())
									setprop("/controls/engines/engine[" ~ e.index ~ "]/condition", val2);
						}
					} elsif (function == "controls.flapsAxis()") {
						if (min==nil) var min=1; #switch the default values around
						if (max==nil) var max=0;
						var flaps = props.globals.getNode("/sim/flaps");
						if(flaps != nil and size(var settings = flaps.getChildren("setting")) > 1) return func(val) {
							# Stepped flaps movement:
							var last_setting = getprop("/controls/flight/flaps");
							var val2 = val*(max-min)+min;
							var last_value = 0;
							foreach (var set; settings) {
								var setting = set.getValue();
								if (val2 >= num(string.trim(setting~""))) { #the dassault-breguet super etendard has spaces around it's values
									var last_value = setting;
								} else {
									if (val2 < (last_value + setting) / 2)
										setprop("/controls/flight/flaps", last_value);
									else
										setprop("/controls/flight/flaps", setting);
									break;
								}
							}
							if ((var flaps = getprop("/controls/flight/flaps")) != last_setting)
								gui.popupTip("Flaps "~string.formatflaps(flaps));
						} else return func(val) {
							# Smooth flaps movement:
							var last_setting = getprop("/controls/flight/flaps");
							setprop("/controls/flight/flaps", val*(max-min)+min);
							var flaps = getprop("/controls/flight/flaps");
							var dt = getprop("/sim/time/delta-sec");
							if (flaps >= last_setting+0.05*dt or
							    flaps <= last_setting-0.05*dt)
								gui.popupTip("Flaps "~string.formatflaps(flaps));
						}
					} elsif (function == "f35.tiltAxis()") return func(val) {
						#min is the amount we go before the hatches start to close
						#FIXME: add some form of interpolation/timing
						var min = min ? min : 0.8;
						val2 = val > min ? (val-1)*0.5/(1-min)+1 : val*0.5/min;
						setprop("/controls/engines/engine/mixture", val2);
					} elsif (function == "v22.tiltAxis()") {
						if (min==nil) var min=0;
						if (max==nil) var max=1;
						return func(val) {
							val2 = val*(max-min)+min;
							v22.set_tilt(val2*100-10, 0);
						}
					} elsif (function == "brake-cmd") {
						if (min==nil) var min=1;
						if (max==nil) var max=0;
						return func(val) setbrakes(val*(max-min)+min, 0, "axis");
					} elsif (function == "flaps") {
						if (min==nil) var min=1;
						if (max==nil) var max=0;
						return func(val) control_functions.flaps.set("axis", val*(max-min)+min);
					} elsif (find("(", function)+1 and find(")", function)+1) {
						if (min==nil) var min=0;
						if (max==nil) var max=1;
						var code = compile(function, "joystick code");
						return func(val) code(val*(max-min)+min, val, min, max); #call with these args...
					} elsif (substr(function, 0, 13) == "split-control") {
						f = find(",", function);
						# The 'number' member in the hash below specifies
						# the total number of functions which we reserve via
						# the if statement below
						if (f == -1) {
							# by default we reserve this function and two others (top and bottom)
							var number = 3;
						} else {
							# otherwise we do "split-control:m,n"
							if (find(":", function) != 13) die();
							var number = 1+substr(function, 13, f-13)+substr(function, f);
						}
						append(cache, {
							function: function,
							min: min,
							max: max,
							number: number #we reserve this many function, min, max combinations
						});
						start_cache=1;
						return func{}; #placeholder function
					} else {
						if (find("/", function) == -1) {
							if (function[-1] == `]`) {
								var indices = []; #list of all indices like in throttle[0,1,2,3,4]
								var i = 0;
								while (i < size(function) and function[i] != `[`) i+=1;
								var start = i;
								if (i >= size(function)) die("bad index specifier, no opening bracket: "~function);

								while (i < size(function)) {
									if (i != start and function[i] != `,` and function[i] != `-`) break; #didn't get a separator, so stop
									var type = function[i] == `-`;
									i+=1; #skip over the comma/hyphen/opening bracket
									var last = i;
									while (i < size(function) and string.isdigit(function[i]))
										i += 1;
									if (i == last) die("empty index in string: "~function);
									#i is our first nondigit and i-last is the number of digits we have wandered through
									if ((var current = num(substr(function, i-1, i-last))) == nil) die(function~" "~i~" "~last); #get the number
									if (!type)
										append(indices, current);
									else {
										if (math.sgn(current-indices[-1]) > 0)
											for (var j=indices[-1]+1; j<=current; j+=1)
												append(indices, j);
										else
											for (var j=current; j<=indices[-1]-1; j+=1)
												append(indices, j);
									}
								}

								if (function[i] != `]`) die("bad index specifier: "~function);
								var function = substr(function, 0, start); #the rest of the function
							} else var indices = nil;
							if (contains(control_functions, function)) {
								var m = control_functions[function]; #save a couple hash lookups
								if (min==nil) if (m["min"] != nil) var min = m.min;
									          else var min = 0;
								if (max==nil) if (m["max"] != nil) var max = m.max;
									          else var max = 0;
								if (indices == nil or size(split("[,]/", m.prop)) != 2) {
									if (m["clipto"] != nil) return func(val) {
										# Draw a line from (0,min) to (1,max) and constrain it
										m.set("axis", m.clipto(val*(max-min)+min)) == nil ? return : nil;
									}
									else return func(val) {
										# Draw a line from (0,min) to (1,max)
										m.set("axis", val*(max-min)+min) == nil ? return : nil;
									}
								} else {
									var function = split("[,]", m.prop);
									if (size(indices) == 1) {
										var index = indices[0];
										if (m["clipto"] != nil) return func(val) {
											# Draw a line from (0,min) to (1,max) and constrain it
											m.set("axis", m.clipto(val*(max-min)+min), index) == nil ? return : nil;
										}
										else return func(val) {
											# Draw a line from (0,min) to (1,max)
											m.set("axis", val*(max-min)+min, index) == nil ? return : nil;
										}
									} else {
										if (m["clipto"] != nil) return func(val) {
											foreach (var index; indices) {
												# Draw a line from (0,min) to (1,max) and constrain it
												m.set("axis", m.clipto(val*(max-min)+min), index) == nil ? return : nil;
											}
										} else return func(val) {
											foreach (var index; indices) {
												# Draw a line from (0,min) to (1,max)
												m.set("axis", val*(max-min)+min, index) == nil ? return : nil;
											}
										}
									}
								}
							}
						}
						if (min==nil) var min=0;
						if (max==nil) var max=1;
						return func(val) {
							# Draw a line from (0,min) to (1,max)
							setprop(function, val*(max-min)+min);
						}
					}
				}
			})()); #end of closure

			if (size(cache) and !start_cache) {
				if (size(cache) < cache[0].number) {
					append(cache, {
						min: mode.getNodeValue("min["~function.getIndex()~"]", 0),
						max: mode.getNodeValue("max["~function.getIndex()~"]", 0),
						function: function.getValue()
					});
				}
				# TODO: extend to be generic "split-control:m,n"
				if (size(cache) == 3 and cache[0].function == "split-control") {
					if (cache[0].min == nil) cache[0].min = 0.5;
					if (cache[0].max == nil) cache[0].max = 0.05;
					if (cache[1].min == nil) cache[1].min = 1;
					if (cache[1].max == nil) cache[1].max = 0;
					if (cache[2].min == nil) cache[2].min = 0;
					if (cache[2].max == nil) cache[2].max = 1;
					(func { #another one!
						#save off our values:
						var (min0, max0, min1, max1, min2, max2) = (
						    cache[0].min, cache[0].max, cache[1].min,
						    cache[1].max, cache[2].min, cache[3].max
						);
						var (fn2, fn1) = (pop(funcs), pop(funcs));
						setsize(cache, 0);
						funcs[-1] = func(val) { #replace our placeholder
							if (val < min0 - max0) {
								# Draw a line from (0,0) to (min0-max0,1)
								var val2 = (val)*(min0-max0);
								fn1(val2);
							} elsif (val > min0 + max0) {
								# Draw a line from (min0+max0,0) to (1,1)
								var val2 = (val-min0-max0)*(1-min0-max0);
								fn2(val2);
							} #else 0;
						};
					})();
				} elsif (size(cache) >= cache[0].number) {
					die("bug: unhandled cache!");
				}
			}
		}
		append(modes, funcs);
	}
	return func(val, mode=nil) {
		if (mode == nil)
			#default node, can be a string pointing to another property that is local to the root
			var mode = root.getNodeValue("throttle-mode", 1);
		if (num(mode) == nil)
			var mode = num(root.getNode(mode).getValue());
		if (mode == nil) return;
		if (val == nil) val = 0;
		foreach(var fn; modes[mode])
			fn(val);
	};
};

##
# Function to add a new mode to the property tree according to the above "standard".
# The first argument is it's name and the other arguments (one per throttle) are
# either a vector with elements either singly or triply:
#
# Singly:
# function
#
# Triply:
# function, min, max
#
# Add together the elements to get the list:
# ["controls.throttleAxis()", "controls/engines/engine[0]/starter", "bool", nil]
#  ^--- single element ---^   ^--- three elements (function, min, and max) ---^
#         //function[0]               //function[1]                //min[1] //max[1]
#
# Or it can be a hash, with a functions vector that is the main iterator and contains
# either a scalar (in which case the min and max are pulled from the corresponding
# index in the minimums and maximums arrays) or a hash itself, which contains function,
# minimum, and maximum entries:
#
# { functions: [ "brake-cmd", "/my/brake/property" ],
#   minimums: [1, 1],
#   maximums: [0, 0]
# };
#
# { functions: [{ function: "brake-cmd", 
#             minimum: 1, maximum: 0
#           { function: "/my/brake/property",
#             minimum: 1, maximum: 0 } ]
# };
#
# { functions: [ "brake-cmd", 
#           { function: "/my/brake/functionerty",
#             minimum: 1, maximum: 0 } ],
#   minimums: [1], #or [1, nil]
#   maximums: [0]  #or [0, nil]
# };
#
# Then add another vector/hash for the next throttle. If there's only one function and
# no min or max for a particular throttle, then the brackets can be omitted, making
# it a scalar. Also, if a min or max equals nil, then it isn't set.
#
# If there is a min that equals -1 but the next max is not a number or does not exist
# (i.e. end-of-vector), then min is set to 1 and max is set to 0, thus reversing the
# control
#
#
# Usage:    addmode(<name>, <list...>);
#
# Examples:
#
# addmode("Throttle / DLC", "controls.throttleAxis()", ["/controls/flight/DLC", -1]);
#
var addmode = func(name, list...) {
	var mode = Joystick.getChildren("mode");
	if (mode != nil and size(mode)) {
		var mode = mode[-1];
		if (mode.getNode("name") == nil)
			var mode = mode.getIndex(); #use this node
		else
			var mode = mode.getIndex()+1; #use the next one
	} else var mode = 0;
	var _mode = Joystick.getChild("mode", mode, 1);
	_mode.getNode("name", 1).setValue(name);
	forindex (var throttle; list) {
		var _throttle = _mode.getChild("throttle", throttle, 1);
		var i = 0; var function = -1;
		if (typeof(list[throttle]) == 'vector') {
			while (i < size(list[throttle])) {
				var item = list[throttle][i];
				var is_path = !(num(item) != nil or item == "bool" or item == "-bool");
				if (is_path) {
					function += 1;
					_throttle.getChild("function", function, 1).setValue(item);
					i += 1;
				} else {
					#try and allow cases where -1 is a real minimum followed by a maximum
					#(determined by whether the next one is a number)
					if (item == -1 and
					    (i >= size(list[throttle])-1 or num(list[throttle][i+1]) == nil)) {
						_throttle.getChild("min", function, 1).setValue(1);
						_throttle.getChild("max", function, 1).setValue(0);
					} else {
						if (item != nil)
							_throttle.getChild("min", function, 1).setValue(item);
						item = (i+=1) < size(list[throttle]) ? list[throttle][i] : nil;
						if (item != nil)
							_throttle.getChild("max", function, 1).setValue(item);
					}
					i += 1;
				}
			}
		} elsif (typeof(list[throttle]) == 'scalar') {
			_throttle.getChild("function", 0, 1).setValue(list[throttle]);
		} elsif (typeof(list[throttle]) == 'hash') {
			if (!contains(list[throttle], "functions")) die("invalid/unrecognized argument to addmode()");
			if (!contains(list[throttle], "minimums")) list[throttle].minimums = [];
			if (!contains(list[throttle], "maximums")) list[throttle].maximums = [];
			setsize(list[throttle].minimums, size(list[throttle].functions));
			setsize(list[throttle].maximums, size(list[throttle].functions));
			forindex (var function; list[throttle].functions) {
				var item = list[throttle].functions[function];
				if (item==nil or !size(item)) continue; #do not increment our function count (the i variable)
				if (typeof(item) == 'hash') {
					_throttle.getNode("function", i, 1).setValue(item.function);
					if (item["minimum"] != nil)
						_throttle.getNode("min", i, 1).setValue(item.minimum);
					if (item["maximum"] != nil)
						_throttle.getNode("max", i, 1).setValue(item.maximum);
				} else {
					setlocalfunction(_mode ~ _throttle ~ "/function[" ~ i ~ "]", item);
					if (list[throttle].minimums[function] != nil)
						_throttle.getNode("min", i, 1).setValue(list[throttle].minimums[function]);
					if (list[throttle].maximums[function] != nil)
						_throttle.getNode("max", i, 1).setValue(list[throttle].maximums[function]);
				}
				i += 1;
			}
		} else die("invalid/unrecognized argument to addmode()");
	}
};

# An object to manage brakes
var brakes = {
	# Containers for each modifier (empty defaults):
	up: [func{},func{},func{}],
	down: [func{},func{},func{}],
	# Functions to fill them:
	speedbrake:func {
		if (!control_functions.speedbrake.isControl("button")) return;
		globals.controls.toggle("/controls/flight/speedbrake");
		var speedbrake = getprop("/controls/flight/speedbrake");
		if (allow_popupTips) gui.popupTip(sprintf("Speedbrake %s", speedbrake ? "EXTENDED":"RETRACTED"));
	},
	spoilers:func {
		if (!control_functions.spoilers.isControl("button")) return;
		globals.controls.toggle("/controls/flight/spoilers");
		var spoilers = getprop("/controls/flight/spoilers");
		if (allow_popupTips) gui.popupTip(sprintf("Spoilers %s", spoilers ? "EXTENDED":"RETRACTED"));
	},
	thrust_reverser:func {
		if (control_functions.thrust_reverser.toggle("button") == nil) return;
		if (allow_popupTips) gui.popupTip(sprintf("Thrust Reversers %s", reverser ? "DEPLOYED":"RETRACTED"));
	},
	parking:func {
		var brake = getprop("/controls/gear/brake-parking");
		setprop("/controls/gear/brake-parking", !brake);
		var brake = getprop("/controls/gear/brake-parking");
		if (allow_popupTips) gui.popupTip(sprintf("Parking Brake %s", brake ? "ON":"OFF"));
	},
	#main: {
	#	trigger: 0,
	#	adj: 0,
	#	axis: 0,
	#	net: 0,
	#	update: func {
	#		me.trigger = !!me.trigger;
	#		me.adj  = me.adj  < 1 ? (me.adj  > -1 ? me.adj  : -1) : 1;
	#		me.axis = me.axis < 1 ? (me.axis >  0 ? me.axis :  0) : 1;
	#		if (mod == 3) {
	#			me.net = (
	#				me.trigger+
	#				me.axis+
	#				me.adj
	#			);
	#		} else {
	#			me.net = (
	#				me.trigger+
	#				me.axis+
	#				me.adj
	#			);
	#		}
	#		me.net = me.net < 1 ? (me.net > 0 ? me.net : 0) : 1;
	#		setlocalprop("brake-cmd", me.net);
	#		return me.net;
	#	},
	#},
};

##
# Helper function to implement differential braking
# Should be called whenever rudder, modifier, or brake-cmd is changed
# (or once per frame)
#
var updatebrakes = func {
	if (control_functions.brakes.isControl("none")) return; #only change if the joystick has control
	var rudder = getprop("/controls/flight/rudder");
	var cmd = getlocalprop("brake-cmd");
	var left = var right = cmd==nil ? 0 : cmd;
	# When differential braking is selected
	if (mod == 3) {
		var left  -= rudder;
		var right += rudder;
	}
	left  = left  > 0 ? (left  < 1 ? left  : 1) : 0;
	right = right > 0 ? (right < 1 ? right : 1) : 0;
	setprop("/controls/gear/brake-left", left);
	setprop("/controls/gear/brake-right", right);
	return mod==3; #something useful...
};

##
# Set brakes and update them under the guise of control_name
#
var setbrakes = func(brake, relative=0, control_name="control") {
	#if (!control_functions.brakes.isControl(control_name)) return;
	if (relative)
		brake += getlocalprop("brake-cmd");
	brake = brake > 0 ? (brake < 1 ? brake : 1) : 0; #the wonferful quintenary operator... almost
	setlocalprop("brake-cmd", brake); updatebrakes();
};

###############
## Modifiers ##
###############

var mod_handled=0; #mod_handled is set when we are setting the modifier...
#...so that the listener does not try and pick it up
setlistener(Joystick.path ~ "/modifier", func {
	if (!mod_handled) mod = getprop(Joystick ~ "/modifier");
});

##
# Utility to handle mods, needs a /input/joysticks/js[n]/button[m]/number node
# (which is retrieved via cmdarg()). It does not need a state argument -- it can
# detect whether it is in a mod-up or a regular binding (FIXME: does it work
# for mod-ctrl, etc.?).
#
var modifier = func(state=nil) {
	var number = cmdarg().getParent(); #the getParent skips to above the <binding> node
	# First we skip mod-ctrls, etc., but not mod-up
	while (number.getName() != "mod-up"
	       and substr(number.getName(), 1, 4) == "mod-")
		number = number.getParent();
	# If we have reached a mod-up, then we hint state
	# to be false and jump up another node
	if (number.getName() == "mod-up") {
		number = number.getParent();
		if (state == nil) state = 0;
	# Otherwise we hint it do be true:
	} elsif (state == nil) state = 1;

	# Now we should be pointing to a button
	if (number.getName() != "button")
		die("modifier(): called from an invalid node: has to be a button");
	number = number.getNode("number");
	if (number == nil) die("modifier(): no number for this button");
	number = number.getValue();
	# Test that should not need to happen:
#	if (getlocalprop("modifier") < 0) {
#		mod = number*!!state;
#		printlog("warn", "Error: Cyborg-X: modifier(): modifier was less than 0");
#	} else {
		mod += state ? number : -number;
#	}
	mod_handled = 1; #set our lock
	setlocalprop("modifier", mod);
	mod_handled = 0; #and release it
};

##############################
## Control Function Library ##
##############################

##
# An object to manage the jamming you'll see later
# Each function takes a name, e.g. "axis" or "control"
# and checks for ownership of the control before doing
# an action. Special control names: "all", "none", and
# "" (empty string); the last one signifies "I don't care".
#
var control_function = {
	active: 1, default_control: "all",
	# Returns the name on success or nil if it is not active
	takeControl:func(name) if (me.isActive()) me.control = name,
	# Returns the default_control on success or nil if releasing control failed
	releaseControl:func(name) {
		if ((me.control != name and me.control != "all") or name == "none") return;
		me.control = me.default_control;
	},
	# Returns 1 if the name matches and is not "none" or the current control is "all"; else 0
	isControl:func(name) return (me.control == name and name != "none") or me.control == "all",
	# Returns whether the control is currently active. Default: 1.
	isActive:func() return me.active,
	# Set this control to the specified value if the name has control and the control is active; else nil
	set:func(name, value, index=nil) {
		if (!me.isControl(name) or !me.isActive()) return;
		if (!contains(me, "prop")) die("control_function.set cannot set a control without a property");
		var s = split("[,]/", me.prop);
		if (size(s) == 2)
			if (index == nil)
				props.setAll(s[0], s[1], value);
			else
				setprop(s[0]~"["~index~"]/"~s[1], value);
		else setprop(s[0], value);
	},
	# Get the value of this control if the name has control and the control is active; else nil
	get:func(name="", index=nil) {
		if (!me.isControl(name) or !me.isActive()) return;
		if (!contains(me, "prop")) die("control_function.get cannot get a control without a property");
		var s = split("[,]/", me.prop);
		if (size(s) == 2)
			if (index == nil) {
				# Basically a props.getAll, returning the average of all existing nodes
				var node = props.globals.getNode(s[0]);
				if(node == nil) return;
				var name = node.getName();
				node = node.getParent();
				if(node == nil) return;
				var children = node.getChildren(name);
				return call(math.avg, children);
			} else getprop(s[0]~"["~index~"]/"~s[1]);
		else return getprop(s[0]);
	},
	toggle:func(name="", switch=0.15, index=nil) {
		var v = me.get(name, index);
		if (v == nil) return;
		me.set(name, v <= switch, index);
	},
};

##
# All of our control functions (the main ones are written out here, odd ones
# and aircraft-specific ones are filled in below or in initialization.nas)
# Written in shorthand, btw (see below)
#
var control_functions = {
	aileron:          ",axis",
	elevator:         ",axis",
	rudder:           ",axis",
	throttle:         "axis,",
	propeller_pitch:  "axis,",
	mixture:          "axis,",
	condition:        "axis,",
	thrust_reverser:  "axis,/controls/engines/engine[,]/reverser",
	flaps:            ",control", #'control': the flapscontrol function; 'axis': second throttle
	slats:            ",control", # // ditto //
	DLC:              "all", #dummy
	aileron_droop :   "all", #and more dummy
	retractable_gear: "control,/controls/gear/gear-down", #'control': the gearcontrol function; 'axis': second throttle
	brakes:           "button,"~Joystick.path~"brake-cmd",  #'button':  setbrakes; 'trigger'; 'axis': second throttle
	tailhook:         "control,/controls/gear/tailhook",  #'control': the tailhookcontrol function
	spoilers:         ",button", #'button':  the brakes.spoilers function
	speedbrake:       ",button", #'button':  the brakes.speedbrake function
	starter:          "button,",
	battery_switch:   "button,/controls/electric/battery-switch",
	tailwheel_lock:   "button,/controls/gear/tailwheel-lock",
};

##
# Convert a Nasal lvalue (e.g. propeller_pitch) to a property node name
# (or XML's notion of an lvalue -- they're the same) following these rules:
#  * Two underscores in a row get converted to an underscore, to
#    allow for flexibility in names, and
#  * An underscore by itself gets converted to a hyphen
#
string.Nasal_to_XML = func(name) string.replace(string.replace(name, "_", "-"), "--", "_");
string.XML_to_Nasal = func(name) string.replace(string.replace(name, "_", "__"), "-", "_");

# fully initialize the entries...
foreach (var item; keys(control_functions)) {
	var fn = control_functions[item];
	if (typeof(fn) == 'scalar') {
		#debug.dump(fn);
		var f = find(",", fn);
		# If we don't have a comma, then we just have a default
		# control without a property and it isn't active by default
		if (f == -1) {
			control_functions[item] = {
				default_control: fn,
				active: 0,
				parents: [control_function]
			};
		# If it comes at the end, then we use the name and
		# prepend a fake engine "path" to it and use (min,max) = (0,1)
		} elsif (f == size(fn)-1) {
			control_functions[item] = {
				default_control: substr(fn, 0, f),
				prop: "/controls/engines/engine[,]/"~string.Nasal_to_XML(item, "_", "-"),
				min: 0, max:1,
				active: 1,
				parents: [control_function]
			};
		# If it comes at the beginning, then prepend
		# /controls/flight/ to the item name and use
		# (min,max) = (-1, 1)
		} elsif (f == 0) {
			control_functions[item] = {
				default_control: substr(fn, 1),
				prop: "/controls/flight/"~string.Nasal_to_XML(item, "_", "-"),
				min: -1, max: 1,
				active: 1,
				parents: [control_function]
			};
		# Otherwise we split it into control,prop
		} else {
			control_functions[item] = {
				default_control: substr(fn, 0, f),
				prop: substr(fn, f+1),
				active: 1,
				parents: [control_function]
			};
		}
	}
	# Now we initialize the current control as the default one
	control_functions[item].control = control_functions[item].default_control;
}
# Fix the minimum of some of these items:
control_functions.flaps.min = control_functions.slats.min = control_functions.spoilers.min
 = control_functions.speedbrake.min = 0;

##
# Use mixture (if 0) or condition (if 1) for main control
#
control_functions.use_condition = 0;

if (getprop("/fdm/jsbsim/systems/hook/tailhook-cmd-norm") != nil) {
	control_functions.tailhook.prop = "/fdm/jsbsim/systems/hook/tailhook-cmd-norm";
}
if (name == "c172p") {
	controls.startEngine = func(s=1) {
		setprop("/controls/switches/starter", s);
	}
}

##
# Get the controls used for a mode by the mode index
#
var getcontrolfuncs = func(idx=nil) {
	if (idx == nil) var idx = getlocalprop("throttle-mode");
	var modeN = Joystick.getChild("mode", idx);
	if (modeN == nil) return []; else
	var result = [];
	foreach (var thrN; modeN.getChildren("throttle"))
		foreach (var propN; thrN.getChildren("function"))
			if (contains(control_functions, split("[", propN.getValue())[0]))
				append(result, control_functions[split("[", propN.getValue())[0]]);
	return result;
};


##################################
## flapscontrol-esque functions ##
##################################

##
# Works like controls.flapsDown, 1 is down -1 is up
# Second, optional argument is the starting popupTip,
# which it returns after adding the necessary info
#
if (getprop("/sim/model/path") == "Aircraft/f-14b/Models/f-14b.xml" or
    getprop("/sim/model/path") == "Aircraft/F-14X/Models/F-14X.xml") {
	var flapscontrol = func(step, popupTip="") {
		var flaps = control_functions.flaps.get("control");
		if (flaps == nil) return popupTip; #must not have control of it
		if    (step > 0) f14.lowerFlaps();
		elsif (step < 0) f14.raiseFlaps();
		if (!getprop("/controls/flight/DLC-engaged") and
		    step > 0) {
			f14.toggleDLC();
			if (popupTip == "") popupTip = "DLC ENGAGED";
			else   popupTip = popupTip ~ "; DLC ENGAGED";
			control_functions.DLC.set("control", 0); #we don't want it to suddenly jump
		}
		if (step < 0) var aim = 0;
		else var aim = 1;
		if (step and flaps != aim) {
			globals.controls.flapsDown(step);
			if (popupTip == "") popupTip = "Flaps ";
			else   popupTip = popupTip ~ "; Flaps ";
			var flaps = control_functions.flaps.get("control");
			popupTip ~= string.formatflaps(flaps);
		}
		return popupTip;
	};
} elsif (getprop("/controls/flight/aileron-droop") != nil ) {
	control_functions.aileron_droop.prop = "/controls/flight/aileron-droop";
	control_functions.aileron_droop.active = 1;
	var flapscontrol = func(step, popupTip="") {
		var flaps = control_functions.flaps.get("control");
		if (flaps == nil) return popupTip; #must not have control of it
		if (step < 0) var aim = 0;
		else var aim = 1;
		if (step and flaps != aim) {
			globals.controls.flapsDown(step);
			if (popupTip == "") popupTip = "Flaps ";
			else   popupTip = popupTip ~ "; Flaps ";
			var flaps = control_functions.flaps.prop.get("control");
			control_functions.aileron_droop.set("control", flaps);
			popupTip ~= string.formatflaps(flaps);
		}
		return popupTip;
	};
} else {
	var flapscontrol = func(step, popupTip="") {
		var flaps = control_functions.flaps.get("control");
		if (flaps == nil) return popupTip; #must not have control of it
		if (step < 0) var aim = 0;
		else var aim = 1;
		if (step and flaps != aim) {
			globals.controls.flapsDown(step);
			if (popupTip == "") popupTip = "Flaps ";
			else   popupTip = popupTip ~ "; Flaps ";
			var flaps = control_functions.flaps.get("control");
			popupTip ~= string.formatflaps(flaps);
		}
		return popupTip;
	};
}

##
# Works like controls.stepSlats
#
var slatscontrol = func(step, popupTip="") {
	var slats = control_functions.slats.get("control");
	if (slats == nil) return popupTip; #must not have control of it
	if (step < 0) var aim = 0;
	else var aim = 1;
	if (step and slats != aim) {
		globals.controls.stepSlats(step);
		if (popupTip == "") popupTip = "Slats ";
		else   popupTip = popupTip ~ "; Slats ";
		var slats = control_functions.slats.get("control");
		popupTip ~= string.formatflaps(slats);
	}
	return popupTip;
};

##
# 1 is down, -1 is up
# Second, optional argument is the starting popupTip,
# which it returns after adding the necessary info
#
var tailhookcontrol = func(step, popupTip="") {
	if (step) {
		var flaps = control_functions.flaps.get("control");
		var tailhook = control_functions.tailhook.get("control");
		if (tailhook == nil) return popupTip; #must not have control of it
		if (step > 0) {
			if ((flaps == nil or flaps > 0.8) and tailhook == 0) {
				control_functions.tailhook.set("control", 1);
				if (popupTip == "") popupTip = "Tailhook DOWN";
				else   popupTip = popupTip ~ "; Tailhook DOWN";
			}
		} else { #if step < 0
			if (tailhook == 1) {
				control_functions.tailhook.set("control", 0);
				if (popupTip == "") popupTip = "Tailhook UP";
				else   popupTip = popupTip ~ "; Tailhook UP";
			}
		}
	}
	return popupTip;
};

##
# Works like controls.gearDown, 1 is down, -1 is up.
# Second, optional argument is the starting popupTip,
# which it returns after adding the necessary info
#
var gearcontrol = func(step, popupTip="") {
	if (step) {
		var gear = control_functions.retractable_gear.get("control");
		if (gear == nil) return popupTip;
		if (step < 0) {
			if (gear != 0 and !getprop("/gear/gear[0]/wow") and !getprop("/gear/gear[1]/wow") and !getprop("/gear/gear[2]/wow")) {
				globals.controls.gearDown(-1);
				if (popupTip == "") popupTip = "Gear UP";
				else   popupTip = popupTip ~ "; Gear UP";
			}
		} else { #if step > 0
			var gear = getprop("/controls/gear/gear-down");
			if (gear != 1) {
				globals.controls.gearDown(1);
				if (popupTip == "") popupTip = "Gear DOWN";
				else   popupTip = popupTip ~ "; Gear DOWN";
			}
		}
	}
	return popupTip;
};

# All the props that fall under 'TWS'
# Order: [prop, pre, [on, off], wow]
# Usage:
#   if (getprop(prop) != nil and in_air() != wow) popupTip ~= pre ~ [on, off][getprop(prop)];
var TWS_list = [
	["/fdm/jsbsim/fcs/fbw-override", "FBW system ", ["ACTIVE", "OVERRIDEN"], 0],
	["/fdm/jsbsim/systems/TWS/engaged", "TWS ", ["DISENGAGED", "ENGAGED"], 1],
	["/fdm/jsbsim/systems/NWS/engaged", "NWS ", ["DISENGAGED", "ENGAGED"], 1],
	["!/controls/gear/tailwheel-lock", "Tailwheel ", ["unlocked", "locked"], 1],
];

# Either toggle the group (n == nil) or set the value (n != nil)
# Tail-wheel steering, Nose-wheel steering, and FBW override are handled individually
var TWS = func(n=nil, popupTip="") {
	var in_air = in_air();
	if (n == nil) {
		foreach (var item; TWS_list) {
			var (prop, name, switch, wow) = item;
			if (prop[0] == `!`) {
				prop = substr(prop, 1);
			}
			if (getprop(prop) != nil and in_air != wow) {
				setprop(prop, !getprop(prop));
				popupTip ~= name ~ switch[getprop(prop)];
			}
		}
	} else {
		var has_one = 0;
		foreach (var item; TWS_list) {
			var (prop, name, switch, wow) = item;
			if (prop[0] == `!`) {
				prop = substr(prop, 1);
				var reverse = 1;
			} else var reverse = 0;
			if (getprop(prop) != nil and in_air != wow) {
				var has_one = 1;
				setprop(prop, reverse ? !n : n);
				popupTip ~= name ~ switch[getprop(prop)];
			}
		}
		if (!has_one) { #do autotrim instead
			n ? aircraft.autotrim.start() : aircraft.autotrim.stop();
			popupTip ~= n ? "Autotrimming" : "Autotrim complete";
		}
	}
	return popupTip;
};

