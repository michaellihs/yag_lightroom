--[[----------------------------------------------------------------------------

YagLoginDialog.lua
Implements a login dialog for login to yag remote service

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


local LrFunctionContext = import 'LrFunctionContext'
local LrView = import 'LrView'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrHttp = import 'LrHttp'
local LrErrors = import 'LrErrors'
local LrPathUtils = import 'LrPathUtils'

local prefs = import 'LrPrefs'.prefsForPlugin()
local bind = LrView.bind
local share = LrView.share

local logger = import 'LrLogger'( 'Yag' )


require "YagUtils"


--------------------------------------------------------------------------------

YagAccountDialog = {}

--------------------------------------------------------------------------------

function YagAccountDialog.showLoginDialog( message )

	LrFunctionContext.callWithContext( 'YagAccountDialog.showLoginDialog', function( context )

		local f = LrView.osFactory()
	
		-- get required properties from plugin's preferences
		local properties = LrBinding.makePropertyTable( context )
		properties.protocoll = prefs.protocoll	
		properties.domain = prefs.domain
		properties.port = prefs.port
		properties.username = prefs.username
		properties.password = prefs.password


		-- Configuration for yag account settings dialog
		local contents = f:column {
			bind_to_object = properties,
			spacing = f:control_spacing(),
			fill = 1,
	
			f:static_text {
				title = 'Login with your yag account settings',
				fill_horizontal = 1,
				width_in_chars = 55,
				height_in_lines = 2,
				size = 'small',
			},
			
			-- Protocoll (http:// per default)
			f:row {
				spacing = f:label_spacing(),
				
				f:static_text {
					title = 'Protocoll:',
					alignment = 'right',
					width = share 'title_width',
				},
				
				f:edit_field { 
					fill_horizonal = 1,
					width_in_chars = 10, 
					value = bind 'protocoll',
					-- TODO add validation for either http or https
					-- TODO make dropdownlist with http / https only
				},
			},
			
			-- Port (80 per default)
			f:row {
				spacing = f:label_spacing(),
				
				f:static_text {
					title = 'Port:',
					alignment = 'right',
					width = share 'title_width',
				},
				
				f:edit_field { 
					fill_horizonal = 1,
					width_in_chars = 4, 
					value = bind 'port',
				},
			},
			
			-- Domain
			f:row {
				spacing = f:label_spacing(),
				
				f:static_text {
					title = 'Domain:',
					alignment = 'right',
					width = share 'title_width',
				},
				
				f:edit_field { 
					fill_horizonal = 1,
					width_in_chars = 35, 
					value = bind 'domain',
				},
			},
			
			-- Username
			f:row {
				spacing = f:label_spacing(),
				
				f:static_text {
					title = 'Username:',
					alignment = 'right',
					width = share 'title_width',
				},
				
				f:edit_field { 
					fill_horizonal = 1,
					width_in_chars = 35, 
					value = bind 'username',
				},
			},
			
			-- Password
			f:row {
				spacing = f:label_spacing(),
				
				f:static_text {
					title = 'Password:',
					alignment = 'right',
					width = share 'title_width',
				},
				
				f:password_field { 
					fill_horizonal = 1,
					width_in_chars = 35, 
					value = bind 'password',
				},
			},
			

		}
		
		-- Here the before configured dialog is actually shown
		local result = LrDialogs.presentModalDialog {
				title = "Enter your yag account settings", 
				contents = contents
			}
		
		if result == 'ok' then 
			-- user pressed 'ok' button in dialog
			
			logger:trace('Login data when OK is pressed (properties):')
			logger:trace(YagUtils.toString(properties))
			
			prefs.username = YagUtils.trim ( properties.username )
			prefs.password = YagUtils.trim ( properties.password )
			prefs.protocoll = YagUtils.trim ( properties.protocoll )
			prefs.domain = YagUtils.trim ( properties.domain )
			prefs.port = YagUtils.trim ( properties.port )
			
			logger:trace('Prefs after OK is pressed (prefs):')
			logger:trace(YagUtils.toString(prefs))
		
		else
			-- error occured or 'cancel' has been pressed by user
			LrErrors.throwCanceled()
		
		end
	
	end )
	
end
