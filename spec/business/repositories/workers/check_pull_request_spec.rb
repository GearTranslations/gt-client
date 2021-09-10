describe Repositories::Workers::CheckPullRequest do
  describe '#perform' do
    subject(:worker_result) { described_class.new.perform(pull_request.id) }

    let(:pull_request) { create :pull_request }
    let(:failure) { false }
    let(:error) { nil }

    before do
      allow(PullRequest).to receive(:find).and_return(pull_request)
      interactor_result = double(failure?: failure, error: error) # rubocop:disable RSpec/VerifiedDoubles
      allow(Repositories::Interactors::CheckPullRequest).to receive(:call)
        .and_return(interactor_result)
    end

    it 'calls interactor correctly' do
      worker_result
      expect(Repositories::Interactors::CheckPullRequest).to have_received(:call)
        .with({ pull_request: pull_request })
    end

    context 'when it fails' do
      let(:failure) { true }
      let(:error) { 'Pull request check status failed' }

      it 'raise exception' do
        expect { worker_result }.to raise_error(described_class::CheckPullRequestError)
      end
    end
  end
end
