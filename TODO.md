TODO
	- skip blank rows of csv when parsing
	CSV.open(import_file, skip_blanks: true).reject { |row| row.all?(&:nil?) }
	
	CSV.parse(import_file, headers: true, skip_blanks: true).delete_if { |row| row.to_hash.values.all?(&:blank?) }

	CSV.open(import_file, skip_blanks: true, headers: true).reject { |row| row.to_hash.values.all?(&:nil?) }

	CSV.readlines(import_file, skip_blanks: true, headers: true).reject { |row| row.to_hash.values.all?(&:nil?) }
	
	- flipbook viewing
	- rake file dependency on either layout.rb or stroy.md
	- RemoteStory
	- generate TOC content
	- sample book with 
		photo
		toc
		cover
		forward
		preface
		chapters
			Heading
			QuoteBox
			Header
			Footer
		index
		
2016 10 8
	- fix node parse_csv 
	- update page_number
	- 
2016 9 30
	- add flipbook viewing
	- update node
	- save content if it changed
	- fix \n\n to \r\n\r\n converted new paragraph from html text_area
	
2016 9 29
	- update node
	- save content and generate_pdf
	
	
	U+2611 check mark with box