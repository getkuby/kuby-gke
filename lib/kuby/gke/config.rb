require 'kube-dsl'
require 'digest'

module Kuby
  module GKE
    class Config
      extend ::KubeDSL::ValueFields

      value_fields :project_id, :cluster_name, :zone, :keyfile

      def hash_value
        keyfile_hash = Digest::SHA256.hexdigest(
          File.exist?(keyfile) ? File.read(keyfile) : ""
        )

        parts = [project_id, cluster_name, zone, keyfile, keyfile_hash]
        Digest::SHA256.hexdigest(parts.join(':'))
      end
    end
  end
end
