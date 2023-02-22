# frozen_string_literal: true

require 'logger'
require 'triggers_check'
logger = Logger.new($stdout)
logger.level = Logger::DEBUG

%w[drv driver].each do |object|
  checker = TriggersCheck::Checker.new(work_directory: '.', test_objects: [object], logger: logger)
  puts "Test object: #{object} -> #{checker.trigger?}"
end
