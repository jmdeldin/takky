require "bundler/gem_tasks"
require "rake/clean"
require "rake/testtask"

CLOBBER << "pkg"

Rake::TestTask.new do |t|
  t.test_files = FileList["spec/*_spec.rb"]
  t.libs << "spec"
end
