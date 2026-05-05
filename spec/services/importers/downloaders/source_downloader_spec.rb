# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importers::Downloaders::SourceDownloader do
  describe '#call' do
    let(:product_source) do
      ProductSource.new(
        name: 'Test XML',
        url: 'https://example.com/feed.xml'
      )
    end

    let(:dir) { Rails.root.join('tmp/imports') }
    let(:file_content) { '<xml>test</xml>' }
    let(:fake_io) { StringIO.new(file_content) }
    let(:response) do
      instance_double(Net::HTTPSuccess, body: file_content)
    end

    before do
      FileUtils.rm_rf(dir)
      FileUtils.mkdir_p(dir)

      allow(Net::HTTP).to receive(:start).and_return(response)
      allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
    end

    after do
      FileUtils.rm_rf(dir)
    end

    it 'downloads file and saves it to tmp/imports' do
      path = described_class.new(product_source:).call

      expect(File).to exist(path)
      expect(File.read(path)).to eq(file_content)
    end

    it 'returns path to saved file' do
      path = described_class.new(product_source:).call

      expect(path).to include('tmp/imports')
      expect(path).to end_with('.xml')
    end

    it 'uses source name in filename' do
      path = described_class.new(product_source:).call

      expect(File.basename(path)).to include('test-xml')
    end

    it 'raises error if download fails' do
      failed_response = instance_double(
        Net::HTTPNotFound,
        code: '404',
        message: 'Not Found',
        body: 'Not found'
      )

      allow(Net::HTTP).to receive(:start).and_return(failed_response)
      allow(failed_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)

      expect do
        described_class.new(product_source:).call
      end.to raise_error(RuntimeError, 'Download failed: 404 Not Found')
    end
  end
end
