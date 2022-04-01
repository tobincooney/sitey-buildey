motd=`cat motd`


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
					<details open>
						<summary><b>contents</b></summary>
						<ul class='menu'>
							<li><a href='index.html'>home</a></li>
	"
	echo "$head_to_toc"
}

toc_to_main="
						</ul>
					</details><br>
					<code>you can also put a footer thing here</code>
				</td>
				<td valign='top' class='main'>
"

main_to_end="
				</td>
			</tr>
		</table>
	</body>
</html>
"

# convert md file input to html string
function htmlify {
	yield=`cat $1 | sed 's/^/<p>/g' | sed 's#$#</p>#g'`
	yield=`echo "$yield" | \
		sed 's#<p><#<#' | \
		sed 's#></p>$#>#' | \
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
for f in $(ls -r *.md | sed '/000/d')
do
	entry_num=`echo $f | cut -c 1-3`
	title=`echo $f | sed 's/.md//g' | sed 's/^....//' | sed 's/-/ /g'`
	html_name="`echo $f | sed 's/.md//g'`.html"
	toc+="<li><a href='$html_name'>$entry_num: $title</a></li>"
	echo "[$entry_num: $title]($html_name)"
done


# assemble pages
for f in $(ls -r *.md | sed '/000/d')
do
	entry_num=`echo $f | cut -c 1-3`
	title=`echo $f | sed 's/.md//g' | sed 's/^....//' | sed 's/-/ /g'`
	head_to_toc=$( head_to_toc_build "$title" )
	echo "htmlifying $f..."
	main=$( htmlify $f )

	page="$head_to_toc$toc$toc_to_main$main$main_to_end"
	html_name="`echo $f | sed 's/.md//g'`.html"

	echo "writing $html_name..."
	echo "$page" > $html_name
done

function build_index {
	src=`ls 000*.md`
	echo "building index from $src..."
	head_to_toc=$( head_to_toc_build home )
	main=$( htmlify $src )
	page="$head_to_toc$toc$toc_to_main$main$main_to_end"
	html_name="`echo $src | sed 's/.md//g'`.html"
	echo "$page" > index.html
}

build_index
