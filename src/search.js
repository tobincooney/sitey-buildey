function searchGo() {
	document.getElementById('results').innerHTML = '';
	var terms = document.getElementById('searchbar').value.toLowerCase();
	var matchedpages = [];
	var results = '';
	var i=0;
	for (const page of pages) {
		termarray = terms.split(' ');
		for (const term of termarray) {
			if ( page[2].toLowerCase().includes(term) === true || page[1].toLowerCase().includes(term) === true ) {
				if ( matchedpages.includes(page[0]) === false ) {
					matchedpages.push(page[0]);
					i++;
					results = results + '<hr><a href=\'' + page[0] + '\'><h3>' + page[1] + '</h3></a>';
				}
				var bodylines = page[2].split('\n');
				for (const line of bodylines) {
					if ( line.includes(term) === true ) {
						var re = new RegExp(term, 'g');
						var bold = '<b style=\'background-color:red; color:white;\'>' + term + '</b>';
						var clip = line.replace(re, bold);
						results = results + '<p>' + clip + '&nbsp;&nbsp;<a href=\'' + page[0] + '\'>&gt;</a></p>';
					}
				}
			}
		}
	}
	document.getElementById('results').innerHTML = '<code>' + i + ' result(s).' + results;
}
