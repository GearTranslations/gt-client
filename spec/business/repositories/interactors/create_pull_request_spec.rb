describe Repositories::Interactors::CreatePullRequest do
  describe '.call' do
    subject(:interactor_result) do
      described_class.call(project: project)
    end

    let(:content_translated_file) do
      <<~CONTENT
        {
          "reserve": "Reserve",
          "users": "Users",
          "games": "Games",
          "players": "Players"
        }
      CONTENT
    end

    let(:response_translated_file) do
      { 'status' => 200, 'data' => content_translated_file }.deep_symbolize_keys
    end

    let(:repository) { project.repository }
    let(:project) { create :project, status: :finalized }
    let(:client) { Bitbucket::Client.new(repository) }
    let(:client_gt) { GearTranslation::Client.new('access_token') }
    let(:response) do
      { status: 201, data: { id: Faker::IDNumber.brazilian_id } }.deep_symbolize_keys
    end

    before do
      allow(client).to receive(:upload_file).and_return(response)
      allow(client).to receive(:create_pull_request).and_return(response)
      allow(client_gt).to receive(:translated_file)
        .and_return(response_translated_file)
      allow_any_instance_of(Repositories::Interactors::UploadFile).to receive(:service)
        .and_return(client)
      allow_any_instance_of(Repositories::Interactors::PullRequest).to receive(:service)
        .and_return(client)
      allow_any_instance_of(Projects::Interactors::GetTranslatedFile).to receive(:service)
        .and_return(client_gt)
    end

    it 'return success' do
      expect(interactor_result).to be_success
    end

    context 'when create pull request fails' do
      let(:response) do
        { status: 400,
          data: {
            type: 'error',
            error: {
              message: 'error message'
            }
          } }.deep_symbolize_keys
      end

      it 'return not success' do
        expect(interactor_result).not_to be_success
      end
    end
  end
end
