# A combo element like that in PUI
var Combo = {
	# Make a new one off of a Canvas group
	#
	# @param group The Canvas group to make this a child of
	# @param values The list of values to start out with
	new: func(group, values=nil, default=nil) {
		var me = {
			parents:[Combo, group.createChild("group")],
			values: values==nil?[]:values,
			_values: [],
			state: 0, #-1: show all; other: index of selected value
			listener: func{},
			spacing: 16,
			width: 160,
		};
		if (default != nil) me.state = me.findValue(default);
		var self = me.parents[1];
		me.transform = self.createTransform();
		self.addEventListener("click", func {
			var s = me.state = me.state == size(me.values) - 1 ? -1 : me.state+1;
			if (s < size(me.values))
				me.listener(s == -1 ? nil : me.values[s], s);
			me._drawValues();
		});
		me.fill = self.createChild("path");
		me.arrow = self.createChild("path")
			.moveTo(0,0)
			.horizTo(180)
			.moveTo(90,90)
			.close().show()
			.setColorFill(0,1,1);
		me._makeValues();
		me._drawValues();
		return me;
	},
	# Private; make text objects out of each value
	_makeValues: func() {
		foreach (var v; me._values) v.del();
		var x = me.transform.e.getValue();
		var y = me.transform.f.getValue();
		me._values = setsize([], size(me.values));
		forindex (var i; me.values) {
			me._values[i] = me.parents[1].createChild("text")
				.setText(me.values[i])
				.setTranslation(x, y)
				.setAlignment("left-top")
				.setFontSize(14)
				.setFont("LiberationFonts/LiberationSans-Bold.ttf")
				.setColor(1,1,1)
				.hide();
		}
		if (me.state < size(me.values))
			me._values[me.state].show();
	},
	# Private: position the values based upon me.state
	_drawValues: func() {
		if (size(me._values) != size(me.values)) print("Sizes differ!");
		var x=me.transform.e.getValue();
		var y=me.transform.f.getValue();
		if (me.state >= 0) {
			foreach (var v; me._values) v.hide().setTranslation(x,y);
			if (me.state < size(me._values))
				me._values[me.state].show();
			me.fill.reset()
				.moveTo(-4,-3)
				.horizTo(me.width)
				.vertTo(18)
				.horizTo(-4)
				.close()
				.setColorFill(0,0,0);
		} else {
			var incr = -me.spacing;
			foreach (var v; me._values) {
				v.show().setTranslation(x,y+(incr+=me.spacing));
			}
			me.fill.reset()
				.moveTo(-4,-3)
				.horizTo(me.width)
				.vertTo(18+incr)
				.horizTo(-4)
				.close()
				.setColorFill(0,0,0);
		}
	},
	# Add a new value into the list at the specified position
	#
	# @param value The value (string)
	# @param idx The index to add it in at; default: the end
	addValue: func(value, idx=-1) {
		if (!size(me.values) and (idx == 0 or idx == -1)) {
			me.values = [value];
			me._makeValues();
			return me;
		}
		if (idx < 0) idx += size(me.values);
		if (idx < 0 or idx >= size(me.values)) return me;
		if (idx == size(me.values)-1)
			me.values = me.values[:idx]~[value];
		else
			me.values = me.values[:idx]~[value]~me.values[idx+1:];
		me._makeValues();
		return me;
	},
	# Remove a value from the list
	#
	# @param value Either the value itself or its index
	removeValue: func(value) {
		var idx = me.findValue(value);
		if (idx == nil or idx < 0 or idx >= size(me.values)) return me;
		if (idx == size(me.values)-1)
			me.values = me.values[:idx-1];
		elsif (idx == 0)
			me.values = me.values[idx+1:];
		else
			me.values = me.values[:idx-1]~me.values[idx+1:];
		me._makeValues();
		return me;
	},
	# Set the listener for this box. Gets called when a new value is
	# selected with the value and index as arguments
	setListener: func(listener_fn) {
		me.listener = listener_fn;
		return me;
	},
	# Find a value in the list
	#
	# @param value Either the value itself or its index
	findValue: func(value) {
		if (num(value) != nil) return value;
		forindex (var i; me.values)
			if (me.values[i] == value) return i;
		return nil;
	},
	# Set the direction for this to open
	#
	# @param dir 1 for up, -1 for down
	setDir: func(dir=1) {
		me.set("direction", dir);
	},
};
