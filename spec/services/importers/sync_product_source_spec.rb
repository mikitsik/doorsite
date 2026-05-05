# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importers::SyncProductSource do
  describe '#call' do
    let(:product_source) do
      ProductSource.create!(
        name: 'Magna XML',
        source_type: 'yml',
        url: 'https://example.com/feed.xml',
        enabled: true,
        sync_strategy: 'scheduled',
        settings: {}
      )
    end

    let(:downloader) { instance_double(Importers::Downloaders::SourceDownloader, call: '/tmp/feed.xml') }
    let(:importer) { instance_double(Importers::Xml::YmlImporter, call: batch) }
    let(:cleaner) { instance_double(Importers::Downloaders::OldFilesCleaner, call: 2) }
    let(:batch) { instance_double(ImportBatch) }

    before do
      allow(Importers::Downloaders::SourceDownloader)
        .to receive(:new)
        .with(product_source:)
        .and_return(downloader)

      allow(Importers::ImporterFactory)
        .to receive(:build)
        .with(product_source:, file_path: '/tmp/feed.xml')
        .and_return(importer)

      allow(Importers::Downloaders::OldFilesCleaner)
        .to receive(:new)
        .and_return(cleaner)
    end

    it 'downloads source, imports file and cleans old files' do
      result = described_class.new(product_source:).call

      expect(result).to eq(batch)
      expect(downloader).to have_received(:call)
      expect(importer).to have_received(:call)
      expect(cleaner).to have_received(:call)
    end
  end
end
