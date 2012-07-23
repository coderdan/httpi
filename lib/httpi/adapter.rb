require "httpi/adapter/httpclient"
require "httpi/adapter/curb"
require "httpi/adapter/net_http"
require "httpi/adapter/em_http"

module HTTPI

  # = HTTPI::Adapter
  #
  # Manages the adapter classes. Currently supports:
  #
  # * httpclient
  # * curb
  # * net/http
  module Adapter

    ADAPTERS = {
      :httpclient => { :class => HTTPClient,    :require => ["httpclient"] },
      :curb       => { :class => Curb,          :require => ["curb"] },
      :net_http   => { :class => NetHTTP,       :require => ["net/https"] },
      :em_http    => { :class => EmHttpRequest, :require => ["fiber", "em-synchrony/em-http", "em-http"] }
    }

    LOAD_ORDER = [:httpclient, :curb, :em_http, :net_http]

    class << self

      def use=(adapter)
        return @adapter = nil if adapter.nil?

        validate_adapter! adapter
        load_adapter adapter
        @adapter = adapter
      end

      def use
        @adapter ||= default_adapter
      end

      def load(adapter)
        adapter = adapter ? validate_adapter!(adapter) : use
        [adapter, ADAPTERS[adapter][:class]]
      end

    private

      def validate_adapter!(adapter)
        raise ArgumentError, "Invalid HTTPI adapter: #{adapter}" unless ADAPTERS[adapter]
        adapter
      end

      def default_adapter
        LOAD_ORDER.each do |adapter|
          begin
            load_adapter adapter
            return adapter
          rescue LoadError
            next
          end
        end
      end

      def load_adapter(adapter)
        ADAPTERS[adapter][:require].each { |r| require r }
      end

    end
  end
end
