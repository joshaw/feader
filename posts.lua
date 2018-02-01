-- Created:  Sat 11 Nov 2017
-- Modified: Tue 30 Jan 2018
-- Author:   Josh Wainwright
-- Filename: posts.lua

local max_age = 2 * 7*24*60*60
local max_age = 5 * 24*60*60
local template_dir = 'templates'

local template_item = io.open(template_dir..'/item')
local template_page = io.open(template_dir..'/page')
local template = {
	item = template_item:read('*all'),
	page = template_page:read('*all'),
}

local function apply_template(plate, post)
	return (template[plate]:gsub('__([%w_]+)__', post))
end

local all_posts = {}
local feed_files = {...}
for i=1, #feed_files do
	local feed_file = feed_files[i]
	local feed = dofile(feed_file)
	for j=1, #feed.posts do
		local post = feed.posts[j]
		post.feed = feed.title
		all_posts[#all_posts+1] = post
	end
end

table.sort(all_posts, function(a,b) return a.secs > b.secs end)
local today = os.time()

local formatted_posts = {}
local prev_post_date = '0'
local num_items = 0
for i=1, #all_posts do
	local post = all_posts[i]

	if today - post.secs > max_age then
		break
	end

	local post_date = os.date('%A, %d %b', post.secs)
	if post_date ~= prev_post_date then
		formatted_posts[#formatted_posts+1] = '<h2 class="date">'..post_date..'</h2>'
	end
	prev_post_date = post_date

	post.date = os.date('%c', post.secs)
	post.counter = i
	formatted_posts[#formatted_posts+1] = apply_template('item', post)
	num_items = num_items + 1
end

io.stdout:write(apply_template('page', {
	items = table.concat(formatted_posts, '\n'),
	num_items = #all_posts,
	generated = os.date('%Y-%m-%d %H:%M'),
	num_items = num_items,
	num_feeds = #feed_files,
}))
