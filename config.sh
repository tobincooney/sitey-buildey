#!/bin/bash

#motd=`cat NOTES`

date=`date`

function head_to_toc_build {
	head_to_toc="<!DOCTYPE html>
<html>
	<head>
		<link rel='icon' type='image/png' href='../media/icon.ico' />
		<link rel='stylesheet' type='text/css' href='style.css' />
		<title>$1</title>
	</head>
	<body id='top'>
		<pre>$motd</pre>
		<table>
			<tr>
				<th id='left'></th>
				<th id='right'></th>
			</tr>
			<tr>
				<td valign='top' class='menu'>
					<h2><a style='text-decoration:none; color:black;' href='home.html'>site title</a></h2><br>
					<details open>
						<summary><b>contents</b></summary>
						<ul class='menu'>
							<li><a href='home.html'>Home</a></li>
							<li><a href='updates.html'>Updates</a></li>
							<li><a href='index.html'>Index</a></li>
						</ul>
						<h3>Auto-generated</h3>
						<ul class='menu'>

							<!-- begin table of contents dump -->

"
	echo "$head_to_toc"
}

toc_to_main="

							<!-- end table of contents dump -->

						</ul>
					</details><br>
				</td>
				<td valign='top' class='main'>

					<!-- begin main content dump -->

"

main_to_end="

					<!-- end main content dump -->

				</td>
			</tr>
			<tr><td></td>
				<td>
					<br><hr><br>
					<p>Last updated $date</p>
					<p>[[&copy; Copyright goes here]]</p>
				</td>
			</tr>
		</table>
	</body>
</html>
"

# convert md file input to html string
function htmlify {
	yield=`cat source/$1 | sed 's/^/<p>/g' | sed 's#$#</p>#g'`
	yield=`echo "$yield" | \
		sed '/<p></s/<\/p>//' | \
		sed 's#<p><#<#' | \
		sed '/<p># /s/$/ ::<\/h1><\/center>/' | \
		sed '/<p># /s/<\/p>//g' | \
		sed 's/<p># /<center><h1>:: /' | \
		sed '/<p>## /s/$/ -<\/h2><\/center>/' | \
		sed '/<p>## /s/<\/p>//g' | \
		sed 's/<p>## /<center><h2>- /'`
	yield=`echo "$yield" | sed -E 's/(^|[^\\\*])\*([^\*]+)\*([^\*]|$)/\1<i>\2<\/i>\3/g'`
	yield=`echo "$yield" | sed -E 's/(^|[^\\\*])\*{2}([^\*]+)\*{2}([^\*]|$)/\1<b>\2<\/b>\3/g'`
	echo "$yield"
}

