# ![](./DVScreenPrinter.ico) DVScreenPrinter Utility
----------------------------------------------------
Makes capturing data analysis charts a snap. Provides a high level of customization
and functionality in order to allow you to capture images in many formats, in 1 click.


Changelog
----------------------------------------------------

### 2.2.6
- Fixed: Auto versioning & version display in tray/settings GUI
- Changed: Cleaned up source files and created a build dir

### 2.2.5
-Fixed: $rssNum tag now also matches 3 digit collar # - build #, CS # and SS #
-Fixed: DV window titles no longer must contain " - TerraVici DataViewer", window matching now uses DV's window class
### 2.2.4
-Added: Command with customizable hotkey to open the root capture folder
-Fixed: Tag stripping now strips values until a valid folder path is found

### 2.1.3
- Added: $appDir tag which results in the full path of the folder containing the DVScreenPrinter app
- Added: browse button on folder settings to open to best matching folder from current setting
- Fixed: 'Close all DV Windows' command
- Cleaned up version changelog

### 2.1.1
- Proper Handling of launching captures folder, regardless of tags
- Added: Option to automatically close all DataViewer windows after capture
- Added: 'Close all DataViewer Windows' command to tray menu
- Added: 'Open Captures Folder' command to tray menu

### 2.1.0
- Added options to backup & import settings to/from files
- Fixed bug when saving new hotkey
- Re-organized settings
- Added version to settings.xml

### 2.0.2
- Fixed: Reload application after changing a hotkey setting

### 2.0.1
- Updated extensions list

### 2.0.0
- Changed to use GDIPlus library to create screen captures instead of the minicap utility
- Highly improved speed and reliability

### 1.8
- Placeholder tags can be used in the capture folder & file setting values.
  $windowName, $rssNum, $fileName, $filePath, $date and $time tags are available
- Settings are now saved in user's AppData folder
- Optimized capture method to attempt to improve speed
- Changed up the tray menu for easier access to commands

### 1.7
- Fixed: restore each window before capturing to prevent random black screens

### 1.6
- Added option to set the default double-click tray icon behavior
- Changed default save dir to the script's dir\Captures
- Added settings GUI; reads/writes settings to xml
- Added hotkey support (customizable)
