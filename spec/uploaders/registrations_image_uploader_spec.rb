# frozen_string_literal: true

RSpec.describe RegistrationsImageUploader, type: :image_uploader do
  include CarrierWave::Test::Matchers

  before { described_class.enable_processing = true }

  after { described_class.enable_processing = false }

  describe '#thumb' do
    let(:uploader) { described_class.new(User.new) }

    before { uploader.store!(File.open('spec/fixtures/default_image.png')) }

    it { expect(uploader.thumb).to have_dimensions(50, 28) }
  end

  describe '#extension_whitelist' do
    let(:uploader) { described_class.new(User.new(id: 1)) }

    it { expect(uploader.extension_allowlist).to eq %w[jpg jpeg gif png] }
  end

  describe '#store_dir' do
    let(:uploader) { described_class.new(User.new(id: 1)) }

    before { uploader.store!(File.open('spec/fixtures/default_image.png')) }

    it { expect(uploader.store_dir).to eq 'uploads/user/1' }
  end

  describe '#public_id' do
    let(:uploader) { described_class.new(User.new(id: 1)) }

    before { uploader.store!(File.open('spec/fixtures/default_image.png')) }

    I18n.transliterate("#{User.model_name.human.downcase}_#{Rails.env}_1")
    it { expect(uploader.public_id).to eq I18n.transliterate("#{User.model_name.human.downcase}_#{Rails.env}_1") }
  end
end