function backlink {
	l="0"
	for b in $( ls -tr source/*.md source/*.html )
	do
		pretty=`head -1 $b | sed 's/# //' | sed 's/<center><h1>:: //' | sed 's/ ::<\/h1><\/center>//'`
		cat $b | grep "$id" | grep -q "<a href="
		if test $? -eq 0
		then
			l=`echo "$l + 1" | bc`
			echo "<li><a href='$b'>$pretty</a></li>" | sed 's/.md/.html/' | sed 's/source\///'
		fi
	done
	for m in $( ls -tr source/updates/*.html )
	do
		cat $m | grep "$id" | grep -q "<a href="
		if test $? -eq 0
		then
			echo "<li><a href='updates.html'>Updates</a></li>"
			l=`echo "$l + 1" | bc`
		fi
	done
}

echo "configuring..."

echo "building index..."
for f in $( ls source/*.md source/*.html )
do
	html_name="`echo $f | sed 's/source\///g' | sed 's/.md//g' | sed 's/.html//g'`.html"
	pretty=`head -1 $f | sed 's/# //' | sed 's/<center><h1>:: //' | sed 's/ ::<\/h1><\/center>//'`
	index+="<li><a href='$html_name'>$pretty</a></li>"
	# take this next line out if you make your own static table of contents above
	toc+="<li><a href='$html_name'>$pretty</a></li>"
	echo ". [$pretty]($html_name)"
done

echo -n "trying to generate site/ directory... "
mkdir site
if test $? -eq 0
then
	echo "ok"
else
	echo -n "removing existing pages... "
	rm site/*.html
	rm site/rss.xml
	echo "ok"
fi


echo "running htmlification of source/*.md..."

for f in $(ls -tr source/*.md | sed '/updates.md/d')
do
	file=`echo $f | sed 's/source\///g'`
	pretty=`head -1 $f | sed 's/# //' | sed 's/<center><h1>:: //' | sed 's/ ::<\/h1><\/center>//'`
	head_to_toc=$( head_to_toc_build "$pretty" )
	echo -n ". htmlifying $f... "
	main=$( htmlify $file )

	echo -n "finding backlinks... "
	id="`echo $file | sed 's/.md//g'`.html"
	backlinks=$( backlink )
	if [ -z "$backlinks" ]
	then
		backlink_header=""
	else
		backlink_header="<br><br><br><h3>Backlinks:</h3>"
	fi
	backlink > /dev/null
	echo -n "$l. "

	page="$head_to_toc$toc$toc_to_main$main$backlink_header<ul>$backlinks</ul>$main_to_end"

	echo "writing $id..."
	echo "$page" > site/$id
done
echo "compiling source/*.html..."
for f in $(ls -tr source/*.html)
do
	file=`echo $f | sed 's/source\///g'`
	pretty=`head -1 $f | sed 's/# //' | sed 's/<center><h1>:: //' | sed 's/ ::<\/h1><\/center>//'`
	head_to_toc=$( head_to_toc_build "$pretty" )
	echo -n ". reading $f... "
	main=$( cat $f )

	echo -n "finding backlinks... "
	id=$file
	backlinks=$( backlink )
	if [ -z "$backlinks" ]
	then
		backlink_header=""
	else
		backlink_header="<br><br><br><h3>Backlinks:</h3>"
	fi
	backlink > /dev/null
	echo -n "$l. "

	page="$head_to_toc$toc$toc_to_main$main$backlink_header<ul>$backlinks</ul>$main_to_end"

	echo "writing $file..."
	echo "$page" > site/$file
done


# create index page
echo -n "creating index page... "
head_to_toc=$( head_to_toc_build "Index" )
main="<center><h1>:: Index ::</h1></center>
<strong>this is an automatically-generated index of the site's source files</strong>
<ul>
$index
</ul>"
echo -n "finding backlinks... "
id="index.html"
backlinks=$( backlink )
if [ -z "$backlinks" ]
then
	backlink_header=""
else
	backlink_header="<br><br><br><h3>Backlinks:</h3>"
fi
backlink > /dev/null
echo "$l. "
page="$head_to_toc$toc$toc_to_main$main$backlink_header<ul>$backlinks</ul>$main_to_end"
echo "$page" > site/index.html

echo "generating rss feed and compiling updates.html out of source/*.html..."
head_to_toc=$( head_to_toc_build "Updates" )
main="<center><h1>:: Updates ::</h1></center>
<strong>View the <a href='rss.xml'>RSS feed</a> built from this same content</strong>"

for f in $(ls -t source/updates/*.html)
do
	echo ". adapting $f..."
	item_title=`head -1 $f | sed 's/<center><h2>- /  <title>/' | sed 's/ -<\/h2><\/center>/<\/title>/'`
	item_date=`head -2 $f | tail -1 | sed 's/<center><code>/  <pubDate>/' | sed 's/<\/code><\/center>/<\/pubDate>/'`
	item_main=`tail -n +3 $f`
	item="<item>
$item_title
  <link>https://example.com</link>
$item_date
  <description>
<![CDATA[$item_main]]>
  </description>
</item>
"
	itemstack+="$item"
	main+=`cat $f`
done

rss="<?xml version='1.0' encoding='UTF-8' ?>
<rss version='2.0'>
<channel>
<title>Your Site Title</title>
<link>https://example.org</link>
<description>Description words woo</description>
<lastBuildDate>$date</lastBuildDate>
<image>
  <url>https://example-image.jpg</url>
  <title>more words</title>
  <link>i don't actually know what this field is for</link>
</image>
$itemstack</channel></rss>"
echo ". writing rss.xml..."
echo "$rss" > site/rss.xml

echo -n ". writing updates.html... "
echo -n "finding backlinks... "
id="updates.html"
backlinks=$( backlink )
if [ -z "$backlinks" ]
then
	backlink_header=""
else
	backlink_header="<br><br><br><h3>Backlinks:</h3>"
fi
backlink > /dev/null
echo "$l. "
page="$head_to_toc$toc$toc_to_main$main$backlink_header<ul>$backlinks</ul>$main_to_end"
echo "$page" > site/updates.html

echo -n "creating symlink of source/style.css at site/style.css... "
cd site
ln -sf ../source/style.css style.css
cd ..
echo ""
