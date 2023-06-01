$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'kuby/gke/version'

Gem::Specification.new do |s|
  s.name     = 'kuby-gke'
  s.version  = ::Kuby::GKE::VERSION
  s.authors  = ['Cameron Dutro']
  s.email    = ['camertron@gmail.com']
  s.homepage = 'http://github.com/getkuby/kuby-gke'

  s.description = s.summary = 'Google Kubernetes Engine (GKE) provider for Kuby.'

  s.platform = Gem::Platform::RUBY

  s.add_dependency 'kube-dsl', '~> 0.7'
  s.add_dependency 'google-cloud-container', '~> 1.3'
  s.add_dependency 'gke-auth-plugin-rb', '~> 0.1'
  s.add_dependency 'kubernetes-cli', '~> 0.5'

  s.require_path = 'lib'
  s.files = Dir['{lib,spec}/**/*', 'Gemfile', 'LICENSE', 'CHANGELOG.md', 'README.md', 'Rakefile', 'kuby-gke.gemspec']
end
