# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'fileutils'

module Importers
  module Downloaders
    class SourceDownloader
      USER_AGENT = 'DoorSiteBot/1.0 (+https://дверной.бел)'

      def initialize(product_source:)
        @product_source = product_source
      end

      def call
        FileUtils.mkdir_p(imports_dir)

        file_path = imports_dir.join(file_name)

        uri = URI.parse(@product_source.url)

        response = Net::HTTP.start(
          uri.host,
          uri.port,
          use_ssl: uri.scheme == 'https',
          open_timeout: 20,
          read_timeout: 60
        ) do |http|
          request = Net::HTTP::Get.new(uri)
          request['User-Agent'] = USER_AGENT

          http.request(request)
        end

        raise "Download failed: #{response.code} #{response.message}" unless response.is_a?(Net::HTTPSuccess)

        File.binwrite(file_path, response.body)

        file_path.to_s
      end

      private

      def imports_dir
        Rails.root.join('tmp/imports')
      end

      def file_name
        "#{@product_source.name.parameterize}_#{Time.current.strftime('%Y%m%d_%H%M%S')}.xml"
      end
    end
  end
end
