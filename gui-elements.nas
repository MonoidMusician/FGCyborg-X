# A combo element like that in PUI
var Combo = {
	# Make a new one off of a Canvas group
	#
	# @param group The Canvas group to make this a child of
	# @param values The list of values to start out with
	new: func(group, values=nil, default=nil) {
		var me = {
			parents:[Combo, group.createChild("group")],
			values: values==nil?[]:values, #vector<string> of values: should this be in the property tree?
			_values: [], #vector<canvas.Text>: handles to canvas.Text objects to manipulate each value
			state: 0, #-1: show all; other: index of selected value
			listener: func{}, #a function that gets called when clicked
			spacing: 18, #parameter: y increment between text elements
			border: 4, #parameter: spacing around various elements
			font_sz: 14,
			width: 170, #width of this box
		};
		if (default != nil) me.state = me.findValue(default);
		me.addEventListener("click", func(e) {
			var y=me._getTf().f.getValue();
			if (me.state == -1) {
				me.set("z-index", 0);
				y-=me.spacing/2; #correct for the center alignment of the text
				y-=2; #and a couple more for the baseline alignment
				var s = nil;
				for (var i=1; i<=size(me.values); i+=1)
					if (e.clientY < y+me.spacing*i) {var s = me.state = i-1; break}
				if (s != nil)
					me.listener(me.values[s], s, e);
				else
					die("Invalid mouse click");
			} else {
				me.state = -1;
				me.set("z-index", 1);
				me.listener(nil, -1, e);
			}
			me._drawValues();
		});
		me.fill = me.createChild("path");
		me._makeValues();
		me._drawValues();
		return me;
	},
	# Private; make text objects out of each value
	_makeValues: func() {
		foreach (var v; me._values) v.del();
		me._values = setsize([], size(me.values));
		forindex (var i; me.values) {
			me._values[i] = me.parents[1].createChild("text")
				.setText(me.values[i])
				.setTranslation(0, 0)
				.setAlignment("left-baseline")
				.setFontSize(me.font_sz)
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
		if (me.state >= 0) {
			foreach (var v; me._values) v.hide().setTranslation(0,0);
			if (me.state < size(me._values))
				me._values[me.state].show();
			me.fill.reset()
				.moveTo(-me.border,-me.font_sz/2-me.border*2)
				.horizTo(me.width)
				.vertTo(me.font_sz/2)
				.horizTo(-me.border)
				.close()
				.setColorFill(0,0,0);
		} else {
			var incr = -me.spacing;
			foreach (var v; me._values) {
				v.show().setTranslation(0,incr+=me.spacing);
			}
			me.fill.reset()
				.moveTo(-me.border,-me.font_sz/2-me.border*2)
				.horizTo(me.width)
				.vertTo(me.font_sz/2+incr)
				.horizTo(-me.border)
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
		if (idx == 0 and size(me.values) == 1)
			me.values = [];
		elsif (idx == size(me.values)-1)
			me.values = me.values[:idx-1];
		elsif (idx == 0)
			me.values = me.values[idx+1:];
		else
			me.values = me.values[:idx-1]~me.values[idx+1:];
		me._makeValues();
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
	# Set the listener for this box. Gets called when a new value is
	# selected with the value and index as arguments
	setListener: func(listener_fn) {
		me.listener = listener_fn;
		return me;
	},
};


# A button element like that in PUI
var Button = {
	# Make a new one off of a Canvas group
	#
	# @param group The Canvas group to make this a child of
	# @param label The label to give to this
	# @param sz [Width,Height]
	new: func(group, label, sz) {
		var me = {
			parents:[Button, group.createChild("group")],
			listener: func{}, #a function that gets called when clicked
			border: 4, #parameter: spacing around various elements
			font_sz: 14,
			width: sz[0], #width of this box
			height: sz[1], #height of this box
		};
		me.set("id", "identifier");
		me.addEventListener("mousedown", func(e) {
			me.listener(1, e);
		});
		me.addEventListener("mouseup", func(e) {
			me.listener(0, e);
		});
		me.fill = me.createChild("path");
		me._drawFill();
		me.text = me.createChild("text")
			.setText(label)
			.setTranslation(0, 0)
			.setAlignment("left-baseline")
			.setFontSize(14)
			.setFont("LiberationFonts/LiberationSans-Bold.ttf")
			.setColor(0,0,0);
		return me;
	},
	# Private: update/draw the filler
	_drawFill: func() {
		me.fill.reset()
			.moveTo(-4,-4)
			.horizTo(me.width+4)
			.vertTo(me.height+4)
			.horizTo(-4)
			.close().show()
			.setFill(1,0,0);
	},
	# Set the listener for this box. Gets called when a new value is
	# selected with the value and index as arguments
	setListener: func(listener_fn) {
		me.listener = listener_fn;
		return me;
	},
	# Set the width of this button
	setWidth: func(n) {
		me.width = n;
		me._drawFill();
		return me;
	},
	# Set the height of this button
	setHeight: func(n) {
		me.height = n;
		me._drawFill();
		return me;
	},
};

