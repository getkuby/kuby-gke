require 'kuby'
require 'kuby/gke/provider'

module Kuby
  module GKE
    autoload :Config,     'kuby/gke/config'
    autoload :Kubeconfig, 'kuby/gke/kubeconfig'
  end
end

Kuby.register_provider(:gke, Kuby::GKE::Provider)
