--[[----------------------------------------------------------------------------

Info.lua
Summary information for yag plugin

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

return {
	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 3.0, -- minimum SDK version required by this plug-in

	LrToolkitIdentifier = 'de.yaggallery.lightroom.export.yag',
	LrPluginName = LOC "$$$/yag/PluginName",
	
	LrExportServiceProvider = {
		title = LOC "$$$/yag/yag-title=yag",
		file = 'YagExportServiceProvider.lua',
	},
	
	LrMetadataProvider = 'YagMetadataDefinition.lua',

	VERSION = { major=0, minor=1, revision=0, build=1, },
}