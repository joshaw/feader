date
cd $(dirname $0)

FEADER_NO_FETCH=${FEADER_NO_FETCH:-}
FEADER_MAX_AGE_DAYS=${FEADER_MAX_AGE_DAYS:-7}
if [ -z "$FEADER_NO_FETCH" ]; then
	echo "Removing old data"
	rm -rf feeds/feed-*
	mkdir -p feeds

	echo "Getting new data"
	grep -vE '^#|^$' config | xargs -P 20 -n 1 python feeds.py
	#grep -vE '^#|^$' config | xargs -P 20 -n 1 -I {} sh -c "curl -s {} | lua feeds.lua"
fi

echo "Generating page"
lua posts.lua output.html all_posts.html feeds/feed-*

OUTPUTDIR=/home/josh/www/feader
cp output.html ${OUTPUTDIR}/index.html
cp all_posts.html ${OUTPUTDIR}/all_posts.html
