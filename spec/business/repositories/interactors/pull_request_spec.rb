describe Repositories::Interactors::PullRequest do
  describe '.call' do
    subject(:interactor_result) do
      described_class.call(project: project, branch_source: branch_source)
    end

    let(:repository) { project.repository }
    let(:client) do
      Bitbucket::Client.new(repository)
    end
    let(:project) { create :project, status: :finalized }
    let(:locale_file) { project.locale_file }

    let(:pull_request_response) do
      { status: 201,
        data: { id: 11 } }.deep_symbolize_keys
    end
    let(:file_name) { project.file_path.split('/').last }
    let(:title) { "Update locale #{file_name}" }
    let(:branch_destination) { repository.branch_pull_request_destination }
    let(:branch_source) { 'branch_source' }
    let(:pull_request) { PullRequest.find_by(locale_file_id: locale_file.id) }

    before do
      allow_any_instance_of(described_class).to receive(:service).and_return(client)
      allow(client).to receive(:create_pull_request).and_return(pull_request_response)
    end

    it 'success' do
      expect(interactor_result).to be_success
    end

    it 'call pull request service' do
      interactor_result
      expect(client).to have_received(:create_pull_request)
        .with(title, branch_destination, branch_source)
    end

    it 'create pull request' do
      expect { interactor_result }.to change(PullRequest, :count).by(1)
    end

    it 'sets external_id' do
      interactor_result
      expect(pull_request.external_id).to eq('11')
    end

    it 'sets status to open' do
      interactor_result
      expect(pull_request.status).to eq('open')
    end

    context 'when fails create pull request' do
      let(:error_message) do
        'The requested repository either does not exist or you do not have access.'
      end
      let(:pull_request_response) do
        { status: 404,
          data: {
            type: 'error',
            error: {
              message: error_message
            }
          } }.deep_symbolize_keys
      end

      it 'failure' do
        expect(interactor_result).to be_failure
      end

      it 'error message' do
        expect(interactor_result.error).to eq(error_message)
      end
    end
  end
end
