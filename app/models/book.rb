class Book < ActiveRecord::Base
  attr_accessor :parts, :segment_list
  after_create :setup,:create_root_node
  has_many :nodes
  
  def setup
    FileUtils.mkdir_p(book_path) unless File.directory?(book_path)
  end
  
  def book_path
    "#{Rails.root}/public/#{id}"
  end
  
  def csv_path
    book_path + "/book_plan.csv"
  end
  
  def pdf_path
    book_path + "/pdf"
  end
  
  # create root node for book
  def create_root_node
    Node.create!(book_id: id, parent: nil, name: title, kind: "book")
  end
  
  def root
    nodes.first
  end
  
  def part_nodes
    nodes.first.children
  end
  
  def front_node
    nodes.first.children.select{|n| n.name =='front'}.first
  end
  
  def body_node
    nodes.first.children.select{|n| n.name =='body'}.first
  end
  
  def chapter_nodes
    body_node.children
  end
  
  def rear_node
    nodes.first.children.select{|n| n.name =='rear'}.first
  end
  
  def toc_node
    front_node.children.each do |node|
      return node if node.name == 'toc'
    end
    nil
  end
  
  def documents
    list = part_nodes.collect {|p| p.children}
    list.flatten
  end

  def sub_documents
    list = documents.collect {|d| d.children} 
    list.flatten
  end
    
  def update_toc
    toc_erb =<<EOF
# <%= @book_title %>
<% @chapters.each do |chapter| %>
## <%= chapter.name %>\t<%= chapter.starting_page %>
<% end %>
EOF
    update_starting_page
    @toc_node     = toc_node 
    template  = toc_erb
    toc_erb_path  = @toc_node.path + "/toc.md.erb"
    if File.exist?(toc_erb_path)
      template  = File.open(toc_erb_path, 'r')
    end
    @book_title = title
    @chapters   = body_node.children.collect{|n| n}
    erb         = ERB.new(template)
    toc_content = erb.result(binding)
    toc_md_path = @toc_node.path + "/toc.md"
    File.open(toc_md_path, 'w'){|f| f.write toc_content }
  end
  
  def chapter_source_path
    book_path + "/source"
  end
  
  def copy_from_source
    Dir.glob("#{chapter_source_path}/*.{md,markdown}").each_with_index do |m, i|
      chapter_nodes[i].copy_node_text_from(m)
    end
  end
  
  
PART_INDEX          = 0
DOCUMENT_INDEX      = 1
SUB_DOCUMENT_INDEX  = 2
TEMPLATE_INDEX      = 3
PAGE_COUNT_INDEX    = 4

