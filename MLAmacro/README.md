# MLAmacro
A simple macro to automatically insert a MLA header.
## Instructions
*(Sorry it's a bit dumbed down, made sense to do so at the time. The biggest thing is just to run `mlaDispConf` after importing before running `mlaFormatDoc`)*

For if you have no clue how to import and use this.
### -- Importing --
Follow these steps to import the MLA macros
1. Extract the zip if you have not already done so
2. Open the VBA editor by pressing ALT+F11 in word
3. Enter the import menu by pressing CTRL+M
4. Navigate to the unzipped file and import either MLAmodule.bas or MLAconfigForm.frm
5. Repeat steps 3 and 4 with the other file mentioned.
### -- Setup --
Following the steps in any one or more of these will give you the ability to run the macro much more easily.
#### - Keyboard Shortcuts - 
Note that Macros can only be binded to function keys (F1,F2,F3,etc) and Key Combinations (CTRL+A, SHIFT+B, ALT+C, etc)
1. Navigate to the "Customize Ribbon" tab of Word's settings
2. Click on the "Customize" button on the bottom left
3. Select the desired macro under "Macros"
4. Click on the box under "Press new shortcut key"
5. Input your shortcut keybind
6. Click on assign in the bottom left
7. Repeat as many times as you have macros of which you want to assign a keybind to and press "Close" and then "Ok"
To use press the keybind
#### - Quick Toolbar -
Put a symbol at the top of word (by "Autosave") that will run the macro when pressed.
1. Navigate to the "Quick Access Toolbar" tab of Word's settings
2. Click on the dropdown box in the top left and select Macros
3. Click on the desired macro on the left side and press "Add"
4. If desired, change the name and/or symbol of the button
	a. Click on the macro on the right side
	b. Press "Modify" underneath the right box
	c. Change the icon and name as desired and then press "Ok"
5. Repeat as many times as you have macros of which you want to assign a button to and press "Ok"
To use click the icon
#### - Developer Tab -
Allows you to run the macro through a popup. Less fluid then the other options
1. Navigate to the "Customize Ribbon" tab of Word's settings
2. Click on the checkbox next to "Developer" on the left side
3. Press "Ok"
Use the following instructions to run the macro
1. Navigate to the "Developer" tab in your document
2. Press the "Macros" button
3. Select the desired macro
4. Press "Run"
### Please run `mlaDispConf` after this setup
