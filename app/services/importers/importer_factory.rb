# frozen_string_literal: true

module Importers
  class ImporterFactory
    def self.build(product_source:, file_path:)
      new(product_source:, file_path:).build
    end

    def initialize(product_source:, file_path:)
      @product_source = product_source
      @file_path = file_path
    end

    def build
      case @product_source.source_type
      when 'xml', 'yml'
        build_xml
      when 'csv'
        raise NotImplementedError, 'CSV importer is not implemented'
      when 'json'
        raise NotImplementedError, 'JSON importer is not implemented'
      else
        raise ArgumentError, "Unsupported source_type: #{@product_source.source_type}"
      end
    end

    private

    def build_xml
      doc = Nokogiri::XML(File.read(@file_path))

      if doc.at_css('yml_catalog')
        Importers::Xml::YmlImporter.new(product_source: @product_source, file_path: @file_path)
      elsif doc.css('catalog products product').any?
        Importers::Xml::ElportaImporter.new(product_source: @product_source, file_path: @file_path)
      else
        raise ArgumentError, 'Unknown XML format'
      end
    end
  end
end
