# frozen_string_literal: true

module Importers
  class SyncProductSource
    def initialize(product_source:)
      @product_source = product_source
    end

    def call
      file_path = Downloaders::SourceDownloader.new(
        product_source: @product_source
      ).call

      batch = ImporterFactory.build(
        product_source: @product_source,
        file_path: file_path
      ).call

      Downloaders::OldFilesCleaner.new.call

      batch
    end
  end
end
