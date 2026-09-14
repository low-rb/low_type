# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  desc 'Run specs with LowType.config.type_checking forced true'
  task :type_checking_true do
    sh({ 'TYPE_CHECKING' => 'true' }, 'bundle exec rspec')
  end

  desc 'Run specs with LowType.config.type_checking forced false'
  task :type_checking_false do
    sh({ 'TYPE_CHECKING' => 'false' }, 'bundle exec rspec')
  end

  desc 'Run the full suite once per type_checking state'
  task all: %i[type_checking_true type_checking_false]
end

task default: 'spec:all'
