#!/bin/bash

#motd=`cat NOTES`


# define the filler html variables
# $toc and $main are defined in the loop

function head_to_toc_build {
	head_to_toc="
<!DOCTYPE html>
<html>
	<head>
		<link rel='icon' type='image/png' href='icon.ico' />
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
					<h2>site title</h2><br>
					<details open>
						<summary><b>contents</b></summary>
						<ul class='menu'>
							<li><a href='index.html'>home</a></li>

							<!-- begin table of contents dump -->

	"
	echo "$head_to_toc"
}

toc_to_main="
						</ul>
					</details><br>
					<code>you can also put a footer thing here</code>
				</td>
				<td valign='top' class='main'>

					<!-- begin main content dump -->

"

main_to_end="

					<!-- end main content dump -->

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

echo "configuring..."
echo "motd: $motd"

# build toc
echo "building table of contents..."
for f in $(ls -r source/*.md | sed '/000/d')
do
	file=`echo $f | sed 's/source\///g'`
	entry_num=`echo $file | cut -c 1-3`
	title=`echo $file | sed 's/.md//g' | sed 's/^....//' | sed 's/-/ /g'`
	html_name="`echo $file | sed 's/.md//g'`.html"
	toc+="<li><a href='$html_name'>$entry_num: $title</a></li>"
	echo ". [$entry_num: $title]($html_name)"
done


echo -n "trying to generate site/ directory... "
mkdir site
if test $? -eq 0
then
	echo "ok"
fi

# assemble pages
for f in $(ls -r source/*.md | sed '/000/d')
do
	file=`echo $f | sed 's/source\///g'`
	entry_num=`echo $file | cut -c 1-3`
	title=`echo $file | sed 's/.md//g' | sed 's/^....//' | sed 's/-/ /g'`
	head_to_toc=$( head_to_toc_build "$entry_num $title" )
	echo -n "htmlifying $f... "
	main=$( htmlify $file )

	page="$head_to_toc$toc$toc_to_main<center><code>$entry_num</code></center>$main$main_to_end"
	html_name="`echo $file | sed 's/.md//g'`.html"

	echo "writing $html_name..."
	echo "$page" > site/$html_name
done

function build_index {
	src=`ls source/000*.md`
	file=`echo $src | sed 's/source\///g'`
	echo "building index.html from $src..."
	head_to_toc=$( head_to_toc_build catalog )
	main=$( htmlify $file )
	page="$head_to_toc$toc$toc_to_main$main$main_to_end"
	html_name="`echo $file | sed 's/.md//g'`.html"
	echo "$page" > site/index.html
}

build_index

echo -n "creating symlink of source/style.css at site/style.css... "
cd site
ln -sf ../source/style.css style.css
cd ..
echo ""

echo -n "creating symlink of source/icon.ico at site/icon.ico... "
cd site
ln -sf ../source/icon.ico icon.ico
cd ..
echo ""

echo -n "creating symlink of source/media/ at site/media... "
cd site
ln -sf ../source/media media
cd ..
echo ""
