# frozen_string_literal: true

require_relative 'triggers_check/version'
require 'yaml'

module TriggersCheck
  # == Description
  #
  # Ruby class provides the ability to check whether the testing
  # process should be started. By comparing files changed in commit to
  # the predefined configuration, Different actions can be triggered if
  # specific files or directories changed
  #
  # == Actions list
  #
  # +trigger?+::      Checks triggers.
  #
  class Checker
    DIFF_FILENAME = 'diff.txt'
    TRIGGER_YAML = 'triggers.yml'

    # == Description
    #
    # Initializes new object of type Checker
    #
    # == Params:
    #
    # +work_directory+::   The directory where the source code is located
    # +test_objects+::     The list of objects that are expected to run tests
    # +diff_file+::        The file with PR difference
    #                      (default: #{work_directory}/diff.txt)
    # +triggers_file+::    The file with the list of includes/excludes for
    #                      each test object
    #                      (default: #{work_directory}/triggers.yml)
    # +logger+::           The ruby logger object for logging
    #                      (default: disabled)
    def initialize(work_directory:, test_objects:, diff_file: nil, triggers_file: nil, logger: nil)
      @logger = logger
      @test_objects = test_objects
      @diff_file = diff_file || "#{work_directory}/#{DIFF_FILENAME}"
      @triggers_file = triggers_file || "#{work_directory}/#{TRIGGER_YAML}"

      @trigger_includes = []
      @trigger_excludes = []
    end

    # == Description
    #
    # Checks triggers.
    #
    def trigger?
      return true unless File.file?(@diff_file) && File.file?(@triggers_file)

      load_test_objects_triggers
      load_diff_files

      root_tr = root_trigger?
      sub_tr = subdir_trigger?
      @logger&.debug("Triggers results: root_trigger? = #{root_tr}, subdir_trigger? = #{sub_tr}")

      root_tr || sub_tr
    end

    private

    def load_test_objects_triggers
      @logger&.info('Loading diff checker trigger file')
      yaml = YAML.safe_load(File.read(@triggers_file))

      yaml.each do |key, value|
        if [*@test_objects, '*'].include?(key)
          @trigger_includes << value['include']
          @trigger_excludes << value['exclude']
        end
      end

      normalize_lists

      @logger&.debug("Loaded trigger includes: #{@trigger_includes}")
      @logger&.debug("Loaded trigger excludes: #{@trigger_excludes}")
    end

    def normalize_lists
      @trigger_includes.flatten!
      @trigger_includes.compact!
      @trigger_includes.uniq!

      @trigger_excludes.flatten!
      @trigger_excludes.compact!
      @trigger_excludes.uniq!
    end

    def check_trigger_file(trigger, line)
      if trigger[-1] == '/'
        # trigger is a directory
        # applying for all files
        line.start_with?(trigger)
      else
        # trigger is a file
        line == trigger
      end
    end

    def load_diff_files
      @logger&.info('Loading test objects diff file')

      @files = File.readlines(@diff_file, chomp: true)
      @logger&.debug("Loaded test objects diff files: #{@files}")

      @files_no_excludes = @files.reject do |line|
        @trigger_excludes.any? do |trigger|
          check_trigger_file(trigger, line)
        end
      end
      @logger&.debug("Test objects diff files w/o excludes: #{@files_no_excludes}")
    end

    def root_trigger?
      @logger&.debug('Processing root triggers')

      return false unless @trigger_includes.include?('/')

      @files_no_excludes.any? { |file| !file.include?('/') }
    end

    def subdir_trigger?
      @logger&.debug('Processing subdir triggers')

      @files_no_excludes.any? do |line|
        @trigger_includes.any? do |trigger|
          check_trigger_file(trigger, line)
        end
      end
    end
  end
end
