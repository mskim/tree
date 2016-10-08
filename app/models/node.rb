class Node < ActiveRecord::Base
  attr_accessor :story, :design 
  after_create :create_job_folders
  belongs_to :book
  has_ancestry

  def path
    "#{Rails.root}/public/#{ancestry}/#{id}"
  end
  
  def layout_path
    path + "/layout.rb"
  end

  def md_path
    path + "/#{id}.md"
  end

  def pdf_image_path
    "/#{ancestry}/#{id}/output.pdf"
  end
  
  
  def create_job_folders
    puts __method__
    FileUtils.mkdir_p(path) unless File.directory?(path)
    @template_path = "/Users/Shared/SoftwareLab/document_template"
    #copy content
    source = @template_path + "/#{template}"
    puts "source:#{source}"
    unless File.directory?(source)
      puts "No template #{template} found!!!"
    else
      puts "coping template...."
      puts "source:#{source}"
      puts "path:#{path}"
      system("cp -R #{source}/* #{path}/")
    end
  end
  
  def copy_rakefile
    template_path = "/Users/Shared/SoftwareLab/document_template"
    source        = template_path + "/#{template}/Rakefile"
    rake_path     = path + "/Rakefile"
    unless File.exist?(source)
      #no Rakefile found
    else
      system("cp #{source} #{rake_path}")
    end
  end
  
  def copy_design
    @template_path  = "/Users/Shared/SoftwareLab/document_template"
    source          = @template_path + "/#{template}/layout.rb"
    unless File.exist?(source)
      puts " #{source} not found!!!"
    else
      system("cp #{source} #{layout_path}")
    end
  end
  
  def copy_text
    text_source = "~/Dropbox/text_source/#{id}.md"
    text_source = File.expand_path(text_source)
    puts "text_source:#{text_source}"
    puts "File.exist?(text_source):#{File.exist?(text_source)}"
    unless File.exist?(text_source)
      puts "text_source doesn't exit!!!"
    else
      puts "copying"
      text_path = path + "/#{id}.md"
      puts "text_path:#{text_path}"
      system("cp #{text_source} #{text_path}")
    end
  end
  
  def create_sample_text
    text_content=<<EOF
---
book_title: 수능만만 어법어휘 모의고사
title: #{name}
---

# #{name}

puts some text here.

Paragraph are separated by empty line.

This is the third line.

## This is section heading

Some more text goes here.

EOF
    sample_path = path + "/#{id}_sample.md"
    File.open(sample_path, 'w'){|f| f.write text_content}
  end
  
  # write sample text to Dropbox
  def share_sample_text
    dropbox_folder = "~/Dropbox/text_source"
    FileUtils.mkdir_p(dropbox_folder) unless File.directory?(dropbox_folder)
    sample_path = path + "/#{id}_sample.md"
    create_sample_text unless File.exist?(sample_path)
    system("cp #{sample_path} #{dropbox_folder}/")
  end
  
  # write text to Dropbox
  def share_text
    dropbox_folder = "~/Dropbox/text_source/"
    FileUtils.mkdir_p(target_folder) unless File.directory?(target_folder)
    text_path = path + "/#{id}.md"
    system("cp #{text_path} #{dropbox_folder}/") if File.exist?(text_path)
  end
  
  def remove_other_md
    Dir.glob("#{path}/*.md") do |f|
      FileUtils.rm(f) unless f == md_path
    end
  end

  def read_story_file
    return @story if @story
    @story_path =Dir.glob("#{path}/*.{md,txt}").first
    if @story_path && File.exist?(@story_path)
      return File.open(@story_path, 'r'){|f| f.read}
    end
    nil
  end
    
  def write_story_file(new_story)
    @story = new_story
    @story_path = @story_path || Dir.glob("#{path}/*.{md,txt}").first
    puts "@story_path:#{@story_path}"
    File.open(@story_path, 'w'){|f| f.write @story}
    # end
  end
  
  
  def read_design_file
    return @design if @design
    if File.exist?(layout_path)
      return File.open(layout_path, 'r'){|f| f.read}
    end
    nil
  end
    
  def write_design_file(new_design)
    @design = new_design
    File.open(layout_path, 'w'){|f| f.write @design}
    # end
  end
  
  def images
    
  end
  
  def generate_pdf
    if File.exist?(layout_path)
      system("cd #{path} && rake")
    end
  end
end
