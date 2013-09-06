namespace :cache do
  namespace :view do
      desc "Deletes view cache"
      task(:clear) { |t| Dir.chdir('public') { ['features'].each{ |folder| `rm -rf #{folder}` } } }
  end
end