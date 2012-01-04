--[[----------------------------------------------------------------------------

YagPublishingSupport.lua
Defines publishing-service specific hooks for yag publishing

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

	-- some shortcuts
local bind = import 'LrView'.bind
local logger = import 'LrLogger'( 'Yag' )

	-- yag plug-in
require 'LoggerConfig'
require 'YagUtils'
	
--------------------------------------------------------------------------------
	
local publishServiceProvider = {}

--------------------------------------------------------------------------------
--- (string) Plug-in defined value is the filename of the icon to be displayed
 -- for this publish service provider, in the Publish Services panel, the Publish 
 -- Manager dialog, and in the header shown when a published collection is selected.
 -- The icon must be in PNG format and no more than 26 pixels wide or 19 pixels tall.
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.small_icon
	-- @class property

publishServiceProvider.small_icon = 'small_yag.png'

--------------------------------------------------------------------------------

--- (optional) This plug-in defined callback function is called when the user
 -- creates a new published collection or edits an existing one. It can add
 -- additional controls to the dialog box for editing this collection. These controls
 -- can be used to configure behaviors specific to this collection (such as
 -- privacy or appearance on a web service).
 -- <p>This is a blocking call. If you need to start a long-running task (such as
 -- network access), create a task using the <a href="LrTasks.html"><code>LrTasks</code></a>
 -- namespace.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.viewForCollectionSettings
	-- @class function
	-- @param f (<a href="LrView.html#LrView.osFactory"><code>LrView.osFactory</code></a> object)
		-- A view factory object.
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
		-- <li><b>collectionSettings</b>: (<a href="LrObservableTable.html"><code>LrObservableTable</code></a>)
			-- Plug-in specific settings for this collection. The settings in this table
			-- are not interpreted by Lightroom in any way, except that they are stored
			-- with the collection. These settings can be accessed via
			-- <a href="LrPublishedCollection.html#pubCollection:getCollectionInfoSummary"><code>LrPublishedCollection:getCollectionInfoSummary</code></a>.
			-- The values in this table must be numbers, strings, or Booleans.
			-- There is a special property in this table, <code>LR_canSaveCollection</code>
			-- which allows you to disable the Edit or Create button in the collection dialog.
			-- (If set to true, the Edit / Create button is enabled; if false, it is disabled.)</li>
		-- <li><b>collectionType</b>: (string) Either "collection" or "smartCollection"
			-- (see also: <code>viewForCollectionSetSettings</code>)</li>
		-- <li><b>isDefaultCollection</b>: (Boolean) True if this is the default collection.</li>
		-- <li><b>name</b>: (name) The name of this collection.</li>
		-- <li><b>parents</b>: (table) An array of information about parents of this collection, in which each element contains:
			-- <ul>
				-- <li><b>localCollectionId</b>: (number) The local collection ID.</li>
				-- <li><b>name</b>: (string) Name of the collection set.</li>
				-- <li><b>remoteCollectionId</b>: (number or string) The remote collection ID assigned by the server.</li>
			-- </ul>
		-- This field is only present when editing an existing published collection.
		-- </li>
		-- <li><b>pluginContext</b>: (<a href="LrObservableTable.html"><code>LrObservableTable</code></a>)
			-- This is a place for your plug-in to store transient state while the collection
			-- settings dialog is running. It is passed to your plug-in's
			-- <code>endDialogForCollectionSettings</code> callback, and then discarded.</li>
		-- <li><b>publishedCollection</b>: (<a href="LrPublishedCollection.html"><code>LrPublishedCollection</code></a>)
			-- The published collection object being edited, or nil when creating a new
			-- collection.</li>
		-- <li><b>publishService</b>: (<a href="LrPublishService.html"><code>LrPublishService</code></a>)
		-- 	The publish service object to which this collection belongs.</li>
	-- </ul>
	-- @return (table) A single view description created from one of the methods in
		-- the view factory. (We recommend that <code>f:groupBox</code> be the outermost view.)
function publishServiceProvider.viewForCollectionSettings( f, publishSettings, info )

	local collectionSettings = assert( info.collectionSettings )
	
	logger:trace('CollectionSettings in dialog: ' .. YagUtils.toString(collectionSettings))

	if collectionSettings.enableRating == nil then
		collectionSettings.enableRating = false
	end

	if collectionSettings.enableComments == nil then
		collectionSettings.enableComments = false
	end

	return f:group_box {
		title = LOC "$$$/yag/CollectionDialog/Title=Album settings",
		size = 'small',
		fill_horizontal = 1,
		bind_to_object = assert( collectionSettings ),
		
		f:column {
			fill_horizontal = 1,
			spacing = f:label_spacing(),

			f:static_text {
				title = "Album name: " .. collectionSettings.albumName
			},
			
			f:static_text {
				title = "Album UID: " .. collectionSettings.albumUid
			}
		}
		
	}

end
--------------------------------------------------------------------------------

YagPublishSupport = publishServiceProvider