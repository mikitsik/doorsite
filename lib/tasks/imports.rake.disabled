# frozen_string_literal: true

require 'net/http'
require 'fileutils'

MAGNA_IMPORT_URL = 'https://dverimagna.by/wp-content/uploads/feed-yml-0.xml'
ELPORTA_IMPORT_URL = 'https://elporta.by/business/export/xml'

namespace :imports do
  desc 'Download XML files, reset products, and import catalog'
  task reset_local: :environment do
    prepare_import_files
    reset_catalog
    import_sources
    print_stats
  end

  def prepare_import_files
    FileUtils.mkdir_p(imports_dir)

    puts 'Downloading Magna XML...'
    download_xml(MAGNA_IMPORT_URL, magna_file)

    puts 'Downloading Elporta XML...'
    download_xml(ELPORTA_IMPORT_URL, elporta_file)
  end

  def reset_catalog
    puts 'Cleaning products...'

    Product.delete_all
    ImportBatch.delete_all
  end

  def import_sources
    import_source(
      name: 'Magna XML',
      source_type: 'yml',
      file_path: magna_file.to_s
    )

    import_source(
      name: 'Elporta XML',
      source_type: 'xml',
      file_path: elporta_file.to_s
    )
  end

  def import_source(name:, source_type:, file_path:)
    source = ProductSource.find_or_create_by!(name:)

    source.update!(
      source_type:,
      url: file_path,
      enabled: true,
      sync_strategy: 'manual',
      settings: {}
    )

    puts "Importing #{name}..."

    Importers::ImporterFactory.build(
      product_source: source,
      file_path:
    ).call
  end

  def print_stats
    puts
    puts "Products: #{Product.count}"

    puts
    puts 'By catalog_section:'
    pp Product.group(:catalog_section).count

    puts
    puts 'By door_type:'
    pp Product.group(:door_type).count

    puts
    puts 'Broken hardware + entrance:'

    pp Product.where(catalog_section: 'hardware', door_type: 'entrance')
              .limit(20)
              .pluck(:id, :title, :collection, :category)
  end

  def download_xml(url, file_path)
    uri = URI.parse(url)

    request = Net::HTTP::Get.new(uri)
    request['User-Agent'] = 'DoorSiteBot/1.0 (+https://дверной.бел)'

    response = Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: uri.scheme == 'https'
    ) do |http|
      http.request(request)
    end

    raise "Failed to download #{url}" unless response.is_a?(Net::HTTPSuccess)

    File.binwrite(file_path, response.body)
  end

  def imports_dir
    Rails.root.join('tmp/imports')
  end

  def magna_file
    imports_dir.join('magna.xml')
  end

  def elporta_file
    imports_dir.join('elporta.xml')
  end
end
