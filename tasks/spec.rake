require 'rspec'
require 'rspec/core/rake_task'

desc 'run specs'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = FileList[File.join('spec', '**', '*_spec.rb')]
  t.verbose = true
end

task :default => :spec