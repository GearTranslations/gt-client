describe Repositories::Interactors::UploadFile do
  describe '.call' do
    subject(:interactor_result) do
      described_class.call(project: project, file: file_upload)
    end

    let(:repository) { project.repository }
    let(:client) do
      Bitbucket::Client.new(repository)
    end
    let(:project) { create :project, status: :finalized }

    let(:upload_response) { { status: 201, data: '' }.deep_symbolize_keys }
    let(:file_upload) do
      file = Tempfile.new
      content = <<~CONTENT
        {
          "reserve": "Reserve",
          "users": "Users",
          "games": "Games",
          "players": "Players"
        }
      CONTENT
      file.write(content)
      file.rewind
      file
    end
    let(:upload_path) { File.dirname(project.file_path) }
    let(:branch_source) { 'update-locale-1' }
    let(:file_name) { project.file_path.split('/').last }
    let(:commit_message) { "Update locale #{file_name} from gt-api-client" }

    before do
      allow_any_instance_of(described_class).to receive(:service).and_return(client)
      allow(client).to receive(:upload_file).and_return(upload_response)
    end

    it 'success' do
      expect(interactor_result).to be_success
    end

    it 'upload file' do
      interactor_result
      expect(client).to have_received(:upload_file)
        .with(branch_source, file_upload, upload_path, commit_message)
    end

    it 'add branch source to context' do
      expect(interactor_result.branch_source).to eq(branch_source)
    end

    it 'increment counter' do
      expect { interactor_result }.to change(repository, :branch_count).to(1)
    end

    context 'when fails upload file' do
      let(:error_message) do
        'The requested repository either does not exist or you do not have access.'
      end
      let(:upload_response) do
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
