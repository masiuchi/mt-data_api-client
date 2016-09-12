require 'bundler/gem_tasks'

default = [:spec, :rubocop, :bundle_outdated]
task default: default

desc 'circleci'
task circleci: default - [:rubocop]

desc 'run specs'
task(:spec) { ruby '-S rspec spec' }
task test: :spec

desc 'rubocop'
task(:rubocop) { sh 'rubocop' }

desc 'bundle outdated'
task(:bundle_outdated) { sh 'bundle outdated' }
