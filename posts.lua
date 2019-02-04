-- Created:  Sat 11 Nov 2017
-- Modified: Tue 07 Aug 2018
-- Author:   Josh Wainwright
-- Filename: posts.lua
local template_dir = 'templates'

local template_item = io.open(template_dir..'/item')
local template_page = io.open(template_dir..'/page')
local template_all_item = io.open(template_dir..'/allitem')
local template_all_page = io.open(template_dir..'/allpage')
local template = {
	item = template_item:read('*all'),
	page = template_page:read('*all'),
	allitem = template_all_item:read('*all'),
	allpage = template_all_page:read('*all'),
}
template_item:close()
template_page:close()
template_all_item:close()
template_all_page:close()

local extractors_mapping = dofile('extractors/mapping.dl')

local function apply_template(plate, post)
	return (template[plate]:gsub('__([%w_]+)__', post))
end

local max_age = 7 * 24 * 60 * 60
local max_age_env = tonumber(os.getenv('FEADER_MAX_AGE_DAYS'))
if max_age_env then
	max_age = max_age_env * 24 * 60 * 60
end
io.write('Max age: ', max_age/(24*60*60), ' days\n')

local all_posts = {}
local feed_files = {...}
for i=1, #feed_files do
	local feed_file = feed_files[i]
	if feed_file:match('^feeds/feed-') then
		local feed = dofile(feed_file)
		for j=1, #feed.posts do
			local post = feed.posts[j]
			post.feed = feed.title
			all_posts[#all_posts+1] = post
		end
	end
end

table.sort(all_posts, function(a,b) return a.secs > b.secs end)
local today = os.time()

local formatted_posts = {}
local all_page = {}
local prev_post_date = '0'
local num_items = 0
for i=1, #all_posts do
	local post = all_posts[i]
	post.date = os.date('%Y-%m-%d', post.secs)
	post.counter = i

	all_page[#all_page+1] = apply_template('allitem', post)

	if today - post.secs < max_age then
		local post_date = os.date('%A, %d %b', post.secs)
		if post_date ~= prev_post_date then
			formatted_posts[#formatted_posts+1] = '<h2 class="date">'..post_date..'</h2>'
		end
		prev_post_date = post_date

		io.write('[ Including ] ', post.url, '\n')
		for pattern, extractor in pairs(extractors_mapping) do
			if post.url:match(pattern) then
				io.write('[ Extracting ] ', post.url, '\n')
				extractor(post)
			end
		end

		formatted_posts[#formatted_posts+1] = apply_template('item', post)
		num_items = num_items + 1
	end
end

local output_fname = arg[1]
local allposts_fname = arg[2]

local output_f = io.open(output_fname, 'w')
output_f:write(apply_template('page', {
	items = table.concat(formatted_posts, '\n'),
	num_items = #all_posts,
	generated = os.date('%Y-%m-%d %H:%M'),
	num_items = num_items,
	num_feeds = #feed_files,
}))
output_f:close()

local allposts_f = io.open(allposts_fname, 'w')
allposts_f:write(apply_template('allpage', {
	items = table.concat(all_page),
	num_items = #all_page
}))
allposts_f:close()
