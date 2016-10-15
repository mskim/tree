TODO

		
	- RemoteStory
	- generate TOC content
	- sample book with 
		photo
		toc
		cover
		forward
		preface
		chapters
			heading
			quoteBox
			header
			footer
			footnote
		index

2016 10 14

	- flipbook viewing
		add flipbook in each node

2016 10 9
	- toc_node
	- front_nodes
	- body_nodes
	- rear_nodes
	- update_starting_page
	- update_toc
	
2016 10 8
	- fix parse_csv in Book Model
	- update page_number
	- skip blank rows of csv when parsing
	- all?
	check if first 3 column are empty?, it calls v.to_s.empty? for fixnum values
	@csv = CSV.parse(import_file, headers: true, skip_blanks: true).delete_if do |row|  
      row.to_hash.values[0..2]all?{|v| v.to_s.empty?}
    
		CSV.open(import_file, skip_blanks: true).reject { |row| row.all?(&:nil?) }
		CSV.parse(import_file, headers: true, skip_blanks: true).delete_if { |row| row.to_hash.values.all?(&:blank?) }
		CSV.open(import_file, skip_blanks: true, headers: true).reject { |row| row.to_hash.values.all?(&:nil?) }
		CSV.readlines(import_file, skip_blanks: true, headers: true).reject { |row| row.to_hash.values.all?(&:nil?) }
	
	- rake file dependency on either layout.rb or stroy.md
		task :default => :pdf
		source_files = Dir.glob("#{File.dirname(__FILE__)}/*.md")
		task :pdf => source_files.map {|source_file| File.dirname(source_file) + "/output.pdf"}
		source_files.each do |source_file|
		  pdf_file = File.dirname(source_file) + "/output.pdf"
		  file pdf_file => [source_file, "*.rb"] do
		    sh "/Applications/nr_chapter.app/Contents/MacOS/nr_chapter . "
		  end
		end
2016 9 30
	- add flipbook viewing
	- update node
	- save content if it changed
	- fix \n\n to \r\n\r\n converted new paragraph from html text_area
	
2016 9 29
	- update node
	- save content and generate_pdf
	
	
	U+2611 check mark with box