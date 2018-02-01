-- Created:  Mon 13 Nov 2017
-- Modified: Mon 13 Nov 2017
-- Author:   Josh Wainwright
-- Filename: feeds.lua

local feedparser = require("feedparser")

local function ByteCRC(sum, data)
	sum = sum ~ data
	for i = 0, 7 do
		if ((sum & 1) == 0) then
			sum = sum >> 1
		else
			sum = (sum >> 1) ~ 0xA001
		end
	end
	return sum
end

local function CRC(data)
	sum = 65535
	local d
	for i = 1, #data do
		d = string.byte(data, i)
		sum = ByteCRC(sum, d)
	end
	return ('%x'):format(sum)
end

local xml_string = io.stdin:read('*all')
if not xml_string or #xml_string == 0 then
	error('No xml to parse')
end
local slug = CRC(xml_string)
local d = feedparser.parse(xml_string)

local s = {}
s[#s+1] = 'return {'
s[#s+1] = ('  title=[==[%s]==],'):format(d.feed.title)
s[#s+1] = ('  link="%s",'):format(d.feed.link)
s[#s+1] = '  posts={'

for i=1, #d.entries do
	local post = d.entries[i]
	s[#s+1] = '    {'

	local secs
	if post.published_parsed then
		secs = post.published_parsed
	elseif post.updated_parsed then
		secs = post.updated_parsed
	end

	assert(secs, 'Missing date')

	s[#s+1] = ('      secs=%s,'):format(secs)
	s[#s+1] = ('      title=[==[%s]==],'):format(post.title)
	s[#s+1] = ('      url=[==[%s]==],'):format(post.link)
	s[#s+1] = ('      hash="%s",'):format(CRC(post.summary))
	s[#s+1] = ('      description=[==[%s]==],'):format(post.summary)
	s[#s+1] = '    },'
end

s[#s+1] = '  }'
s[#s+1] = '}'

local f = io.open('feeds/feed-'..slug, 'w')
f:write(table.concat(s, '\n'))
print('', slug, d.feed.title)

