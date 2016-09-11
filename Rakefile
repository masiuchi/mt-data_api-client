require 'bundler/gem_tasks'

task default: [:spec, :rubocop]

desc 'run specs'
task(:spec) { ruby '-S rspec spec' }

desc 'rubocop'
task(:rubocop) { sh 'rubocop' }

task test: :spec
