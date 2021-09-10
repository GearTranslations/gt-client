describe Repositories::Interactors::GetFile do
  describe '.call' do
    subject(:interactor_result) do
      described_class.call(project: project)
    end

    let(:repository) { project.repository }
    let(:client) do
      Bitbucket::Client.new(repository)
    end
    let(:project) { create :project, status: :open }
    let(:content) do
      <<~CONTENT
        {
          "reserve": "Reserve",
          "users": "Users",
          "games": "Juegos",
          "players": "Jugadores"
        }
      CONTENT
    end
    let(:response) { { status: 200, data: content }.deep_symbolize_keys }

    before do
      allow_any_instance_of(described_class).to receive(:service).and_return(client)
      allow(client).to receive(:file).and_return(response)
    end

    it 'success' do
      expect(interactor_result).to be_success
    end

    it 'get file' do
      interactor_result
      expect(client).to have_received(:file)
        .with(repository.branch, project.file_path)
    end

    it 'add file context' do
      expect(interactor_result.file).to be_present
      expect(interactor_result.file.class).to eq(File)
    end
  end
end
