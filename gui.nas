var config_dlg  = gui.Dialog.new(Joystick.path ~ "/dialog","Input/Joysticks/Saitek/Cyborg-X/Dialog-Cyborg");

io.load_nasal(Joystick.Root ~ "/gui-elements.nas", "elements");

var state = {};

var mode_editor = nil;
var make_window = func {
	mode_editor = getprop("/sim/version/flightgear") == "2.10.0" ? canvas.Dialog.new([400,300]) : canvas.Window.new([400,300]);
	var my_canvas = mode_editor.createCanvas()
		                       .setColorBackground(0,0,0,0);
	var root = my_canvas.createGroup();
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
	y = 20;
	h = 280;
	root.createChild("path")
		.moveTo(x + w, y)
		.vertTo(y + h)
		.horizTo(x)
		.vertTo(y)
		.setColorFill(1,1,1)
		.setColor(0,0,0);
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
		.addEventListener("click", func {mode_editor.del(); mode_editor = nil});
	title_bar.createChild("text", "dialog-caption")
		.setText("Joystick Mode Editor")
		.setTranslation(x + w + 8, 4)
		.setAlignment("left-top")
		.setFontSize(14)
		.setFont("LiberationFonts/LiberationSans-Bold.ttf")
		.setColor(1,1,1);
	var body = root.createChild("group");
		x = 4;
		y = 4;
		body.createChild("text")
			.setText("Selected joystick:")
			.setTranslation(x, 20+y+2)
			.setAlignment("left-top")
			.setFontSize(14)
			.setFont("LiberationFonts/LiberationSans-Bold.ttf")
			.setColor(0,0,0);
		x += 150;
		var joystick_list = elements.Combo.new(body, [], 0)
			.setTranslation(x, 20+y)
			.setListener(func gui.popupTip("Joystick is "~(arg[0]==nil?"being selected":arg[0]~" at index "~arg[1])));
		x = 4;
		y = 30;
		body.createChild("text")
			.setText("Selected mode:")
			.setTranslation(x, 20+y)
			.setAlignment("left-top")
			.setFontSize(14)
			.setFont("LiberationFonts/LiberationSans-Bold.ttf")
			.setColor(0,0,0);
		x += 150;
		var mode_list = elements.Combo.new(body, [], 0)
			.setTranslation(x, 20+y)
			.setListener(func gui.popupTip("Mode is "~(arg[0]==nil?"being selected":arg[0]~" at index "~arg[1])));
		var w = 400;
		body.createChild("path")
			.moveTo(4,75)
			.horizTo(w-4)
			.setColor(0,0,0);
	joystick_list.addValue("[none]");
	foreach (var js; Joystick.getParent().getChildren("js"))
		joystick_list.addValue(js.getNode("name").getValue());
	foreach (var mode; Joystick.getChildren("mode"))
		mode_list.addValue(mode.getNode("name").getValue());
	state = caller(0)[0];
};

var toggle_window = func {
	if (mode_editor != nil) {mode_editor.del(); mode_editor = nil}
	else {
		io.load_nasal(Joystick.Root ~ "/gui.nas", namespace);
		make_window();
	}
};

