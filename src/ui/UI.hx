package ui;

import haxe.ui.containers.VBox;
import haxe.ui.components.Switch;
import haxe.ui.components.Button;
import haxe.ui.components.TextField;
import haxe.ui.Toolkit;
import lime.ui.FileDialog;
import haxe.ui.core.Screen;
import lime.ui.FileDialogType;
import haxe.ui.containers.Grid;
import haxe.ui.macros.ComponentMacros;

class UI extends openfl.display.Sprite
{
	static var leftColumn: VBox;
	static var rightColumn: VBox;

	static var paths: Grid;
	static var others: Grid;
	static var switches: Grid;

	static var dolphinPath: TextField;
	static var replaysPath: TextField;
	static var obsPath: TextField;
	static var meleePath: TextField;
	static var videosPath: TextField;

	static var dolphinButton: Button;
	static var replaysButton: Button;
	static var obsButton: Button;
	static var meleeButton: Button;
	static var videosButton: Button;

	static var port: TextField;
	static var password: TextField;
	static var profile: TextField;
	static var scene: TextField;

	static var recurse: Switch;
	static var rename: Switch;
	static var restructure: Switch;
	static var kill: Switch;

	public static function initComponents() {
		Toolkit.init();
		var ui = ComponentMacros.buildComponent('assets/ui/ui.xml');
		Screen.instance.addComponent(ui);
		leftColumn = ui.findComponent('leftColumn', VBox);
		rightColumn = ui.findComponent('rightColumn', VBox);

		paths = ui.findComponent('paths', Grid);
		others = ui.findComponent('others', Grid);
		switches = ui.findComponent('switches', Grid);

		dolphinPath = ui.findComponent('dolphinPath', TextField);
		replaysPath = ui.findComponent('replaysPath', TextField);
		obsPath = ui.findComponent('obsPath', TextField);
		meleePath = ui.findComponent('meleePath', TextField);
		videosPath = ui.findComponent('videosPath', TextField);

		dolphinButton = ui.findComponent('dolphinButton', Button);
		replaysButton = ui.findComponent('replaysButton', Button);
		obsButton = ui.findComponent('obsButton', Button);
		meleeButton = ui.findComponent('meleeButton', Button);
		videosButton = ui.findComponent('videosButton', Button);

		port = ui.findComponent('port', TextField);
		password = ui.findComponent('password', TextField);
		profile = ui.findComponent('profile', TextField);
		scene = ui.findComponent('scene', TextField);

		recurse = ui.findComponent('recurse', Switch);
		rename = ui.findComponent('rename', Switch);
		restructure = ui.findComponent('restructure', Switch);
		kill = ui.findComponent('kill', Switch);
	}

	public function new()
	{
		super();
		initComponents();
		leftColumn.marginLeft = 10;
		leftColumn.marginTop = 10;
		leftColumn.marginBottom = 10;
		leftColumn.marginRight = 10;
		rightColumn.marginLeft = 10;
		rightColumn.marginTop = 10;
		rightColumn.marginBottom = 10;
		rightColumn.marginRight = 10;

		var fd = new FileDialog();
		fd.browse(FileDialogType.OPEN, 'exe', null, 'Dolphin.exe');

		fd.onSelect.add(function(path: String) {
			trace(path);
		});
	}

}
