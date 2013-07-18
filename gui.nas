io.load_nasal(getprop("/sim/fg-root") ~ "/Nasal/elements.nas", "elements");

var mode_editor = nil;
var make_window = func {
	mode_editor = getprop("/sim/version/flightgear") == "2.10.0" ? canvas.Dialog.new([400,300]) : canvas.Window.new([400,300]);
	var my_canvas = mode_editor.createCanvas()
		                       .setColorBackground(0,0,0,0);
	var root = my_canvas.createGroup();
	# Title bar:
	var title_bar = root.createChild("group");
	title_bar.addEventListener("drag", func(e) { mode_editor.move(e.deltaX, e.deltaY); });
	var x = 0;
	var y = 0;
	var rx = 8;
	var ry = 8;
	var w = 400;
	var h = 20;
	title_bar.createChild("path")
		.moveTo(x + w - rx, y)
		.arcSmallCWTo(rx, ry, 0, x + w, y + ry)
		.vertTo(y + h)
		.horizTo(x)
		.vertTo(y + ry)
		.arcSmallCWTo(rx, ry, 0, x + rx, y)
		.close()
		.setColorFill(0.25,0.24,0.22)
		.setStrokeLineWidth(0);
	# Border
	y = 20;
	h = 280;
	root.createChild("path")
		.moveTo(x + w, y)
		.vertTo(y + h)
		.horizTo(x)
		.vertTo(y)
		.setColorFill(1,1,1)
		.setColor(0,0,0);
	# Red-X: close this dialog
	x = 8;
	y = 5;
	w = 10;
	h = 10;
	title_bar.createChild("path", "icon-close")
		.moveTo(x, y)
		.lineTo(x + w, y + h)
		.moveTo(x + w, y)
		.lineTo(x, y + h)
		.setColor(1,0,0)
		.setStrokeLineWidth(3)
		.addEventListener("click", func remove_window());
	# Title of this dialog
	title_bar.createChild("text", "dialog-caption")
		.setText("Joystick Mode Editor")
		.setTranslation(x + w + 8, 4)
		.setAlignment("left-top")
		.setFontSize(14)
		.setFont("LiberationFonts/LiberationSans-Bold.ttf")
		.setColor(1,1,1);
	var body = root.createChild("group");
		# Select your joystick:
		x = 4;
		y = 18;
		body.createChild("text")
			.setText("Selected joystick:")
			.setTranslation(x, 20+y+2)
			.setAlignment("left-baseline")
			.setFontSize(14)
			.setFont("LiberationFonts/LiberationSans-Bold.ttf")
			.setColor(0,0,0);
		x += 150;
		var joystick_list = elements.Combo.new(body, [], 0)
			.setTranslation(x, 20+y)
			.setListener(func {
				gui.popupTip("Joystick is "~(arg[0]==nil?"being selected":arg[0]~" at index "~arg[1]));
				if (arg[1] != -1) update_modes();
			});
		joystick_list.width = 90;
		joystick_list._drawValues(); #force update of width
		elements.Button.new(body, "Refresh", [60, 16])
			.setTranslation(x+=110, 20+y)
			.setListener(func {
				if (arg[0]) return;
				gui.popupTip("Refresh");
				update_joysticks();
			});
		# Select your mode:
		x = 4;
		y = 44;
		body.createChild("text")
			.setText("Selected mode:")
			.setTranslation(x, 20+y)
			.setAlignment("left-baseline")
			.setFontSize(14)
			.setFont("LiberationFonts/LiberationSans-Bold.ttf")
			.setColor(0,0,0);
		x += 150;
		var mode_list = elements.Combo.new(body, [], 0)
			.setTranslation(x, 20+y)
			.setListener(func {
				gui.popupTip("Mode is "~(arg[0]==nil?"being selected":arg[0]~" at index "~arg[1]));
				if (arg[1] != -1) make_throttles();
			});
		# hrule:
		var w = 400;
		body.createChild("path")
			.moveTo(4,75)
			.horizTo(w-4)
			.setColor(0,0,0);
		var sub_body = body.createChild("group");
			var make_throttles = func {
				sub_body.removeAllChildren();
				var y = 74;
				foreach (var thr; Joystick.getChild("mode", mode_list.state).getChildren("throttle")) {
					var x = 4;
					sub_body.createChild("text")
						.setText("Throttle "~(thr.getIndex()+1)~":")
						.setTranslation(x, 20+y)
						.setAlignment("left-baseline")
						.setFontSize(14)
						.setFont("LiberationFonts/LiberationSans-Bold.ttf")
						.setColor(0,0,0);
					y += 18;
					foreach (var fn; thr.getChildren("function")) {
						sub_body.createChild("text")
							.setText("Function "~(fn.getIndex()+1)~":")
							.setTranslation(x+=20, 20+y)
							.setAlignment("left-baseline")
							.setFontSize(14)
							.setFont("LiberationFonts/LiberationSans-Bold.ttf")
							.setColor(0,0,0);
						sub_body.createChild("text")
							.setText(fn.getValue())
							.setTranslation(x+80, 20+y)
							.setAlignment("left-baseline")
							.setFontSize(14)
							.setFont("LiberationFonts/LiberationSans-Regular.ttf")
							.setColor(0,0,0);
						sub_body.createChild("text")
							.setText("Min:")
							.setTranslation(x+=230, 20+y)
							.setAlignment("left-baseline")
							.setFontSize(14)
							.setFont("LiberationFonts/LiberationSans-Bold.ttf")
							.setColor(0,0,0);
						sub_body.createChild("text")
							.setText("Max:")
							.setTranslation(x+=70, 20+y)
							.setAlignment("left-baseline")
							.setFontSize(14)
							.setFont("LiberationFonts/LiberationSans-Bold.ttf")
							.setColor(0,0,0);
						y += 18;
					}
				}
			};

	var update_joysticks = func {
		while (size(joystick_list.values))
			joystick_list.removeValue(0);
		joystick_list.addValue("[none]").addValue("Cyborg-X").addValue("Missing").addValue("One?");
		#foreach (var js; Joystick.getParent().getChildren("js"))
		#	joystick_list.addValue(js.getNode("name").getValue());
	};
	var update_modes = func {
		while (size(mode_list.values))
			mode_list.removeValue(0);
		foreach (var mode; Joystick.getChildren("mode"))
			mode_list.addValue(mode.getNode("name").getValue());
		make_throttles();
	};
	update_joysticks();
	update_modes();

	mode_editor.listener = setlistener("/devices/status/keyboard/event", func(event) {
		if (!event.getNode("pressed").getValue())
			return;
		var key = event.getNode("key");
		var shift = event.getNode("modifier/shift").getValue();
		if (key.getValue() == 27 and !shift) {
			remove_window();
			key.setValue(-1);           # drop key event
		}
	});
};

var toggle_window = func {
	if (mode_editor != nil) remove_window();
	else {
		io.load_nasal(Joystick.Root ~ "/gui.nas", namespace); #reload ourselves for testing purposes
		make_window();
	}
};
var remove_window = func {
	removelistener(mode_editor.listener);
	mode_editor.del();
	mode_editor = nil;
};

