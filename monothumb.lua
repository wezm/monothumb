-- require('imlib2')
http = require ("socket.http")
url = require("socket.url")
ltn12 = require("ltn12")
require("lxp")


--local debug = false
local api_url = "http://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=aa003631cc50bd47f27f242d30bcd22f&user_id=40215689%40N00&per_page=20&extras=url_sq,url_m"

rsp, status, auth = http.request(api_url)

--[[
if debug then
  status = 200
  local sample_response, err = io.open("sample_response.xml")
  if(sample_response == nil) then
    print("Unable to open sample response file: " .. err)
    return
  end

  rsp = sample_response:read("*a") -- Read the whole file
  sample_response:close()
end
]]

if (status ~= 200) then
  print("Unable to retrieve photo XML from Flickr: " .. status)
  os.exit(1)
end

-- Parse the response
-- Check the stat attribute of the root element is "ok"
-- look for //photos/photo elements
-- Extract the interesting information into a photo structure and download the small image and add that to a list
-- Loop over the list rendering and processing them into the target image

local callbacks
local photos = {}

local function photo_handler(parser, name, attributes)
  if (name == "photo") then
    table.insert(photos, attributes) -- XXX: Might need to dup the attrs if they're reused
    local u = url.parse(attributes.url_sq)
    -- http://farm5.static.flickr.com/4044/4702281342_610ce0b485_s.jpg
    filename = string.match(u.path, "/([^/]+)$")
    print(attributes.url_sq .. " => " .. filename)
    -- TODO: add more error checking to this whole arrangement
    local status = http.request{
      url = attributes.url_sq,
      sink = ltn12.sink.file(io.open("output/" .. filename, "w"))
    }
  else
    print("Expecting photo, got: " .. name)
    parser:close()
  end
end

local function photos_handler(parser, name, attributes)
  if (name == "photos") then
    callbacks.StartElement = photo_handler
  else
    print("Expecting photos, got: " .. name)
    parser:close()
  end
end

local function err_handler(parser, name, attributes)
  print("Response failed: " .. attributes.msg .. " (" .. attributes[code] .. ")")
  parser:close()
end

local function rsp_handler(parser, name, attributes)
  if (name == "rsp") then
    -- Ensure the status is ok
    local stat = attributes.stat
    if stat == "ok" then
      callbacks.StartElement = photos_handler
    elseif (stat == "fail") then
      callbacks.StartElement = err_handler
    else
      print("Response is not ok: " .. stat)
      parser:close()
    end
  end
end

--local function end_element_handler(parser, name)
--end

callbacks = {
  StartElement = rsp_handler
}

local expat = lxp.new(callbacks)
expat:parse(rsp)
expat:parse() -- closes the document
expat:close()