# Maximun number of chapter graups 
MAX_GROUP           = 4
  # 
  # parsing csv into nodes steps
  # 1. seperate rows into group of parts 
  # 2. then create nodes for each parts 
  #    headed(parent) by part node with no document
  # 3. add other noeds as documents and sub-document
  
  def parse_csv
    require 'csv'

    # skip blank rows 
    # also skip the row if first three columns are empty? 
    # this removes bottom total page_count row.
    # using .all? for first three column row.to_hash.values[0..2].all?  	
    # blank? is supported only in Rails, not in Ruby
    @csv = CSV.parse(book_plan, :headers=> true, :skip_blanks=> true).delete_if do |row| 
      row.to_hash.values[0..2].all?{|col| col.to_s.blank?}
    end
		
    @parts        = []
    @csv.each_with_index do |row, i|
      if row[PART_INDEX]
        @parts << @current_part unless i == 0
        @current_part = []
        @current_part << row
      else
        @current_part << row
      end
    end
    @parts << @current_part # insert last part
    @parts.each do |part|
      create_part_nodes(part)
    end
  end
  
  def create_part_nodes(rows)
    part_row = rows.first
    part = Node.create!(parent: root, name: part_row[PART_INDEX], kind: "part")
    # first document in same row as part
    current_document = Node.create!(parent: part, name: part_row[DOCUMENT_INDEX], kind: "document", template: part_row[TEMPLATE_INDEX], page_count: part_row[PAGE_COUNT_INDEX]) 
    rows.shift
    rows.each do |row|
      if  row[DOCUMENT_INDEX]
        current_document = Node.create!(parent: part, name: row[DOCUMENT_INDEX], kind: "document", template: row[TEMPLATE_INDEX], page_count: row[PAGE_COUNT_INDEX])
      elsif row[SUB_DOCUMENT_INDEX]
        Node.create!(parent: current_document, name: row[SUB_DOCUMENT_INDEX], kind: "sub-document", template: row[TEMPLATE_INDEX], page_count: row[PAGE_COUNT_INDEX])
      end
    end
  end

  #TODO
  # I should just call root.total_page_count
  # and let each node calculate total page_number of thir children  
  def total_page_count
    documents.collect{|n| n.total_page_count}.reduce(:+)
  end
  
  def update_starting_page
    default_page_count = 2
    page_number = 1
    Node.all.each do |node|
      next if node.kind == "book"
      next if node.kind == "part"
      if node.page_count
        node.starting_page  = page_number
        page_number         += node.page_count
      else
        node.starting_page  = page_number
        node.page_count     = default_page_count
        page_number         += node.page_count
      end
      node.save
    end
    puts "total page count:#{page_number - 1 }"
  end
    
  # collect all pdf files into pdf folder
  def collect_pdf
    FileUtils.mkdir_p(pdf_path) unless File.directory?(pdf_path)
    Dir.glob("#{book_path}/**/*.pdf") do |pdf_path|
      
    end
    # page_index = 1
    # nodes.each do |node|
    #   if node.kind == "documnet" || node.kind == "sub-documnet"
    #     
    #   end
    # end
  end

  ####################### Flipbook ###############
  
  def flipbook_path
    book_path + "/flipbook"
  end
  
  def flipbook_images_path
    "#{flipbook_path}/images"
  end

  def flipbook_js_path
    "#{flipbook_path}/js"
  end
    
  def flipbook_css_path
    "#{flipbook_path}/css"
  end
  
  def flipbook_font_path
    "#{flipbook_path}/fonts"
  end
  def flipbook_html_path
    "#{flipbook_path}/index.html"
  end
  
  def flipbook_tempate_path
    "#{Rails.root}/public/flipbook_template"
  end
  
  def template_js_path
    "#{flipbook_tempate_path}/js"
  end
  
  def template_css_path
    "#{flipbook_tempate_path}/css"
  end
  
  def template_images_path
    "#{flipbook_tempate_path}/images"
  end
  
  def template_font_path
    "#{flipbook_tempate_path}/fonts"
  end
  
  # create downloadable flipbook, a separate grouped web pages with own js and css
  # index.html, front, chapter 1-3, chapter 4-5, chapter 6-9, rear
  def generate_flipbook
    @segment_list             = []
    setup_flipbook_assets
    setup_flipbook_front
    setup_flipbook_chapters
    setup_flipbook_rear
    generate_flipbook_html
  end
  
  def setup_flipbook_assets
    system("mkdir -p #{flipbook_path}") unless File.directory?(flipbook_path) 
    system("mkdir -p #{flipbook_images_path}") unless File.directory?(flipbook_images_path)
    system("cp -r #{template_js_path} #{flipbook_js_path}") unless File.directory?(flipbook_js_path)
    system("cp -r #{template_css_path} #{flipbook_css_path}") unless File.directory?(flipbook_css_path)
    system("cp -r #{template_font_path} #{flipbook_font_path}") unless File.directory?(flipbook_font_path)
    
    
  end

  def setup_flipbook_front
    @segment_data         = {}
    @segment_data[:name]  = "Front"
    @segment_data[:pages] = []
    front_folder = flipbook_images_path + "/front"
    system("mkdir -p #{front_folder}") unless File.directory?(front_folder)
    front_node.children.each do |node|
      # copy_previews_to_flipbook and insert_data segment_data[:pages]
      preview_images      = node.preview_images
      preview_images.each do |image|
        target              = flipbook_images_path + "/front/#{node.name}:#{File.basename(image)}"
        system("cp #{image} #{target}")
        @segment_data[:pages] << target
      end
    end
    @segment_list << @segment_data
    
  end

  def setup_flipbook_chapters
    body_folder = flipbook_images_path + "/body"
    system("mkdir -p #{body_folder}") unless File.directory?(body_folder)
    # separate chapters into groups of MAX_GROUP
    chapters = chapter_nodes
    chapter_length = chapters.length
    if chapter_length > MAX_GROUP
      chapter_count = chapter_length/MAX_GROUP
      if chapter_length % MAX_GROUP > 0
        chapter_count += 1
      end
    else
      chapter_length = chapter_length
    end
    chapter_number = 1
    chapters.each_slice(MAX_GROUP).each_with_index do |chapter_group, i|
      stating         = i*chapter_count + 1
      ending          = stating + chapter_count - 1
      name            = "chapters:#{stating}-#{ending}"
      @segment_data   = {}
      @segment_data[:name]  =  name
      @segment_data[:pages] = []
      chapter_group.each_with_index do |chapter,j|
        chapter.preview_images.each do |image|
          target = flipbook_images_path + "/body/#{chapter_number}-#{File.basename(image)}"
          system("cp #{image} #{target}")
          @segment_data[:pages] << target
        end
        chapter_number += 1
        # TODO what if sub_doc images come before or middle of chapter

      end
      @segment_list << @segment_data
    end
  end
  
  def setup_flipbook_rear
    @segment_data         = {}
    @segment_data[:name]  = "Rear"
    @segment_data[:pages] = []
    rear_folder = flipbook_images_path + "/rear"
    system("mkdir -p #{rear_folder}") unless File.directory?(rear_folder)
    rear_node.children.each do |node|
      preview_images      = node.preview_images
      preview_images.each do |image|
        target              = flipbook_images_path + "/rear/#{node.name}:#{File.basename(image)}"
        system("cp #{image} #{target}")
        @segment_data[:pages] << target
      end
    end
    @segment_list << @segment_data if @segment_data[:pages].length > 0
  end
  
  def generate_flipbook_html
    @book_title = title
    @segment_list.each_with_index do |segment, i|
      @segment
      html_erb        = flipbook_tempate_path + "/index.html.erb"
      template_file   = File.open(html_erb, 'r'){|f| f.read}
      puts "+++++++++ segment:#{segment}"
      erb             = ERB.new(template_file)
      html            = erb.result(binding)
      if i == 0
        html_path       = flipbook_path + "/index.html"
      else
        html_path       = flipbook_path + "/index#{i}.html"
      end
      File.open(html_path, 'w'){|f| f.write html}
    end
  end
end
