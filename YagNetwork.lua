--[[----------------------------------------------------------------------------

YagNetwork.lua
Handles all network traffic with yag service

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

local LrHttp = import "LrHttp"


local YagNetwork = {}

--------------------------------------------------------------------------------

----------------
-- Public API --
----------------


function LrHttp.get( propertyTable, parameterTable ) 
	body, headers = LrHttp.get(YagNetwork.urlBuilder( propertyTable, parameterTable))
	return body, headers
end

--------------------------------------------------------------------------------

--------------------
-- Helper methods --
--------------------


local function LrHttp.urlBuilder( propertyTable, parameterTabel ) 
	url = ''
	
	url = 'http://pt_list_dev.centos.localhost/?eID=yagRemoteDispatcher&extensionName=YagRemote&pluginName=ajax&controllerName=Authentication&actionName=ping&pageUid=42'
	
	return url
end

--------------------------------------------------------------------------------

return YagNetwork