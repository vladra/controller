module Lotus
  module Action
    # Language utilities
    #
    # This module must be included by developers.
    #
    # @since x.x.x
    module Language
      # The Rack env key for HTTP Accept-Language header
      #
      # @since x.x.x
      # @api private
      #
      # @see Lotus::Action::Rack#language
      # @see Lotus::Action::Rack#accept_language?
      HTTP_ACCEPT_LANGUAGE = 'HTTP_ACCEPT_LANGUAGE'.freeze

      # The Rack env key for HTTP Accept-Language header
      #
      # @since x.x.x
      # @api private
      #
      # @see Lotus::Action::Rack#language
      # @see Lotus::Action::Rack#accept_language?
      #
      # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html
      HTTP_ACCEPT_ALL_LANGUAGES = '*'.freeze

      private
      # Return the first accepted language code
      #
      # @return [String] a language code
      #
      # @since x.x.x
      #
      # @see Lotus::Controller::Configuration#default_language
      #
      # @example Accept-Language is present
      #   require 'lotus/controller'
      #   require 'lotus/action/language'
      #
      #   module Dashboard
      #     class Index
      #       include Lotus::Action
      #       include Lotus::Action::Language
      #
      #       def call(params)
      #         self.body = language
      #       end
      #     end
      #   end
      #
      #   # GET / 'HTTP_ACCEPT_LANGUAGE' => 'da, en;q=0.6'
      #   # 200 OK
      #   # "da"
      #
      # @example Accept-Language is wildcard or missing
      #   require 'lotus/controller'
      #   require 'lotus/action/language'
      #
      #   module Dashboard
      #     class Index
      #       include Lotus::Action
      #       include Lotus::Action::Language
      #
      #       def call(params)
      #         configuration.default_language # => "en"
      #         self.body = language
      #       end
      #     end
      #   end
      #
      #   # GET / 'HTTP_ACCEPT_LANGUAGE' => '*'
      #   # 200 OK
      #   # "en"
      def language
        languages.first || configuration.default_language
      end

      # Check if the given language is supported
      #
      # @return [String] a language code
      #
      # @since x.x.x
      #
      # @example Accept-Language is present
      #   require 'lotus/controller'
      #   require 'lotus/action/language'
      #
      #   module Dashboard
      #     class Index
      #       include Lotus::Action
      #       include Lotus::Action::Language
      #
      #       def call(params)
      #         headers['X-Accept-DA'] = accept_language?('da').to_s
      #         headers['X-Accept-EN'] = accept_language?('en').to_s
      #         headers['X-Accept-FR'] = accept_language?('fr').to_s
      #
      #         self.body = 'Hello'
      #       end
      #     end
      #   end
      #
      #   # GET / 'HTTP_ACCEPT_LANGUAGE' => 'da, en;q=0.6'
      #   # 200 OK
      #   # "Hello"
      #   #
      #   # X-Accept-DA: true
      #   # X-Accept-EN: true
      #   # X-Accept-FR: false
      #
      # @example Accept-Language is wildcard or missing
      #   require 'lotus/controller'
      #   require 'lotus/action/language'
      #
      #   module Dashboard
      #     class Index
      #       include Lotus::Action
      #       include Lotus::Action::Language
      #
      #       def call(params)
      #         headers['X-Accept-DA'] = accept_language?('da').to_s
      #         headers['X-Accept-EN'] = accept_language?('en').to_s
      #         headers['X-Accept-FR'] = accept_language?('fr').to_s
      #
      #         self.body = 'Hello'
      #       end
      #     end
      #   end
      #
      #   # GET / 'HTTP_ACCEPT_LANGUAGE' => '*'
      #   # 200 OK
      #   # "Hello"
      #   #
      #   # X-Accept-DA: true
      #   # X-Accept-EN: true
      #   # X-Accept-FR: true
      def accept_language?(language)
        return true if languages.empty?
        languages.include?(language)
      end

      # Return a list of ordered accepted languages
      #
      # @return [Array<String>] the accepted languages
      #
      # @since x.x.x
      # @api private
      def languages
        @languages ||=
          if (langs = @_env[HTTP_ACCEPT_LANGUAGE]) == HTTP_ACCEPT_ALL_LANGUAGES
            []
          else
            ::Rack::Utils.q_values(langs).collect { |(lang, _)| lang }
          end
      end
    end
  end
end
