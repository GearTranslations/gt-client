describe LocaleFile do
  subject(:locale_file) do
    build :locale_file
  end

  it { is_expected.to validate_presence_of(:name) }

  context 'when it is validated that it is unique' do
    let(:dup) { locale_file.dup }

    before do
      locale_file.save
    end

    it 'do not save' do
      expect(dup.save).to be_falsey
    end
  end
end
