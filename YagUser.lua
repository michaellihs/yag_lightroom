--[[----------------------------------------------------------------------------

YagUser.lua
Yag user account management


TODOs:

- nsid seems to be Flickr's user id which we probably don't have in yag

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
local LrDialogs = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'
local LrTasks = import 'LrTasks'

local logger = import 'LrLogger'( 'Yag' )

require 'YagApi'

--------------------------------------------------------------------------------

YagUser = {}

--------------------------------------------------------------------------------

--- Returns username from given propertyTable
    -- @param propertyTable (table) An observable table that contains the most
		-- recent settings for your export or publish plug-in, including both
		-- settings that you have defined and Lightroom-defined export settings
local function getDisplayUserNameFromProperties( propertyTable )

	displayUserName = propertyTable.username
	return displayUserName

end

--------------------------------------------------------------------------------

--- Checks whether credentials given in propertyTable are valid
    -- @param propertyTable (table) An observable table that contains the most
		-- recent settings for your export or publish plug-in, including both
		-- settings that you have defined and Lightroom-defined export settings
local function storedCredentialsAreValid( propertyTable )

	return propertyTable.username and string.len( propertyTable.username ) > 0
			and propertyTable.auth_token

end

--------------------------------------------------------------------------------

--- Sets all settings on given propertyTable as if user was not logged in
    -- @param propertyTable (table) An observable table that contains the most
		-- recent settings for your export or publish plug-in, including both
		-- settings that you have defined and Lightroom-defined export settings
local function notLoggedIn( propertyTable )

	propertyTable.username = nil
	propertyTable.password = nil
	propertyTable.protocoll = nil
	propertyTable.domain = nil
	propertyTable.port = nil
	propertyTable.auth_token = nil

	propertyTable.accountStatus = LOC "$$$/yag/AccountStatus/NotLoggedIn=Not logged in"
	propertyTable.loginButtonTitle = LOC "$$$/yag/LoginButton/NotLoggedIn=Log In"
	propertyTable.loginButtonEnabled = true
	propertyTable.validAccount = false

end

--------------------------------------------------------------------------------

function YagUser.verifyLogin( propertyTable ) 

	-- Observe changes to prefs and update status message accordingly.

	local function updateStatus()
	
		logger:trace( "verifyLogin: updateStatus() was triggered." )
		
		LrTasks.startAsyncTask( function()
			logger:trace( "verifyLogin: updateStatus() is executing." )
			if storedCredentialsAreValid( propertyTable ) then
			     
				local displayUserName = getDisplayUserNameFromProperties( propertyTable )
				
				propertyTable.accountStatus = LOC( "$$$/yag/AccountStatus/LoggedIn=Logged in as ^1", displayUserName )
			
				if propertyTable.LR_editingExistingPublishConnection then
					propertyTable.loginButtonTitle = LOC "$$$/yag/LoginButton/LogInAgain=Log In"
					propertyTable.loginButtonEnabled = false
					propertyTable.validAccount = true
				else
					propertyTable.loginButtonTitle = LOC "$$$/yag/LoginButton/LoggedIn=Switch User?"
					propertyTable.loginButtonEnabled = true
					propertyTable.validAccount = true
				end
			else
				notLoggedIn( propertyTable )
			end
	
			YagUser.updateUserStatusTextBindings( propertyTable )
		end )
		
	end

	propertyTable:addObserver( 'auth_token', updateStatus )
	updateStatus()

end

--------------------------------------------------------------------------------

function YagUser.updateUserStatusTextBindings( propertyTable )

	local username = propertyTable.username
	
	if username and string.len( username ) > 0 then

		LrFunctionContext.postAsyncTaskWithContext( 'Yag account status check',
		function( context )
		
			context:addFailureHandler( function()

				-- Login attempt failed. Offer chance to re-establish connection.

				if propertyTable.LR_editingExistingPublishConnection then
				
					local displayUserName = getDisplayUserNameFromProperties( propertyTable )
					
					propertyTable.accountStatus = LOC( "$$$/yag/AccountStatus/LogInFailed=Log in failed, was logged in as ^1", displayUserName )

					propertyTable.loginButtonTitle = LOC "$$$/yag/LoginButton/LogInAgain=Log In"
					propertyTable.loginButtonEnabled = true
					propertyTable.validAccount = false
					
					propertyTable.accountTypeMessage = LOC "$$$/yag/AccountStatus/LoginFailed/Message=Could not verify this yag account. Please log in again. Please note that you can not change the yag account for an existing publish connection. You must log in to the same account."

				end
			
			end )		
			
		end )
	else

		propertyTable.accountTypeMessage = LOC( "$$$/yag/SignIn=Sign in with your yag account." )

	end

end

--------------------------------------------------------------------------------

local doingLogin = false

function YagUser.login( propertyTable )

	-- make sure not to start a login procedure twice
	if doingLogin then return end
	doingLogin = true

	LrFunctionContext.postAsyncTaskWithContext( 'Yag login', function( context )

		-- Clear any existing login info, but only if creating new account.
		-- If we're here on an existing connection, that's because the login
		-- token was rejected. We need to retain existing account info so we
		-- can cross-check it.

		if not propertyTable.LR_editingExistingPublishConnection then
			notLoggedIn( propertyTable )
		end

		propertyTable.accountStatus = LOC "$$$/yag/AccountStatus/LoggingIn=Logging in..."
		propertyTable.loginButtonEnabled = false
		
		LrDialogs.attachErrorDialogToFunctionContext( context )
		
		-- Make sure login is valid when done, or is marked as invalid.
		
		context:addCleanupHandler( function()

			doingLogin = false

			if not storedCredentialsAreValid( propertyTable ) then
				notLoggedIn( propertyTable )
			end

		end )
		
		-- Get current login information (if not currently logged in, dialog will be shown)
		loginInformation = YagApi.getLoginInformation()
		
		-- TODO implement actual yag login here!
		--propertyTable.auth_token = YagApi.login(loginInformation)
		loginWasSuccessfull, auth_token = YagApi.login( loginInformation )
		if loginWasSuccessfull then
			-- Login was successfull, we can write auth_token and username to prefs
			propertyTable.auth_token = auth_token
			propertyTable.username = loginInformation.username
		end
		
		YagUser.updateUserStatusTextBindings( propertyTable )
		
	end )

end

--------------------------------------------------------------------------------