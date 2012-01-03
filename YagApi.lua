--[[----------------------------------------------------------------------------

YagApi.lua
Defines Yag API for Lightroom

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

-- Load Plugin's preferences
local prefs = import 'LrPrefs'.prefsForPlugin()
local logger = import 'LrLogger'( 'Yag' )

require 'YagAccountDialog'
require 'YagUtils'

--------------------------------------------------------------------------------

YagApi = {}

--------------------------------------------------------------------------------

--- Returns login information for given yag account.
 -- Login information is either gathered from prefs table or a account dialog is shown to the user
 -- where account settings can be given.
function YagApi.getLoginInformation()

	local username = prefs.username
	local password = prefs.password
	local domain = prefs.domain
	local protocoll = prefs.protocoll
	local port = prefs.port
	
	while not(
		type( username )  == 'string' and #username > 0 and
		type( password )  == 'string' and #password > 0 and
		type( domain )    == 'string' and #domain > 0 and
		type( protocoll ) == 'string' and #protocoll > 0 and
		type( port )      == 'string' and #port > 0
	) do
	
		local message
		if username then
			message = "Your yag login does not seem to be valid!"
		end

		-- If we do not have login data, show login / account dialog
		YagAccountDialog.showLoginDialog( message )

		username = prefs.username
		password = prefs.password
		domain = prefs.domain
		protocoll = prefs.protocoll
		port = prefs.port

		loginInformation = {
			username = username,
			password = password,
			domain = domain,
			protocoll = protocoll,
			port = port
		}
	
	end
	
	logger:trace('loginInformation:')
	logger:trace(YagUtils.toString(loginInformation))
	
	return loginInformation

end

--------------------------------------------------------------------------------

--- Does a login on yag server with given login information
 -- If login succeeds, true and a auth_token will be returned
 -- If login does not succeed, false is returned as single return value
    -- @param loginInformation Table with login information
    -- @return bool, string True, if login succeeds. Auth token as string
function YagApi.login(loginInformation) 

	logger:trace('YagApi.login with loginInformation:')
	logger:trace(YagUtils.toString(loginInformation))

	for k,v in pairs(loginInformation) do
		logger:trace('Key: ' .. YagUtils.toString(k) .. ' - Value: ' .. YagUtils.toString(v))
	end

	-- TODO implement actual login!
	if loginInformation.username == 'mimi' then
		--logger:trace('YagApi.login has correct username: ' .. loginInformation.username)
		return true, 'auth_token-' .. loginInformation.username .. ':' .. loginInformation.url
	else 
		--logger:trace('YagApi.login has incorrect username: ' .. loginInformation.username)
		return false
	end

end

--------------------------------------------------------------------------------

--- Returns a set of collections for connection in given propertyTable
function YagApi.getCollectionsFromServer(propertyTable)

	-- TODO implement me!
	local collections = {}
	
	subCollectionsForFirstCollection = {}
	subCollectionsForFirstCollection[1] = {
			uid = 1,
			name = 'First album'
	}
		
	subCollectionsForFirstCollection[2] = {
			uid = 2,
			name = 'Second album'
	}
	
	subCollectionsForSecondCollection = {}
	subCollectionsForSecondCollection[1] = {
			uid = 3,
			name = 'Third album'
	}
		
	subCollectionsForSecondCollection[2] = {
			uid = 4,
			name = '4th album'
	}
	
	collections[1] = {
		uid = 1,
		name = 'First Gallery',
		subCollections = subCollectionsForFirstCollection
	}
	
	collections[2] = {
		uid = 2,
		name = 'Second Gallery',
		subCollections = subCollectionsForSecondCollection
	}

	return collections

end
