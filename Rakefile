require "bundler/gem_tasks"
require "rake/clean"
require "rspec/core/rake_task"

CLOBBER << "pkg"
RSpec::Core::RakeTask.new(:spec)

task :console do
  require "bundler/setup"
  require "pry"
  Pry.start
end

task :style do
  sh "rubocop -a ."
end

task default: :spec
