printf "[%s] %s\n" "feader" "$(date)" >&2
cd $(dirname $0)

if [ -z "$FEADER_NO_FETCH" ]; then
	echo "Removing old data"
	#rm -rf feeds/feed-*
	mkdir -p feeds

	echo "Getting new data"
	grep -vE '^#|^$' config | xargs -P 20 -n 1 python feeds.py
	#grep -vE '^#|^$' config | xargs -P 20 -n 1 -I {} sh -c "curl -s {} | lua feeds.lua"
	#grep -vE '^#|^$' config | while read line; do
	#	printf '%s' "$line"
	#	python feeds.py "$line"
	#done
fi

echo "Generating page"
lua posts.lua feeds/feed-* > output.html

cp output.html /mnt/www/feader.html
