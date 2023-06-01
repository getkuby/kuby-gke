require 'fileutils'
require 'google/cloud/container'
require 'google/cloud/container/v1'
require 'tmpdir'
require 'yaml'

module Kuby
  module GKE
    class Provider < Kuby::Kubernetes::Provider
      STORAGE_CLASS_NAME = 'default'.freeze

      attr_reader :config

      def configure(&block)
        config.instance_eval(&block)
      end

      def kubeconfig_path
        File.join(
          kubeconfig_dir,
          "#{environment.app_name.downcase}-#{config.hash_value}-kubeconfig.yaml"
        )
      end

      def storage_class_name
        STORAGE_CLASS_NAME
      end

      def kubernetes_cli
        @kubernetes_cli ||= begin
          refresh_kubeconfig

          super.tap do |cli|
            cli.env['GOOGLE_APPLICATION_CREDENTIALS'] = config.keyfile
          end
        end
      end

      def deploy
        with_env({ 'GOOGLE_APPLICATION_CREDENTIALS' => config.keyfile }) do
          super
        end
      end

      private

      def after_initialize
        @config = Config.new
        @kubeconfig_refreshed = false
      end

      def client
        @client ||= Google::Cloud::Container.cluster_manager do |client_config|
          client_config.credentials = config.keyfile
        end
      end

      def refresh_kubeconfig
        return unless should_refresh_kubeconfig?

        FileUtils.mkdir_p(kubeconfig_dir)

        Kuby.logger.info('Refreshing kubeconfig...')

        request = Google::Cloud::Container::V1::GetClusterRequest.new(
          name: "projects/#{config.project_id}/locations/#{config.zone}/clusters/#{config.cluster_name}"
        )

        cluster = client.get_cluster(request)
        kubeconfig = Kubeconfig.from(config: config, cluster_def: cluster)

        File.write(kubeconfig_path, YAML.dump(kubeconfig.generate))

        @kubeconfig_refreshed = true

        Kuby.logger.info('Successfully refreshed kubeconfig!')
      end

      def should_refresh_kubeconfig?
        return false if @kubeconfig_refreshed
        !File.exist?(kubeconfig_path) || !can_communicate_with_cluster?
      end

      def can_communicate_with_cluster?
        cli = ::KubernetesCLI.new(kubeconfig_path)
        cli.env['GOOGLE_APPLICATION_CREDENTIALS'] = config.keyfile
        cli.send(:backticks, [cli.executable, '--kubeconfig', kubeconfig_path, 'get', 'ns'])
        cli.last_status.success?
      end

      def kubeconfig_dir
        @kubeconfig_dir ||= File.join(
          Dir.tmpdir, 'kuby-gke'
        )
      end

      def with_env(new_env)
        old_env = ENV.to_h
        ENV.replace(old_env.merge(new_env))
        yield
      ensure
        ENV.replace(old_env)
      end
    end
  end
end
