Apart from the character json files, you can also add character scripts here, the script name must be the character target
For example for "bf.json" --> "bf.hx"

This type of script contains a special variable called "ScriptChar"
It will be the target character for the script
You can use it as a shortcut of for example State.boyfriend

It also contains the special callbacks "createChar()" and "destroyChar()"
called when the character is created (or switched to) and destroyed.