# Tree 
Rails app for simulating book tree.

How does it work?

We create a book_plan, a csv file that has a plan for the book.
With book_plan, we create a file system representing a book.
And we also create Nodes for each document.

## Tables

### book
	title
	type:
	book_plan: text
	root_node_id: integer

### node
	name
	type	# part, document, sub-document, page
	has_ancestry	
		
### document_type
	- name cover
	- part front

	front_matter = %w{cover preface forward dedication colophone toc}
	body_matter = %w{chapter quiz_chapter items_chapter pdf_insert}
	rear_matter = %w{index appendix glossary}

---	
front_matter
	- cover
	- preface
	- toc
part1:
	01 subject and verb
	02 matching numbers of subject and verb
	03 matching numbers of subject and verb
	04 matching numbers of subject and verb
	05 matching numbers of subject and verb

	cover: "cover"
	preface: "preface"
	intro: "intro"
	toc: "toc"
	01: "chapter"
	02: "chapter"
	03: "chapter"
