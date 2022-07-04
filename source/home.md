# Home

Welcome to sitey-buildey!
You can write both markdown and HTML files in the <code>source/</code> directory, and they will be built into a website in the <code>site/</code> directory.
Lines of plain text in markdown files will be converted to <code>&lt;p&gt;</code> elements, and a title beginning with <code>#</code> on the first line will be processed into the index.
Titles in HTML pages should follow the format <code>&lt;center&gt;&lt;h1&gt;:: Your Title Here ::&lt;/h1&gt;&lt;/center&gt;</code> in order to be recognized by the script (if you change it, just make sure to update the associated lines in <code>config.sh</code>).
You can choose whether to use a pre-formatted navigation on the left or the automatically assembled one. In either case, <code>index.html</code> will be automatically built by the script to include all pages.
