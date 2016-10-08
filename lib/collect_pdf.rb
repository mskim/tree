
book_path = "/Users/mskim/Development/rails_rlayout/tree/public/1"
# book_path = "/Users/mskim/demo_book_plan"
# pdf_images = []
# Dir.glob("#{book_path}/**/*.pdf") do |pdf_path|
#   pdf_images << pdf_path unless pdf_path =~/images/
# end
# 
# puts pdf_images


# pdf_folder = book_path + "/_pdf"
# system("mkdir -p #{pdf_folder}") unless File.directory?(pdf_folder)

jpg_images = []
Dir.glob("#{book_path}/**/*.jpg") do |jpg_path|
  jpg_images << jpg_path if jpg_path =~/preview/
end

puts jpg_images

# page_images.each_with_index do |path, i|
  