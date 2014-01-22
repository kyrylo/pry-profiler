def test_files
  paths = FileList['test/**/*_test.rb']
  paths.shuffle!.join(' ')
end

desc "Run the tests"
task :test do
  exec "ruby #{ test_files }"
end

task :default => :test
