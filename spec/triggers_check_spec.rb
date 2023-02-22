# frozen_string_literal: true

RSpec.describe TriggersCheck do
  triggers = 'spec/triggers_check_spec/triggers.yml'
  diffs = 'spec/triggers_check_spec/diff_*.txt'

  it 'has a version number' do
    expect(TriggersCheck::VERSION).not_to be_nil
  end

  Dir[diffs].each do |diff|
    name = File.basename(diff)
    name_parts = name.split('_')

    expect_res = name_parts[3].split('.')[0] == 'pass'
    drivers = [name_parts[2]]

    it name.to_s do
      dc = TriggersCheck::Checker.new(
        work_directory: '.', test_objects: drivers, diff_file: diff, triggers_file: triggers
      )
      expect(dc.trigger?).to eq(expect_res)
    end
  end
end
