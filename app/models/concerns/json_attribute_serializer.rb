module JsonAttributeSerializer
  extend ActiveSupport::Concern

  class_methods do
    def load(json_object)
      json_object.present? ? new(json_object) : new
    end

    def dump(serialized_object)
      serialized_object.as_json
    end
  end
end
