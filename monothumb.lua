-- require('imlib2')
http = require ("socket.http")
url = require("socket.url")
ltn12 = require("ltn12")
require("lxp")
require("imlib2")

local api_url = "http://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=aa003631cc50bd47f27f242d30bcd22f&user_id=40215689%40N00&per_page=20&extras=url_sq,url_m"

rsp, status, auth = http.request(api_url)

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

local function desaturate_image(image)
  local width = image:get_width()
  local height = image:get_height()
  local result = imlib2.image.new(width, height)
  result:set_has_alpha(image:has_alpha())
  result:set_format(image:get_format())

  for x=0, width-1 do
    for y=0, height-1 do
      local pix = image:get_pixel(x, y)
      -- Link
      local luminance = 0.2126 * pix.red + 0.7152 * pix.green + 0.0722 * pix.blue
      if (luminance - math.floor(luminance) >= 0.5) then
        luminance = math.ceil(luminance)
      else
        luminance = math.floor(luminance)
      end

      local monopix = imlib2.color.new(luminance, luminance, luminance, pix.alpha)
      result:draw_pixel(x, y, monopix)
    end
  end

  return result
end

local function photo_handler(parser, name, attributes)
  if (name == "photo") then
    local u = url.parse(attributes.url_sq)
    -- http://farm5.static.flickr.com/4044/4702281342_610ce0b485_s.jpg
    filename = string.match(u.path, "/([^/]+)$")
    --print(attributes.url_sq .. " => " .. filename)
    -- TODO: add more error checking to this whole arrangement
    -- TODO: Add caching or content negotiation to the requests, find out how to serialise lua tables, syck?
    local filepath = "output/" .. filename
    local status = http.request{
      url = attributes.url_sq,
      sink = ltn12.sink.file(io.open(filepath, "w"))
    }
    attributes['filepath'] = filepath
    table.insert(photos, attributes)
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

-- Create the output image
local pixel_width = 75 * 20;
local pixel_height = 75 * 2;

output = imlib2.image.new(pixel_width, pixel_height)
output:set_has_alpha(false)
output:set_format("jpg")
output:set_quality(90)

-- Now process the images
for idx, attrs in ipairs(photos) do
  local photo = imlib2.image.load(attrs['filepath'])

  if (photo) then
    -- Draw the color version
    output:blend_image(photo, false, 0, 0, 75, 75, (idx - 1) * 75, 0, 75, 75)

    -- and the monochrome version
    local monochrome = desaturate_image(photo)
    output:blend_image(monochrome, false, 0, 0, 75, 75, (idx - 1) * 75, 75, 75, 75)
  else
    print("Unable to load " .. attrs['filepath'])
  end
end

-- save the result
output:save("sprite.jpg")

