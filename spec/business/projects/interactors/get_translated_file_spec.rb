describe Projects::Interactors::GetTranslatedFile do
  describe '.call' do
    subject(:interactor_result) do
      described_class.call(project: project)
    end

    let(:status) { :finalized }
    let(:repository) { project.repository }
    let(:project) { create :project, status: status }
    let(:content) do
      <<~CONTENT
        {
          "reserve": "Reserve",
          "users": "Users",
          "games": "Games",
          "players": "Players"
        }
      CONTENT
    end
    let(:response) { { status: 200, data: content }.deep_symbolize_keys }
    let(:client) { GearTranslation::Client.new('access_token') }

    before do
      allow_any_instance_of(described_class).to receive(:service).and_return(client)
      allow(client).to receive(:translated_file)
        .and_return(response)
    end

    it 'success' do
      expect(interactor_result).to be_success
    end

    it 'get file' do
      interactor_result
      expect(client).to have_received(:translated_file)
        .with(project.external_id)
    end

    it 'add file to context' do
      expect(interactor_result.file).to be_present
      expect(interactor_result.file.class).to eq(File)
    end

    context 'when fails get translated file' do
      let(:response) do
        { status: 400,
          data: { error: "Couldn't find Subproject with 'id'=18252" } }.deep_symbolize_keys
      end

      it 'failure' do
        expect(interactor_result).to be_failure
      end
    end
  end
end
