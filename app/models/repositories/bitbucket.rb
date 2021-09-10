module Repositories
  class Bitbucket < Repository
    validate :valid_metadata

    class ApiMetadata
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Serializers::JSON
      include JsonAttributeSerializer

      ATTRIBUTE_ENCODING_KEY = Rails.application.secrets.attribute_encoding_key

      extend AttrEncrypted
      attr_encrypted :app_password, key: ATTRIBUTE_ENCODING_KEY, encode: 'M'

      attribute :encrypted_app_password, :string
      attribute :encrypted_app_password_iv, :string
      attribute :user_name, :string
      attribute :branch_pull_request_destination, :string
      attribute :server_url, :string

      validates :user_name, :app_password, :branch_pull_request_destination, :server_url,
                presence: true
    end

    delegate :app_password, :user_name, :branch_pull_request_destination, :server_url, to: :metadata

    serialize :metadata, ApiMetadata

    def scan
      Repositories::Interactors::Bitbucket::Scan.call(repository: self)
    end

    private

    def valid_metadata
      errors.add(:metadata, metadata.errors.full_messages.join(',')) unless metadata.valid?
    end
  end
end
