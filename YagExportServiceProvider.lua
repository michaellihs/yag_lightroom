--[[----------------------------------------------------------------------------

YagExportServiceProvider.lua
Publishing service description for Lightroom Yag publishing service

--------------------------------------------------------------------------------

Daniel Lienert & Michael Knoll
 Copyright 2011 Daniel Lienert und Michael Knoll
 see www.yag-gallery for further information
 All Rights Reserved.

This script is part of the yag project. The yag project is
free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

The GNU General Public License can be found at
http://www.gnu.org/copyleft/gpl.html.

This script is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

This copyright notice MUST APPEAR in all copies of the script!

------------------------------------------------------------------------------]]

------------------ IMPORTS ------------------

	-- Lightroom SDK
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrFileUtils = import 'LrFileUtils'
local LrPathUtils = import 'LrPathUtils'
local LrView = import 'LrView'

	-- Common shortcuts
local bind = LrView.bind
local share = LrView.share

	-- yag plug-in
require 'LoggerConfig'
require 'YagApi'
require 'YagPublishSupport'


--------------------------------------------------------------------------------

local exportServiceProvider = {}

-- We put publish specific hooks in a separate file file and load it here
for name, value in pairs( YagPublishSupport ) do
	exportServiceProvider[ name ] = value
end
--------------------------------------------------------------------------------

--- (optional) Plug-in defined value declares whether this plug-in supports the Lightroom
 -- publish feature. If not present, this plug-in is available in Export only.
 -- When true, this plug-in can be used for both Export and Publish. When 
 -- set to the string "only", the plug-in is visible only in Publish.
	-- @name exportServiceProvider.supportsIncrementalPublish
	-- @class property

exportServiceProvider.supportsIncrementalPublish = 'only'

--------------------------------------------------------------------------------

--- (optional) Plug-in defined value declares which fields in your property table should
 -- be saved as part of an export preset or a publish service connection. If present,
 -- should contain an array of items with key and default values. For example:
	-- <pre>
		-- exportPresetFields = {<br/>
			-- &nbsp;&nbsp;&nbsp;&nbsp;{ key = 'username', default = "" },<br/>
			-- &nbsp;&nbsp;&nbsp;&nbsp;{ key = 'fullname', default = "" },<br/>
			-- &nbsp;&nbsp;&nbsp;&nbsp;{ key = 'nsid', default = "" },<br/>
			-- &nbsp;&nbsp;&nbsp;&nbsp;{ key = 'privacy', default = 'public' },<br/>
			-- &nbsp;&nbsp;&nbsp;&nbsp;{ key = 'privacy_family', default = false },<br/>
			-- &nbsp;&nbsp;&nbsp;&nbsp;{ key = 'privacy_friends', default = false },<br/>
		-- }<br/>
	-- </pre>
 -- <p>The <code>key</code> item should match the values used by your user interface
 -- controls.</p>
 -- <p>The <code>default</code> item is the value to the first time
 -- your plug-in is selected in the Export or Publish dialog. On second and subsequent
 -- activations, the values chosen by the user in the previous session are used.</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @name exportServiceProvider.exportPresetFields
 	-- @class property

exportServiceProvider.exportPresetFields = {
	{ key = 'username', default = "" },
	{ key = 'fullname', default = "" },
	{ key = 'auth_token', default = '' },
}

--------------------------------------------------------------------------------

--- (optional) Plug-in defined value restricts the display of sections in the Export
 -- or Publish dialog to those named. You can use either <code>hideSections</code> or 
 -- <code>showSections</code>, but not both. If present, this should be an array 
 -- containing one or more of the following strings:
	-- <ul>
		-- <li>exportLocation</li>
		-- <li>fileNaming</li>
		-- <li>fileSettings</li>
		-- <li>imageSettings</li>
		-- <li>outputSharpening</li>
		-- <li>metadata</li>
		-- <li>watermarking</li>
	-- </ul>
 -- <p>You cannot suppress display of the "Connection Name" section in the Publish Manager dialog.</p>
 -- <p>If you suppress the "exportLocation" section, the files are rendered into
 -- a temporary folder which is deleted immediately after the Export operation
 -- completes.</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @name exportServiceProvider.showSections
	-- @class property

exportServiceProvider.showSections = { 
	'fileNaming', 
	'fileSettings',
	'imageSettings',
	'outputSharpening',
	'metadata',
	'watermarking'
}

--------------------------------------------------------------------------------

