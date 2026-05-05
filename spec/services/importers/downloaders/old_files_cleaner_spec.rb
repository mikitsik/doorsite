# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importers::Downloaders::OldFilesCleaner do
  describe '#call' do
    let(:dir) { Rails.root.join('tmp/spec_imports_cleaner') }

    before do
      FileUtils.rm_rf(dir)
      FileUtils.mkdir_p(dir)
    end

    after do
      FileUtils.rm_rf(dir)
    end

    it 'deletes xml files older than keep_days' do
      old_file = dir.join('old.xml')
      File.write(old_file, '<xml/>')
      File.utime(20.days.ago.to_time, 20.days.ago.to_time, old_file)

      deleted = described_class.new(dir:, keep_days: 14).call

      expect(deleted).to eq(1)
      expect(old_file).not_to exist
    end

    it 'keeps recent xml files' do
      recent_file = dir.join('recent.xml')
      File.write(recent_file, '<xml/>')
      File.utime(2.days.ago.to_time, 2.days.ago.to_time, recent_file)

      deleted = described_class.new(dir:, keep_days: 14).call

      expect(deleted).to eq(0)
      expect(recent_file).to exist
    end

    it 'does not delete non-xml files' do
      old_log = dir.join('old.log')
      File.write(old_log, 'log')
      File.utime(20.days.ago.to_time, 20.days.ago.to_time, old_log)

      deleted = described_class.new(dir:, keep_days: 14).call

      expect(deleted).to eq(0)
      expect(old_log).to exist
    end

    it 'returns zero when directory does not exist' do
      missing_dir = Rails.root.join('tmp/missing_imports_cleaner_dir')

      deleted = described_class.new(dir: missing_dir, keep_days: 14).call

      expect(deleted).to eq(0)
    end
  end
end
