require 'bundler/gem_tasks'

task default: [:spec, :rubocop, :bundle_outdated]

desc 'run specs'
task(:spec) { ruby '-S rspec spec' }

desc 'rubocop'
task(:rubocop) { sh 'rubocop' }

desc 'bundle outdated'
task(:bundle_outdated) { sh 'bundle outdated' }

task test: :spec
