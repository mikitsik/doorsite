# frozen_string_literal: true

module Importers
  module Downloaders
    class OldFilesCleaner
      DEFAULT_KEEP_DAYS = 14

      def initialize(dir: Rails.root.join('tmp/imports'), keep_days: DEFAULT_KEEP_DAYS)
        @dir = Pathname(dir)
        @keep_days = keep_days
      end

      def call
        return 0 unless @dir.exist?

        deleted = 0
        threshold = @keep_days.days.ago

        @dir.glob('*.xml').each do |file|
          next unless file.file?
          next unless file.mtime < threshold

          file.delete
          deleted += 1
        end

        deleted
      end
    end
  end
end