--- (optional) Plug-in defined value suppresses the display of the named sections in
 -- the Export or Publish dialogs. You can use either <code>hideSections</code> or 
 -- <code>showSections</code>, but not both. If present, this should be an array 
 -- containing one or more of the following strings:
	-- <ul>
		-- <li>exportLocation</li>
		-- <li>fileNaming</li>
		-- <li>fileSettings</li>
		-- <li>imageSettings</li>
		-- <li>outputSharpening</li>
		-- <li>metadata</li>
		-- <li>watermarking</li>
	-- </ul>
 -- <p>You cannot suppress display of the "Connection Name" section in the Publish Manager dialog.</p>
 -- <p>If you suppress the "exportLocation" section, the files are rendered into
 -- a temporary folder which is deleted immediately after the Export operation
 -- completes.</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @name exportServiceProvider.hideSections
	-- @class property

exportServiceProvider.hideSections = { 'exportLocation' }

--------------------------------------------------------------------------------

--- (optional) Plug-in defined value restricts the available file format choices in the
 -- Export or Publish dialogs to those named. You can use either <code>allowFileFormats</code> or 
 -- <code>disallowFileFormats</code>, but not both. If present, this should be an array
 -- containing one or more of the following strings:
	-- <ul>
		-- <li>JPEG</li>
		-- <li>PSD</li>
		-- <li>TIFF</li>
		-- <li>DNG</li>
		-- <li>ORIGINAL</li>
	-- </ul>
 -- <p>This property affects the output of still photo files only;
 -- it does not affect the output of video files.
 --  See <a href="#exportServiceProvider.canExportVideo"><code>canExportVideo</code></a>.)</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @name exportServiceProvider.allowFileFormats
	-- @class property

exportServiceProvider.allowFileFormats = { 'JPEG' }

--------------------------------------------------------------------------------

--- (optional) Plug-in defined value restricts the available color space choices in the
 -- Export or Publish dialogs to those named.  You can use either <code>allowColorSpaces</code> or 
 -- <code>disallowColorSpaces</code>, but not both. If present, this should be an array
 -- containing one or more of the following strings:
	-- <ul>
		-- <li>sRGB</li>
		-- <li>AdobeRGB</li>
		-- <li>ProPhotoRGB</li>
	-- </ul>
 -- <p>Affects the output of still photo files only, not video files.
 -- See <a href="#exportServiceProvider.canExportVideo"><code>canExportVideo</code></a>.</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @name exportServiceProvider.allowColorSpaces
	-- @class property

exportServiceProvider.allowColorSpaces = { 'sRGB' }
	
--------------------------------------------------------------------------------

--- (optional, Boolean) Plug-in defined value is true to hide print resolution controls
 -- in the Image Sizing section of the Export or Publish dialog.
 -- (Recommended when uploading to most web services.)
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @name exportServiceProvider.hidePrintResolution
	-- @class property

exportServiceProvider.hidePrintResolution = true

--------------------------------------------------------------------------------

--- (optional, Boolean)  When plug-in defined value istrue, both video and 
 -- still photos can be exported through this plug-in. If not present or set to false,
 --  video files cannot be exported through this plug-in. If set to the string "only",
 -- video files can be exported, but not still photos.
 -- <p>No conversions are available for video files. They are simply
 -- copied in the same format that was originally imported into Lightroom.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name exportServiceProvider.canExportVideo
	-- @class property

exportServiceProvider.canExportVideo = false -- video is not supported through this sample plug-in

--------------------------------------------------------------------------------

-- Yag specific: Helper functions and tables.

local function updateCantExportBecause( propertyTable )

	if not propertyTable.validAccount then
		propertyTable.LR_cantExportBecause = LOC "$$$/yag/ExportDialog/NoLogin=You haven't logged in to yag yet."
		return
	end
	
	propertyTable.LR_cantExportBecause = nil

end

--------------------------------------------------------------------------------

--- (optional) This plug-in defined callback function is called when the 
 -- user chooses this export service provider in the Export or Publish dialog, 
 -- or when the destination is already selected when the dialog is invoked, 
 -- (remembered from the previous export operation).
 -- <p>This is a blocking call. If you need to start a long-running task (such as
 -- network access), create a task using the <a href="LrTasks.html"><code>LrTasks</code></a>
 -- namespace.</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @param propertyTable (table) An observable table that contains the most
		-- recent settings for your export or publish plug-in, including both
		-- settings that you have defined and Lightroom-defined export settings
	-- @name exportServiceProvider.startDialog
	-- @class function

function exportServiceProvider.startDialog( propertyTable )

	-- Clear login if it's a new connection.
	
	if not propertyTable.LR_editingExistingPublishConnection then
		propertyTable.username = nil
		propertyTable.nsid = nil
		propertyTable.auth_token = nil
	end

	-- Can't export until we've validated the login.

	propertyTable:addObserver( 'validAccount', function() updateCantExportBecause( propertyTable ) end )
	updateCantExportBecause( propertyTable )

	-- Make sure we're logged in.

	require 'YagUser'
	YagUser.verifyLogin( propertyTable )

end

--------------------------------------------------------------------------------



return exportServiceProvider