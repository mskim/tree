class Book < ActiveRecord::Base
  attr_accessor :parts
  after_create :setup,:create_root_node
  has_many :nodes
  
  def setup
    FileUtils.mkdir_p(book_path) unless File.directory?(book_path)
  end
  
  # create root node for book
  def create_root_node
    Node.create!(book_id: id, parent: nil, name: title, kind: "book")
  end
  
  def root
    nodes.first
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
  
PART_INDEX          = 0
DOCUMENT_INDEX      = 1
SUB_DOCUMENT_INDEX  = 2
TEMPLATE_INDEX      = 3
PAGE_COUNT_INDEX    = 4
  
  # seperate rows into parts first, 
  # then create nodes for each parts headed(parent) by part node with no document
  # add other noeds as documents and sub-document
  def parse_csv
    require 'csv'
    @csv          = CSV.parse(book_plan, :headers => true)
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
    @parts << @current_part
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
  
  def update_page_number
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
  
end
