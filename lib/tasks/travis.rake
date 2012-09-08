task :travis do
  puts "Starting to run rspec spec..."
  system("export DISPLAY=:99.0 && bundle exec rspec spec")
  raise "rspec spec failed!" unless $?.exitstatus == 0
end