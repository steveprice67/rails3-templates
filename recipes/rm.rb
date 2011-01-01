remove_file 'README'
remove_dir 'doc'

inside 'public' do
  remove_file 'images/rails.png'
  remove_file 'index.html'
  remove_file 'robots.txt'
end
