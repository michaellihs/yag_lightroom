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
local LrTasks = import 'LrTasks'
local LrFunctionContext = import 'LrFunctionContext'
local LrErrors = import 'LrErrors'
local LrApplication = import 'LrApplication'


	-- Common shortcuts
local bind = LrView.bind
local share = LrView.share
local prefs = import 'LrPrefs'.prefsForPlugin()
local logger = import 'LrLogger'( 'Yag' )

	-- yag plug-in
require 'LoggerConfig'

--------------------------------------------------------------------------------

YagSectionsForTopOfDialog = {}

--------------------------------------------------------------------------------

-- GUI elements to be added in publish service dialog --

--------------------------------------------------------------------------------

function YagSectionsForTopOfDialog.getSectionsForTopOfDialog( f, propertyTable )
	
	logger:trace('propertyTable at beginning of getSectionsForTopOfDialog')
	logger:trace(YagUtils.toString(propertyTable))
	
	-- We do some login for available accounts
	for k,v in pairs(prefs.accounts) do
		logger:trace("Accounts: ", "k: " .. k .. " v: " .. YagUtils.toString(v))
	end

	-- Configuration for additional elements of publishing service dialog
	return {

		-- Yag account settings	
		{
			title = LOC "$$$/yag/ExportDialog/Account=Yag Account",
			
			synopsis = bind {key = 'accountStatus', object = propertyTable },
	

			f:row {
				spacing = f:control_spacing(),
	
				f:static_text {
					title = LOC "$$$/yag/ExportDialog/SelectedAccount=Selected Account",
					alignment = 'right',
					fill_horizontal = 1,
				},
				
				-- Select account
				f:popup_menu {
					value = bind { key = 'selectedAccount', object = propertyTable },
					items = bind {key = 'accounts', bind_to_object = prefs, transform=function(v,t)
						local r = {}
						for k,v in pairs(prefs.accounts) do
							r[#r+1] = {title = k, value = k}
						end
						return r
					end},
					fill_horizontal = 1
				}
				
			},
			
			f:row {
			
				spacing = f:control_spacing(),
				
				f:static_text {
					fill_horizontal = 1
				},
			
				-- Login button
				f:push_button {
					title = LOC "$$$/yag/ExportDialog/Login=Login",
					enabled = bind { key = 'loginButtonEnabled', object = propertyTable },
					action = function()	login( propertyTable ) end,
					alignment = 'right',
				},
				
				-- Add account button
				f:push_button {
					title = LOC "$$$/yag/ExportDialog/AddAccount=Add Account",
					action = function() addAccount() end,
					alignment = 'right'
				},
				
				-- Edit account button
				--[[  THIS IS NOT WORKING: table is excessivly nested... DAMN!
				f:push_button {
					enabled = bind { key = 'loginButtonEnabled', object = propertyTable },
					title = LOC "$$$/yag/ExportDialog/EditAccount=Edit Account",
					action = function() editAccount(propertyTable) end,
					alignment = 'right'
				},
				]]
	
				-- Delete account button
				f:push_button {
					enabled = bind { key = 'loginButtonEnabled', object = propertyTable },
					title = LOC "$$$/yag/ExportDialog/DeleteAccount=Delete Account",
					action = function() deleteSelectedAccount(propertyTable) end,
					alignment = 'right'
				},
				
				-- Delete ALL accounts button
				f:push_button {
					enabled = bind { key = 'loginButtonEnabled', object = propertyTable },
					title = LOC "$$$/yag/ExportDialog/DeleteAccount=Delete ALL Accounts",
					action = function() deleteAllAccounts(propertyTable) end,
					alignment = 'right'
				}
	
			}
			
		},
		
		-- Yag services
		{
			
			enabled = false,		
			title = 'Yag Services',
			
			f:row {

				spacing = f:control_spacing(),
			
				f:push_button {
					title = 'Get Collections from server',
					action = function() getCollectionsFromServer(propertyTable) end,
					alignment = 'left'
				}
				
			}
			
		}
	
	}

end

--------------------------------------------------------------------------------

-- Some more dialogs concerning publish service --

--------------------------------------------------------------------------------

--- Show a login dialog for creating a new account and doing login
function YagSectionsForTopOfDialog.showLoginDialogAndLogin( accountSettings )

	return LrFunctionContext.callWithContext( 'login dialog', function( context )
		local key
		local url
		
		local f = LrView.osFactory()
		local properties = accountSettings
		
		-- We can call this method also for editing accounts
		if accountSettings == nil then
			properties = LrBinding.makePropertyTable( context )		
		end
		
		-- contents is setup for dialog to be shown for login
		local contents = f:column {
			bind_to_object = properties,
			spacing = f:control_spacing(),
			fill = 1,
		
			-- username
			f:row {
				spacing = f:label_spacing(),
				f:static_text {
					title = LOC "$$$/yag/LoginDialog/Username=Username",
					alignment = 'lright',
					width = share 'title_width'
				},
				f:edit_field { 
					fill_horizonal = 1,
					width_in_chars = 35, 
					value = bind 'username'
				}
			},
		  
		    -- password
			f:row {
				spacing = f:label_spacing(),
				f:static_text {
					title = LOC "$$$/yag/LoginDialog/Password=Password",
					alignment = 'lright',
					width = share 'title_width'
				},
				f:password_field { 
					fill_horizonal = 1,
					width_in_chars = 35, 
					value = bind 'password'
				}
			},
		  
		    -- url
			f:row {
				spacing = f:label_spacing(),
				f:static_text {
					title = LOC "$$$/yag/LoginDialog/Url=Url",
					alignment = 'lright',
					width = share 'title_width',
				},
				f:edit_field { 
					fill_horizonal = 1,
					width_in_chars = 35, 
					value = bind 'url'
				}
			}
		}
		
		
		while true do
			local result = LrDialogs.presentModalDialog {
				title = "Login", 
				contents = contents,
			}
			
			if result == 'ok' then
				--strip trailing slash off url
				if string.sub(properties.url, #properties.url) == "/" then
					properties.url = string.sub(properties.url, 1, #properties.url-1)
				end
				
				local loginInformation = {}
				loginInformation.username = properties.username
				loginInformation.url = properties.url
				loginInformation.password = properties.password
				
				--attempt to login
				local success = YagApi.login( loginInformation )
				-- TODO add some more detailed error message here!
				-- TODO add translation!
				if not success then LrDialogs.message("Error", "Login was not successfull. Make sure your settings are correct!")
				else
					return loginInformation
				end
			else
				LrErrors.throwCanceled()	
			end
		end
	end)
	
end

--------------------------------------------------------------------------------

-- Methods implementing the actions of dialog buttons

-------------------------------------------------------------------------------

--- Called, if an account should be deleted
 -- Shows confirmation dialog for deleting account
function deleteSelectedAccount(propertyTable)

	local reallyDelete = LrDialogs.confirm( 
		LOC "$$$/yag/ExportDialog/Confirm=Confirm", 
		LOC "$$$/yag/ExportDialog/DeleteConfirmMessage=Are you sure you want to delete account: " .. propertyTable.selectedAccount .. "?", 
		LOC "$$$/yag/ExportDialog/Yes=Yes", 
		LOC "$$$/yag/ExportDialog/Cancel=Cancel"
	)
	
	if reallyDelete == 'ok' then
		prefs.accounts[propertyTable.selectedAccount] = nil
	
		-- We have to unset selected account as this is the only account that can be selected
		propertyTable.selectedAccount = nil
	
		LrDialogs.message(LOC "$$$/yag/ExportDialog/AccountDeleted=Account Deleted!")
	
		--force the observable tables to propagate the changes
		prefs.accounts = prefs.accounts
		propertyTable.selectedAccount = propertyTable.selectedAccount
	end
	
end

--------------------------------------------------------------------------------

--- Deletes ALL accounts from prefs
function deleteAllAccounts(propertyTable)
	local reallyDelete = LrDialogs.confirm( 
		LOC "$$$/yag/ExportDialog/Confirm=Confirm", 
		LOC "$$$/yag/ExportDialog/DeleteAllConfirmMessage=Are you sure you want to delete ALL accounts?", 
		LOC "$$$/yag/ExportDialog/Yes=Yes", 
		LOC "$$$/yag/ExportDialog/Cancel=Cancel"
	)
	
	if reallyDelete then
		prefs.accounts = {}
		propertyTable.selectedAccount = nil
		propertyTable.auth_token = nil
		
		LrDialogs.message(LOC "$$$/yag/ExportDialog/AccountsDeleted=Accounts Deleted!")
		
		--force the observable tables to propagate the changes
		prefs.accounts = prefs.accounts
		propertyTable.selectedAccount = propertyTable.selectedAccount
	end
end

--------------------------------------------------------------------------------

--- Called, if a new account should be created
 -- Shows dialog for entering information about new account
function addAccount()

	LrTasks.startAsyncTask( function()
		local loginInformation = YagSectionsForTopOfDialog.showLoginDialogAndLogin()
		--handle cancel
		if not loginInformation.username then 
			return
		end
		
		-- We generate a key for account
		local k = loginInformation.url.." - "..loginInformation.username
		
		-- We store account with generated key in prefs table
		prefs.accounts[k] = loginInformation
		
		--force the observable table to propagate the change
		prefs.accounts = prefs.accounts
		
		LrDialogs.message("Account added.")
	end)
	
end

--------------------------------------------------------------------------------

--- Called if an account should be edited
 -- Shows dialog for editing account information
function editAccount( propertyTable )

	LrTasks.startAsyncTask( function()
		local accountSettings = prefs.accounts[propertyTable.selectedAccount]

		local loginInformation = YagSectionsForTopOfDialog.showLoginDialogAndLogin( accountSettings )
	
		if not loginInformation.username then 
			return
		end
	
		local k = loginInformation.url.." - "..loginInformation.username
		logger:trace('Changed account information')
		logger:trace('k: ' .. YagUtils.toString(k))
		logger:trace('loginInformation: ' .. YagUtils.toString(loginInformation))
		prefs.accounts[k] = nil
		prefs.accounts[k] = loginInformation
		
		--force the observable table to propagate the change
		prefs.accounts = prefs.accounts
		
		LrDialogs.message("Account changed.")
	end)
	
end

--------------------------------------------------------------------------------

--- Action that is triggered, if 'login' button is pushed
function login( propertyTable ) 

	-- TODO implement me!
	-- We should do a login, get a session key and store it to prefs / propertyTable
	--LrDialogs.message("Doing Login!", YagUtils.toString(propertyTable.selectedAccount))
	local loginSuccess, auth_token = YagApi.login(prefs.accounts[propertyTable.selectedAccount])
	if loginSuccess then
		propertyTable.auth_token = auth_token
		LrDialogs.message("Login did succeed! auth_token: " .. auth_token)
	else
		LrDialogs.message("Login did not succeed!")
		propertyTable.auth_token = nil
	end
	
	-- Publish changes to auth_token
	propertyTable.auth_token = propertyTable.auth_token
	
end

--------------------------------------------------------------------------------

function getCollectionsFromServer(propertyTable) 

	LrTasks.startAsyncTask( function()
		collections = YagApi.getCollectionsFromServer(propertyTable)
	
		local activeCatalog = LrApplication.activeCatalog()
		local publishServices = activeCatalog:getPublishServices('de.yaggallery.lightroom.export.yag')
		local currentPublishService = nil
		
		for k,v in ipairs(publishServices) do
			logger:trace('Publish service key: ' .. k .. ' value ' .. YagUtils.toString(v))
			logger:trace('Publish service plugin id: ' .. v:getPluginId())
			logger:trace('Publish service name: ' .. v:getName())
			if v:getName() == propertyTable.LR_publish_connectionName then
				currentPublishService = v
			end
		end
		
		if currentPublishService then
			logger:trace('We have a current publish service')
		else
			LrDialogs.message('We do not have a current publish service!')
			return
		end
	
		-- We add each collection as publish collection for this publish service
		activeCatalog:withWriteAccessDo( 'Inserting galleries and albums to publish service', function( context )
			for galleryNumber, gallery in ipairs(collections) do
				-- We create a collection set for each gallery
				local galleryCollectionSet = currentPublishService:createPublishedCollectionSet('[' .. gallery.uid .. '] '.. gallery.name, nil, true)
				
				-- We set some additional settings for this gallery
				gallerySettings = {}
				gallerySettings.galleryUid = gallery.uid
				gallerySettings.galleryName = gallery.name
				galleryCollectionSet:setCollectionSetSettings(gallerySettings)
				galleryCollectionSet:setRemoteId(gallery.uid)			
				
				if gallery.subCollections then
					for albumNumber, album in ipairs(gallery.subCollections) do
						-- We create a collection for each album
						local albumCollection = currentPublishService:createPublishedCollection('[' .. album.uid .. '] '.. album.name, galleryCollectionSet, true)
						
						-- We set some additional settings for this album
						albumSettings = {}
						albumSettings.albumUid = album.uid
						albumSettings.albumName = album.name
						albumSettings.galleryUid = gallery.uid
						albumSettings.galleryName = gallery.name
						logger:trace('Collection settings: ' .. YagUtils.toString(albumSettings))
						albumCollection:setCollectionSettings(albumSettings)
						albumCollection:setRemoteId(album.uid)
					
					end
				end
			end	
		end) -- end write access
		
	end) -- end async task

end

