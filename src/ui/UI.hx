package ui;

import haxe.ui.containers.HBox;
import haxe.ui.Toolkit;
import lime.ui.FileDialog;
import haxe.ui.core.Screen;
import lime.ui.FileDialogType;
import haxe.ui.containers.Grid;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import haxe.ui.components.Button;
import haxe.ui.components.CheckBox;
import haxe.ui.components.TextField;
import haxe.ui.macros.ComponentMacros;

class UI extends openfl.display.Sprite
{
	static var leftColumn: VBox;
	static var rightColumn: VBox;

	static var components: HBox;
	static var buttons: HBox;

	static var paths: Grid;
	static var others: Grid;

	static var dolphinTextField: TextField;
	static var replaysTextField: TextField;
	static var obsTextField: TextField;
	static var meleeTextField: TextField;
	static var videosTextField: TextField;

	static var dolphinButton: Button;
	static var replaysButton: Button;
	static var obsButton: Button;
	static var meleeButton: Button;
	static var videosButton: Button;

	static var portTextField: TextField;
	static var passwordTextField: TextField;
	static var profileTextField: TextField;
	static var sceneTextField: TextField;

	static var recursive: CheckBox;
	static var rename: CheckBox;
	static var restructure: CheckBox;
	static var kill: CheckBox;

	static var saveButton: Button;

	public function new() {
		super();

		initComponents();
		setStyles();
	}

	static function initComponents(): Void {
		Toolkit.init();
		var ui = ComponentMacros.buildComponent('assets/ui/ui.xml');
		Screen.instance.addComponent(ui);
		leftColumn = ui.findComponent('leftColumn', VBox);
		rightColumn = ui.findComponent('rightColumn', VBox);

		components = ui.findComponent('components', HBox);
		buttons = ui.findComponent('buttons', HBox);

		paths = ui.findComponent('paths', Grid);
		others = ui.findComponent('others', Grid);

		dolphinTextField = ui.findComponent('dolphinTextField', TextField);
		replaysTextField = ui.findComponent('replaysTextField', TextField);
		obsTextField = ui.findComponent('obsTextField', TextField);
		meleeTextField = ui.findComponent('meleeTextField', TextField);
		videosTextField = ui.findComponent('videosTextField', TextField);

		dolphinButton = ui.findComponent('dolphinButton', Button);
		replaysButton = ui.findComponent('replaysButton', Button);
		obsButton = ui.findComponent('obsButton', Button);
		meleeButton = ui.findComponent('meleeButton', Button);
		videosButton = ui.findComponent('videosButton', Button);

		portTextField = ui.findComponent('port', TextField);
		passwordTextField = ui.findComponent('password', TextField);
		profileTextField = ui.findComponent('profile', TextField);
		sceneTextField = ui.findComponent('scene', TextField);

		recursive = ui.findComponent('recursive', CheckBox);
		rename = ui.findComponent('rename', CheckBox);
		restructure = ui.findComponent('restructure', CheckBox);
		kill = ui.findComponent('kill', CheckBox);

		saveButton = ui.findComponent('saveButton', Button);

		setEventListeners();
	}

	static function setEventListeners(): Void {

		inline function onSelect(fd: FileDialog, tf: TextField): Void {
			fd.onSelect.add(function(s: String) {tf.text = s;});
		}

		inline function onClick(fdt: FileDialogType, name: String, tf: TextField, ?filter: String): MouseEvent -> Void {
			var fd = new FileDialog();

			return function(evt: MouseEvent) {
				onSelect(fd, tf);
				fd.browse(fdt, filter, null, name);
			}
		}

		dolphinButton.onClick = onClick(
			FileDialogType.OPEN, 'Dolphin.exe', dolphinTextField, 'exe'
		);

		replaysButton.onClick = onClick(
			FileDialogType.OPEN_DIRECTORY, 'Replays folder', replaysTextField
		);

		obsButton.onClick = onClick(
			FileDialogType.OPEN, 'OBS32.exe / OBS64.exe', obsTextField, 'exe'
		);

		meleeButton.onClick = onClick(
			FileDialogType.OPEN, 'Melee NTSC 1.02 .iso', meleeTextField, 'iso'
		);

		videosButton.onClick = onClick(
			FileDialogType.OPEN_DIRECTORY, 'Videos folder', videosTextField
		);

		saveButton.onClick = saveConfig;
	}

	static function setStyles(): Void {
		for (box in [leftColumn, rightColumn, buttons]) {
			box.marginLeft = 10;
			box.marginTop = 10;
			box.marginBottom = 10;
			box.marginRight = 10;
		}

	}

	static function loadConfig(): Void {

	}

	static function saveConfig(evt: MouseEvent): Void {

	}

}
