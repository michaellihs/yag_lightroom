--[[----------------------------------------------------------------------------

LoggerConfig.lua
Configuration for Lightroom logger for logging yag plugin

use

require 'LoggerConfig'

to establish logger with this configuration in your script.

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

local LrLogger = import "LrLogger"
local log = LrLogger( 'Yag' )

-- Log files will be written to a file:
-- 	On Mac: 

log:enable( { 
	['debug'] = 'logfile',
	['trace'] = 'logfile',
	['info'] = 'logfile',
	['warn'] = 'logfile',
	['error'] = 'logfile',
	['fatal'] = 'logfile'
} )

--log:disable()