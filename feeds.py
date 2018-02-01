# Created:  Sat 11 Nov 2017
# Modified: Tue 30 Jan 2018
# Author:   Josh Wainwright
# Filename: feeds.py

import sys
import time
import hashlib
import feedparser

def getslug(s):
	return hashlib.sha1(s.encode('utf-8')).hexdigest()[:8]
	#return hex(sum([ord(c) for c in list(s)]))[2:]

feed_url = sys.argv[1]
slug = getslug(feed_url)
d = feedparser.parse(feed_url)
sys.stdout.write(slug + '\t' + d.feed.title + '\t' + feed_url + '\n')

lines = []
lines.append('return {')
lines.append('  title=[==[{}]==],'.format(d.feed.title))
lines.append('  link="{}",'.format(d.feed.link))
lines.append('  posts={')

for post in d.entries:
	lines.append('    {')

	date = None
	if 'published_parsed' in post:
		date = post.published_parsed
	elif 'updated_parsed' in post:
		date = post.updated_parsed
	elif 'created_parsed' in post:
		date = post.created_parsed

	if date:
		secs = int(time.mktime(date))

	lines.append('      secs={},'.format(secs))
	lines.append('      title=[==[{}]==],'.format(post.title))
	lines.append('      url=[==[{}]==],'.format(post.link))
	lines.append('      hash="{}",'.format(getslug(post.link)))
	lines.append('      description=[==[{}]==],'.format(post.summary))
	lines.append('    },')

lines.append('  }')
lines.append('}')

f = open('feeds/feed-'+slug, 'w')
f.write('\n'.join(lines))
