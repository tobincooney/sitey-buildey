#!/bin/bash

head=$( cat head.htm )
foot=$( cat foot.htm | sed "s/{BUILDDATE}/$( date )/" )

function backlink {
	backlinks="<br><hr /><h3>Backlinks:</h3><ul>"
	for n in $( ls -tr src/*.htm ); do
		cat $n | grep -q "<a href=\"$1\""
		if test $? -eq 0; then
			back_name=$( echo "$n" | sed 's/src\///' | sed 's/\.htm//' )
			echo -n " ."
			backlinks+="<li><a href='$back_name.html'>$back_name</a></li>"
		fi
	done; echo ""
	backlinks+="</ul>"
}

function pages {
	echo ""; echo "(PAGES)"
	for i in $( ls -t src/*.htm ); do
		name=$( echo "$i" | sed 's/src\///' | sed 's/\.htm//' )
		echo -n "$name"
		#main=$( cat $i )
		#easter egg
		main=$( cat $i | sed 's/\&mdash;/<span onclick=\"startegg();\">\&mdash;<\/span>/g' )
		backlink $name.html
		page="$head$main$backlinks$foot"
		echo "$page" > site/$name.html
	done
}

function meta {
	echo ""; echo "(META)"
	for i in $( ls -t src/meta/*.htm ); do
		name=$( echo "$i" | sed 's/src\/meta\///' | sed 's/\.htm//' )
		echo -n "$name"
		main="$( cat $i )$( eval $name )"
		# (the content of the page will be the content of src/meta/name.htm followed by the output of the 'name' function)
		backlink $name.html
		page="$head$main$backlinks$foot"
		echo "$page" > site/$name.html
	done
}

function index {
	echo "<b>Meta pages:</b>"
	echo "<ul>"
	for i in $( ls src/meta/*.htm ); do
		item_name=$( echo "$i" | sed 's/src\/meta\///' | sed 's/\.htm//' )
		echo "<li><a href='$item_name.html'>$item_name</a></li>"
	done
	echo "</ul>"

	echo "<b>Regular pages:</b>"
	echo "<ul>"
	for i in $( ls src/*.htm ); do
		item_name=$( echo "$i" | sed 's/src\///' | sed 's/\.htm//' )
		echo "<li><a href='$item_name.html'>$item_name</a></li>"
	done
	echo "</ul>"
}

function search {
	echo "		<script type='text/javascript' src='search.js'></script>
		<script type='text/javascript' src='search-pages.js'></script>
		<br>
		<form onsubmit='return false;'><input id='searchbar' autofocus />
		<button onclick='searchGo();'>Go</button></form>
		<h2>RESULTS</h2>
		<div id='results'><ol id='log'></ol></div>"
	cd site; ln -sf ../src/search.js search.js; cd ..
	echo "var pages = [" > site/search-pages.js
	for i in $( ls -t src/*.htm ); do
		name=$( echo "$i" | sed 's/src\///' | sed 's/\.htm//' )
		echo "	['$name.html', '$name', \`$( cat $i )\`]," >> site/search-pages.js
	done
	echo "	['', '', '']]" >> site/search-pages.js
}

function updates {
	echo "<ul>"
	updates_full=""
	echo "<?xml version='1.0' encoding='UTF-8' ?>
<rss version='2.0'>
<channel>
<title>Tobin Cooney: Site Updates</title>
<link>https://tobincooney.com/garden/</link>
<description>tobincooney.com website changelog</description>
<lastBuildDate>$( date +%a,\ %d\ %b\ %Y\ %H:%M:%S\ %Z )</lastBuildDate>" > site/rss.xml
	for i in $( ls -r src/updates/*.htm ); do
		name=$( echo "$i" | sed 's/src\/updates\///' | sed 's/\.htm//' )
		prettyname=$( head -1 $i | sed 's/<h2>//' | sed 's/<\/h2>//' )
		echo "<li><small>$name</small> <a href='#$name'>$prettyname</a></li>"
		updates_full+="<br><hr /><br><a id='$name'></a>"
		#updates_full+="$( cat $i )"
		#easter egg
		updates_full+="$( cat $i | sed 's/\&mdash;/<span onclick=\"startegg();\">\&mdash;<\/span>/g' )"
		echo "<item>
  <title>$prettyname</title>
  <link>https://tobincooney.com/garden/site/updates.html#$name</link>
  <pubDate>$( head -2 $i | tail -1 | sed 's/<code>//' | sed 's/<\/code>//' )</pubDate>
  <description>
<![CDATA[$( tail -n +3 $i )]]>
  </description>
</item>" >> site/rss.xml
	done
	echo "</ul>"
	echo "$updates_full"
	echo "</channel></rss>" >> site/rss.xml
}

function uncreated {
	echo "<ul>"
	for i in $( ls -t src/meta/*.htm src/*.htm ); do
		cat $i | grep -q "<<"
		if test $? -eq 0; then
			echo "	<li><b>in <code><a href=\"../$i\">$i</a></code>:</b><ul>
		<li>$( cat $i | grep "<<" | sed 's/<< /<b style="background-color:red; color:white;"><< /g' | sed 's/ >>/ >><\/b>/g' )</li></ul></li>"
		fi
	done
	echo "</ul>"
}

function media {
	echo "<ul>"
	for i in $( ls -t media/ ); do
		echo "<li><a href=\"../media/$i\">$i</a></li>"
	done
	echo "</ul>"
}

echo -n "[$( date )]" >> site/builds.txt
if [ -z "$1" ]; then
	echo "FULL BUILD"
	echo " - FULL BUILD" >> site/builds.txt
	rm -r site/*.html
	pages
	meta
else
	for a in "$@"; do
		if [[ "$a" =~ .*"src/".* ]]; then
			echo -n "INDIVIDUAL PAGE BUILD: $a"
			echo " - INDIVIDUAL PAGE BUILD: $a" >> site/builds.txt
			name=$( echo "$a" | sed 's/src\///' | sed 's/\.htm//' )
			#main=$( cat $a )
			#easter egg
			main=$( cat $a | sed 's/\&mdash;/<span onclick=\"startegg();\">\&mdash;<\/span>/g' )
			backlink $name.html
			page="$head$main$backlinks$foot"
			echo "$page" > site/$name.html
		else
			echo -n "SUBSYSTEM BUILD: $a"
			echo " - SUBSYSTEM BUILD: $a" >> site/builds.txt
			main="$( cat src/meta/$a.htm )$( eval $a )"
			backlink $a.html
			page="$head$main$backlinks$foot"
			echo "$page" > site/$a.html
		fi
	done
fi
