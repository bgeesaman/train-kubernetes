require 'train'
require 'k8s-ruby'
require 'train-kubernetes/platform'

module TrainPlugins
  module TrainKubernetes
    class Connection < Train::Plugins::Transport::BaseConnection
      include TrainPlugins::TrainKubernetes::Platform

      def initialize(options)
        super(options)

        parse_kubeconfig
        connect
      end

      attr_accessor :client

      def connect
        @client.apis(prefetch_resources: true)
      rescue Excon::Error::Socket => e
        logger.error e.message
        exit
      end

      def uri
        "kubernetes://#{unique_identifier}"
      end

      def unique_identifier
        @client.transport.server.gsub(%r{(http|https)\:\/\/}, '') || 'default'
      end

      def parse_kubeconfig
        kubeconfig_file = @options[:kubeconfig] if @options[:kubeconfig]
        @client = K8s::Client.config(K8s::Config.load_file(File.expand_path(kubeconfig_file)))
      end
    end
  end
end
