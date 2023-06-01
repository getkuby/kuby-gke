## kuby-gke

Google Kubernetes Engine (GKE) provider for [Kuby](https://github.com/getkuby/kuby-core).

## Intro

In Kuby parlance, a "provider" is an [adapter](https://en.wikipedia.org/wiki/Adapter_pattern) that enables Kuby to deploy apps to a specific cloud provider. In this case, we're talking about Google's [Cloud Platform](https://cloud.google.com/), specifically their managed Kubernetes offering, [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine) (GKE).

All providers adhere to a specific interface, meaning you can swap out one provider for another without having to change your code.

## Usage

Before you get started configuring Kuby, you'll need to create a cluster and service account for accessing said cluster. The service account should have owner-level permissions to be able to create cluster-level resources. The JSON credentials file mentioned below can be obtained by creating a key for the service account.

Enable the GKE provider like so:

```ruby
require 'kuby/gke'

Kuby.define('MyApp') do
  environment(:production) do
    kubernetes do

      provider :gke do
        # The ID of the GCP project that houses your cluster.
        project_id 'my-project-id'

        # The name of your cluster.
        cluster_name 'my-cluster-name'

        # The availability zone your cluster is in, eg. us-central1-a
        zone 'my-zone'

        # The path to a JSON file containing credentials for an actor
        # that has access to the cluster, most likely a service account.
        keyfile '/path/to/keyfile.json'
      end

    end
  end
end
```

Once configured, you should be able to run all the Kuby rake tasks as you would with any provider.

## License

Licensed under the MIT license. See LICENSE for details.

## Authors

* Cameron C. Dutro: http://github.com/camertron
