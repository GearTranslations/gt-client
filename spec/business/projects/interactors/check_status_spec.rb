describe Projects::Interactors::CheckStatus do
  describe '.call' do
    subject(:interactor_result) do
      described_class.call(project: project)
    end

    let(:status) { :processing }
    let(:repository) { project.repository }
    let(:project) { create :project, status: status }
    let(:response) do
      json_fixture('/projects/check_status/in_process.json').deep_symbolize_keys
    end
    let(:client) { GearTranslation::Client.new('access_token') }

    before do
      allow_any_instance_of(described_class).to receive(:service).and_return(client)
      allow(client).to receive(:project_status)
        .and_return(response)
    end

    it 'success' do
      expect(interactor_result).to be_success
    end

    it 'check status' do
      interactor_result
      expect(client).to have_received(:project_status).with(project.external_id)
    end

    context 'when status is in process' do
      it 'do not change status' do
        expect { interactor_result }.not_to change(project, :status)
      end
    end

    context 'when the state is finished' do
      let(:response) do
        json_fixture('/projects/check_status/finished.json').deep_symbolize_keys
      end

      it 'change status to finalized' do
        expect { interactor_result }.to change(project, :status).from('processing').to('finalized')
      end

      it 'enqueue create pull request job' do
        expect { interactor_result }.to change(Repositories::Workers::CreatePullRequest.jobs, :size)
          .to(1)
      end
    end

    context 'when fails check project status' do
      let(:response) do
        json_fixture('/projects/check_status/bad_request.json').deep_symbolize_keys
      end

      it 'failure' do
        expect(interactor_result).to be_failure
      end

      it 'error' do
        expect(interactor_result.error).to match("Couldn't find Subproject")
      end
    end

    context 'when project is invalid' do
      let(:status) { :open }

      it 'failure' do
        expect(interactor_result).to be_failure
      end

      it 'validate project status' do
        expect(interactor_result.error).to eq('project is not processing')
      end
    end
  end
end
