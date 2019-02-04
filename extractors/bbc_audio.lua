local function file_exists(name)
	local f = io.open(name, "r")
	if f == nil then
		return false
	else
		io.close(f)
		return true
	end
end

local function capture(cmd)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	return s
end

return function(post)
	local opts = '-f "bestaudio"'

	local filename_cmd = ('youtube-dl %s --restrict-filenames --get-filename "%s"'):format(opts, post.url)
	local filename = capture(filename_cmd)
	filename = string.gsub(filename, '^%s+', '')
	filename = string.gsub(filename, '%s+$', '')
	filename = string.gsub(filename, '[\n\r]+', ' ')

	local full_path = ('/mnt/isen/feader/%s'):format(filename)
	local download_cmd = ('youtube-dl %s -o "%s" "%s" 1>&2'):format(opts, full_path, post.url)

	io.stderr:write('[ Downloading ] ', download_cmd, '\n')
	if not file_exists(full_path) and not os.getenv('FEADER_NO_FETCH') then
		os.execute(download_cmd)
	end

	post.description = ([[
<video controls
	src="feader/%s"
	preload="metadata"
	width="560">
		Video playback not supported
</video>
<p><a href="feader/%s">Download</a></p>
<p>Original video: <a href="%s">BBC</a></p>
]]):format(filename, filename, post.url)

	--io.stderr:write('Deleting files older than 7 days\n')
	--local delete_cmd = 'find /mnt/isen/feader -mtime +7'
	--os.execute(delete_cmd)
end
