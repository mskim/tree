class Book < ActiveRecord::Base
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
  
  # 1. parse parts
  # 2. let each parts parse documents and subdocuments
    
  def parse_csv
    require 'csv'
    parts      = []
    @csv       = CSV.parse(book_plan, :headers => true)
    @current_part  = @csv.first.first[1].gsub(" ","_")
    template_name  = "part"
    @current_part_node = Node.create!(parent: root, name: @current_part, kind: "part", template: template_name)
    @csv.each do |row|
      puts "+++++++++ #{row}"
      if row.first[1] == nil
        row.first[1]  = @current_part
      elsif row.first[1] != @current_part
        @current_part = row.first[1].gsub(" ","_")
        @current_part_node = Node.create!(parent: root, name: @current_part, kind: "part")
        row.first[1]  = @current_part
      end
      create_book_node(row)
      # create_document_template(row)
    end
  end
    
  def create_book_node(row)
    document_name = row[1] if row[1] 
    template_name = row[3] if row[3] 
    if document_name
      @current_document_node = Node.create!(parent: @current_part_node, name: document_name, kind: "document", template: template_name)
    elsif sub_document = row[2]
      Node.create!(parent: @current_document_node, name: sub_document, kind: "sub-document", template: template_name)
    end
  end
  # part, document, subdocument, type, page, item, color
  def create_document_template(row)
    part_folder = book_path + "/#{row.first[1]}"
    FileUtils.mkdir_p(part_folder) unless File.directory?(part_folder)
    document_name = row[1] if row[1] 
    if document_name
      @document_path = part_folder + "/#{document_name.gsub(" ","_")}"
      # puts "@document_path:#{@document_path}"
      FileUtils.mkdir_p(@document_path) unless File.directory?(@document_path)
      template_name = row[3] if row[3]
      #copy content
      source = @template_path + "/#{template_name.gsub(" ","_")}"
      system("cp -R #{source}/* #{@document_path}/")
    elsif sub_document = row[2]
      sub_document_path = @document_path + "/#{sub_document.gsub(" ","_")}"
      FileUtils.mkdir_p(sub_document_path) unless File.directory?(sub_document_path)
      template_name = row[3] if row[3]
      #copy content
      source = @template_path + "/#{template_name}"
      system("cp -R #{source}/* #{sub_document_path}/")
    end
  end
  
  def update_book
    require 'csv'
    @csv       = CSV.parse(book_plan, :headers => true)
    @current_part  = @csv.first.first[1].gsub(" ","_")
    template_name  = "part"
    @current_part_node = Node.create!(parent: root, name: @current_part, kind: "part", template: template_name)
    @csv.each do |row|
      puts "+++++++++ #{row}"
      if row.first[1] == nil
        row.first[1]  = @current_part
      elsif row.first[1] != @current_part
        @current_part = row.first[1].gsub(" ","_")
        @current_part_node = Node.create!(parent: root, name: @current_part, kind: "part")
        row.first[1]  = @current_part
      end
      update_book_node(row)
      # create_document_template(row)
    end
  end
  
  def update_book_node
    
  end
  
  # collect all pdf files into pdf folder
  def collect_pdf
    FileUtils.mkdir_p(pdf_path) unless File.directory?(pdf_path)
    Dir.glob("#{book_path}/**/*.pdf") do |pdf_path|
      
    end
    page_index = 1
    nodes.each do |node|
      if node.kind == "documnet" || node.kind == "sub-documnet" 
    end
  end
  
end
