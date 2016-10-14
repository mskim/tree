class Book < ActiveRecord::Base
  attr_accessor :parts
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
    chapter_nodes = body_node.children
    Dir.glob("#{chapter_source_path}/*.{md,markdown}").each_with_index do |m, i|
      chapter_nodes[i].copy_node_text_from(m)
    end
  end
  
  
PART_INDEX          = 0
DOCUMENT_INDEX      = 1
SUB_DOCUMENT_INDEX  = 2
TEMPLATE_INDEX      = 3
PAGE_COUNT_INDEX    = 4
  
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
  
  ####################### Flipbook ###############
  def flipbook_path
    book_path + "/flipbook"
  end
  
  def flipbook_images_path
    "#{Rails.root}/public/flipbook/#{id}/images"
  end
  
  def template_js_path
    "#{Rails.root}/public/flipbook/template/js"
  end
  
  def template_css_path
    "#{Rails.root}/public/flipbook/template/css"
  end
  
  def flipbook_js_path
    "#{Rails.root}/public/flipbook/#{id}/js"
  end
    
  def flipbook_css_path
    "#{Rails.root}/public/flipbook/#{id}/css"
  end
  
  def copy_assets_to_flipbook
    # copy js
    system("cp -r #{template_js_path} #{flipbook_js_path}") unless File.directory?(flipbook_js_path)
    # copy css
    system("cp -r #{template_css_path} #{flipbook_css_path}") unless File.directory?(flipbook_css_path)
  end
  
  def flipbook_html_path
    flipbook_path + "/index.html"
  end
  
  def flipbook_template_erb_path
    "#{Rails.root}/public/flipbook/template/index.html.erb"
  end
    
  
  def collect_flipbook_data
    flipbook_data = []
    front_matters.each do |front_matter|
      if front_matter.preview_images_full_path.length > 0
        front_matter_folder = flipbook_images_path + "/#{front_matter.kind}"
        system("mkdir -p #{front_matter_folder}") unless File.directory?(front_matter_folder)
        @h = {}
        @h[:title]    = front_matter.kind
        @h[:preview]  = []
        # copy preview images to flopbook
        front_matter.preview_images.each do |image|
          target = front_matter_folder + "/#{File.basename(image)}"
          system("cp #{image} #{target}")
          @h[:preview]  << target
        end
        flipbook_data << @h
      end
    end
    chapters.each_with_index do |chapter, i|
      if chapter.preview_images.length > 0
        chapter_folder = flipbook_images_path + "/chapter#{i.to_s.rjust(2,'0')}"
        system("mkdir -p #{chapter_folder}") unless File.directory?(chapter_folder)
        @h = {}
        @h[:title]    = chapter.title
        @h[:preview]  = []
        # copy preview images to flopbook
        # puts "chapter.preview_images_full_path:#{chapter.preview_images_full_path}"
        chapter.preview_images_full_path.each do |image|
          target = chapter_folder + "/#{File.basename(image)}"
          system("cp #{image} #{target}")
          @h[:preview]  << target
        end      
        flipbook_data << @h
      end
    end
    rear_matters.each do |rear_matter|
      if rear_matter.preview_images.length > 0
        rear_matter_folder = flipbook_images_path + "/#{rear_matter.kind}"
        system("mkdir -p #{rear_matter_folder}") unless File.directory?(rear_matter_folder)
        @h = {}
        @h[:title]    = rear_matter.kind
        @h[:preview]  = []
        # copy preview images to flopbook
        rear_matter.preview_images_full_path.each do |image|
          target = rear_matter_folder + "/#{File.basename(image)}"
          system("cp #{image} #{target}")
          @h[:preview]  << target
        end
        flipbook_data << @h
      end
    end
    flipbook_data
  end
  
  def generate_flipbook
    system("mkdir -p #{flipbook_path}") unless File.directory?(flipbook_path)
    @flipbook_data  = collect_flipbook_data
    copy_assets_to_flipbook
    template_file   = File.open(flipbook_template_erb_path, 'r'){|f| f.read}
    erb             = ERB.new(template_file)
    File.open(flipbook_html_path, 'w'){|f| f.write erb.result(binding)}
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
  
end
