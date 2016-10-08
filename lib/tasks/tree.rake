
namespace :tree do
  desc "Copy template from library to current project."
  task :copy_template =>:environment do
    puts "copying templates from library"
    Node.all.each do |n|
      n.create_job_folders
    end
  end
  
  desc "Copy Rakefile from library. This will update all Rakefiles."
  task :copy_rakefile =>:environment do
    puts "copying Rakefile ... "
    Node.all.each do |n|
      n.copy_rakefile
    end
  end
  
  desc "Copy design files from library. This will update all design files."
  task :copy_design =>:environment do
    puts "copying design files... This will updata all design files..."
    Node.all.each do |n|
      n.copy_design
    end
  end
  
  desc "Copy text files from text source to current project."
  task :copy_text =>:environment do
    puts "copying text files from text source... This will updata all text files..."
    Node.all.each do |n|
      n.copy_text
    end
  end
  
  desc "Share text files of current project to to Dropbox."
  task :share_text =>:environment do
    puts "updating source text files from text source"
    Node.all.each do |n|
      n.share_text
    end
  end
  
  desc "Create sample texts."
  task :create_sample_text =>:environment do
    puts "Share sample text, copy to Dropbox"
    Node.all.each do |n|
      n.create_sample_text
    end
  end
  
  desc "Share sample text of current project to Dropbox."
  task :share_sample_text =>:environment do
    puts "Share sample text, copy to Dropbox"
    Node.all.each do |n|
      n.share_sample_text
    end
  end
  
  
  desc "Remove unwanted markdown file."
  task :remove_other_md =>:environment do
    puts "Removing unwanted md files"
    Node.all.each do |n|
      n.remove_other_md
    end
  end
  
  desc "Generate pdf for all documentd" 
  task :generate_pdf =>:environment do 
    Node.all.each do |n|
      n.generate_pdf
    end
  end
end