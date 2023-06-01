require 'gke-auth-plugin-rb'

module Kuby
  module GKE
    class Kubeconfig
      attr_reader :project_id, :cluster_name, :zone, :endpoint, :ca_cert

      def self.from(config:, cluster_def:)
        new(
          project_id: config.project_id,
          cluster_name: config.cluster_name,
          zone: config.zone,
          endpoint: cluster_def['endpoint'],
          ca_cert: cluster_def['master_auth']['cluster_ca_certificate']
        )
      end

      def initialize(project_id:, cluster_name:, zone:, endpoint:, ca_cert:)
        @project_id = project_id
        @cluster_name = cluster_name
        @zone = zone
        @endpoint = endpoint
        @ca_cert = ca_cert
      end

      def generate
        {
          "apiVersion" => "v1",
          "kind" => "Config",
          "clusters" => clusters,
          "contexts" => contexts,
          "current-context" => id_triple,
          "preferences" => {},
          "users" => users
        }
      end

      private

      def clusters
        [{
          "cluster" => {
            "certificate-authority-data" => ca_cert,
            "server" => "https://#{endpoint}"
          },
          "name" => id_triple
        }]
      end

      def contexts
        [{
          "context" => {
            "cluster" => id_triple,
            "user" => id_triple
          },
          "name" => id_triple
        }]
      end

      def users
        [{
          "name" => id_triple,
          "user" => {
            "exec" => {
              "apiVersion" => "client.authentication.k8s.io/v1beta1",
              "command" => GKEAuthPluginRb.executable,
              "provideClusterInfo" => true,
              "interactiveMode" => "Never"
            }
          }
        }]
      end

      def id_triple
        @id_triple ||= "#{project_id}_#{zone}_#{cluster_name}"
      end
    end
  end
end
