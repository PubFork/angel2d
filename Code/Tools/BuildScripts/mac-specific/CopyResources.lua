------------------------------------------------------------------------------
-- Copyright (C) 2008-2012, Shane Liesegang
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without 
-- modification, are permitted provided that the following conditions are met:
-- 
--     * Redistributions of source code must retain the above copyright 
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright 
--       notice, this list of conditions and the following disclaimer in the 
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of the copyright holder nor the names of any 
--       contributors may be used to endorse or promote products derived from 
--       this software without specific prior written permission.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
-- POSSIBILITY OF SUCH DAMAGE.
------------------------------------------------------------------------------

if (package.path == nil) then
  package.path = ""
end
local mydir = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]]
if (mydir == nil) then
  mydir = "."
end
mydir = mydir .. "/../"
package.path = mydir .. "?.lua;" .. package.path
package.path = package.path .. ";" .. mydir .. "lua-lib/penlight-0.8/lua/?/init.lua"
package.path = package.path .. ";" .. mydir .. "lua-lib/penlight-0.8/lua/?.lua"

require "angel_build"
require "lfs"
require "pl.path"

local env = os.environ()

lfs.chdir(fulljoin(env['PROJECT_DIR'], '..', 'Angel', 'Scripting', 'EngineScripts'):gsub('"', ''))

function building_for_iphone()
  if ((env['PLATFORM_NAME'] == "iphonesimulator") or (env['PLATFORM_NAME'] == "iphoneos")) then
    return true
  else
    return false
  end
end

local dest = ""
if (building_for_iphone()) then
  dest = fulljoin(
      env['TARGET_BUILD_DIR'],
      env['EXECUTABLE_NAME'] .. '.app',
      'Angel',
      'Resources',
      'Scripts'
    )
elseif (env['CONFIGURATION'] == 'Debug') then
  dest = fulljoin(
      env['PROJECT_DIR'],
      'Resources',
      'Scripts'
    )
else
  dest = fulljoin(
      env['BUILT_PRODUCTS_DIR'],
      env['EXECUTABLE_NAME'] .. '.app',
      'Contents',
      'Resources',
      'Scripts'
    )
end

if (not pl.path.exists(dest:gsub('"', ''))) then
  makedirs(dest:gsub('"', ''))
end

for _, filename in pairs(pl.dir.getfiles(lfs.currentdir(), ".lua")) do
  if (not _isdotfile(filename)) then
    local dstname = fulljoin(dest, pl.path.basename(filename))
    pl.dir.copyfile(filename, dstname:gsub('"', ''))
  end
end

if (env['CONFIGURATION'] == 'Debug' and building_for_iphone() == false) then
  os.exit(0)
end

local source = fulljoin(env['PROJECT_DIR'], 'Resources')
if (building_for_iphone()) then
  dest = fulljoin(
      env['TARGET_BUILD_DIR'],
      env['EXECUTABLE_NAME'] .. '.app',
      'Angel',
      'Resources'
    )
else
  dest = fulljoin(
    env['BUILT_PRODUCTS_DIR'],
    env['EXECUTABLE_NAME'] .. '.app',
    'Contents',
    'Resources'
  )
end
recursive_copy(source, dest)

source = fulljoin(env['PROJECT_DIR'], 'Config')
if (building_for_iphone()) then
  dest = fulljoin(
      env['TARGET_BUILD_DIR'],
      env['EXECUTABLE_NAME'] .. '.app',
      'Angel',
      'Config'
    )
else
  dest = fulljoin(
    env['BUILT_PRODUCTS_DIR'],
    env['EXECUTABLE_NAME'] .. '.app',
    'Contents',
    'Config'
  )
end
recursive_copy(source, dest)

if (building_for_iphone() == false) then
  local log_path = fulljoin(
      env['BUILT_PRODUCTS_DIR'],
      env['EXECUTABLE_NAME'] .. '.app',
      'Contents',
      'Logs'
    )
  if not pl.path.exists(log_path) then
      makedirs(log_path)
  end
end