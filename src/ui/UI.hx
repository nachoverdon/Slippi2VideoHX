package ui;

import haxe.ui.Toolkit;
import lime.ui.FileDialog;
import haxe.ui.core.Screen;
// import lime.app.Application;
import lime.ui.FileDialogType;
import haxe.ui.macros.ComponentMacros;

class UI extends openfl.display.Sprite
{
	public function new()
	{
		super();
		Toolkit.init();
		var ui = ComponentMacros.buildComponent('assets/ui/ui.xml');
		Screen.instance.addComponent(ui);

		var fd = new FileDialog();
		fd.browse(FileDialogType.OPEN, 'exe', null, 'Dolphin.exe');

		fd.onSelect.add(function(path: String) {
			trace(path);
		});
	}
}
