describe Repositories::Interactors::CheckPullRequest do
  describe '.call' do
    subject(:interactor_result) do
      described_class.call(pull_request: pull_request)
    end

    let(:status) { :open }
    let(:pull_request) { create :pull_request, status: status }
    let(:repository) { pull_request.locale_file.repository }
    let(:client) do
      Bitbucket::Client.new(repository)
    end
    let(:state) { 'MERGED' }

    let(:get_pull_request_response) do
      { status: 200,
        data: { state: state } }.deep_symbolize_keys
    end

    before do
      allow_any_instance_of(described_class).to receive(:service).and_return(client)
      allow(client).to receive(:get_pull_request).and_return(get_pull_request_response)
    end

    it 'return success' do
      expect(interactor_result).to be_success
    end

    it 'call pull request service' do
      interactor_result
      expect(client).to have_received(:get_pull_request)
        .with(pull_request.external_id)
    end

    it 'change pull request status' do
      expect { interactor_result }.to change(pull_request, :status).from('open').to('merged')
    end

    context 'when merge is still open' do
      let(:state) { 'OPEN' }

      it 'return success' do
        expect(interactor_result).to be_success
      end

      it 'not change pull request status' do
        expect { interactor_result }.not_to change(pull_request, :status)
      end
    end

    context 'when merge is declined' do
      let(:state) { 'DECLINED' }

      it 'return success' do
        expect(interactor_result).to be_success
      end

      it 'change pull request status' do
        expect { interactor_result }.to change(pull_request, :status).from('open').to('declined')
      end
    end

    context 'when pull request status is not open' do
      let(:status) { :merged }

      it 'return failure' do
        expect(interactor_result).to be_failure
      end
    end
  end
end
