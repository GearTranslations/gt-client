describe Projects::Interactors::Create do
  describe '.call' do
    subject(:interactor_result) do
      described_class.call(project: project, file: file_to_translate)
    end

    let(:repository) { project.repository }
    let(:project) { create :project, status: status }
    let(:response) do
      json_fixture('/projects/ok.json').deep_symbolize_keys
    end
    let(:file_to_translate) do
      file = Tempfile.new
      content = <<~CONTENT
        {
          "reserve": "Reserve",
          "users": "Users",
          "games": "Juegos",
          "players": "Jugadores"
        }
      CONTENT
      file.write(content)
      file.rewind
      file
    end
    let(:status) { :open }
    let(:client) { GearTranslation::Client.new('access_token') }

    before do
      allow_any_instance_of(described_class).to receive(:service).and_return(client)
      allow(client).to receive(:create_project)
        .and_return(response)
    end

    it 'success' do
      expect(interactor_result).to be_success
    end

    it 'set external_id' do
      interactor_result
      expect(project.reload.external_id).to eq('18245')
    end

    it 'change status from open to processing' do
      expect { interactor_result }.to change(project, :status).from('open').to('processing')
    end

    context 'when fails create project' do
      let(:response) do
        json_fixture('/projects/bad_request.json').deep_symbolize_keys
      end

      it 'failure' do
        expect(interactor_result).to be_failure
      end

      it 'do not set external_id' do
        interactor_result
        expect(project.reload.external_id).to eq(nil)
      end

      it 'change status to failed' do
        interactor_result
        expect(project.reload.status).to eq('failed')
      end
    end

    context 'when project status is not open' do
      let(:status) { :processing }

      it 'failure' do
        expect(interactor_result).to be_failure
      end

      it 'error message' do
        expect(interactor_result.error).to eq('project is not open')
      end
    end

    context 'when invalid parameter file' do
      let(:file_to_translate) { nil }

      it 'failure' do
        expect(interactor_result).to be_failure
      end

      it 'error message' do
        expect(interactor_result.error).to eq('missing file')
      end
    end

    context 'when invalid parameter project' do
      let(:project) { nil }

      it 'failure' do
        expect(interactor_result).to be_failure
      end

      it 'error message' do
        expect(interactor_result.error).to eq('missing project')
      end
    end

    context 'when connection error' do
      before do
        allow(client).to receive(:create_project)
          .and_raise(HTTP::ConnectionError)
      end

      it 'failure' do
        expect(interactor_result).to be_failure
      end

      it 'do not set external_id' do
        interactor_result
        expect(project.reload.external_id).to eq(nil)
      end

      it 'change status to failed' do
        interactor_result
        expect(project.reload.status).to eq('failed')
      end
    end
  end
end
