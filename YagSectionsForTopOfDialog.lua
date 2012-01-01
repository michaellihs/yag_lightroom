--[[----------------------------------------------------------------------------

YagSectionsForTopOfDialog.lua
Defines additional dialog section for Publishing Dialog for yag publishing

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

	-- Lightroom SDK
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrFileUtils = import 'LrFileUtils'
local LrPathUtils = import 'LrPathUtils'
local LrView = import 'LrView'

	-- Common shortcuts
local bind = LrView.bind
local share = LrView.share
local prefs = import 'LrPrefs'.prefsForPlugin()
local logger = import 'LrLogger'( 'Yag' )

	-- yag plug-in
require 'LoggerConfig'

--------------------------------------------------------------------------------

YagSectionsForTopOfDialog = {}

function YagSectionsForTopOfDialog.getSectionsForTopOfDialog( f, propertyTable )

	return {
	
		{
			title = LOC "$$$/yag/ExportDialog/Account=Yag Account",
			
			synopsis = bind 'accountStatus',
	
			f:row {
				spacing = f:control_spacing(),
	
				f:static_text {
					title = bind 'accountStatus',
					alignment = 'right',
					fill_horizontal = 1,
				},
	
				f:push_button {
					width = tonumber( LOC "$$$/locale_metric/Flickr/ExportDialog/LoginButton/Width=90" ),
					title = bind 'loginButtonTitle',
					enabled = bind 'loginButtonEnabled',
					action = function()
						require 'YagUser'
						YagUser.login( propertyTable )
					end,
				},
	
			},
		},
	
	}

end

