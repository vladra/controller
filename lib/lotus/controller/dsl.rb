module Lotus
  module Controller
    # Public DSL
    #
    # @since 0.1.0
    module Dsl
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # Define an action for the given name.
        # It generates a concrete class for the action, for this reason the name
        # MUST be a valid name for Ruby.
        #
        # @param name [String] the name of the action
        # @param blk [Proc] the code of the action
        #
        # @raise TypeError when the name isn't a valid Ruby name
        #
        # @since 0.1.0
        #
        # @example
        #   require 'lotus/controller'
        #
        #   class ArticlesController
        #     include Lotus::Controller
        #
        #     action 'Index' do
        #       def call(params)
        #         # ...
        #       end
        #     end
        #
        #     action 'Show' do
        #       def call(params)
        #         # ...
        #       end
        #     end
        #   end
        def action(name, &blk)
          const_set(name, Class.new)

          const_get(name).tap do |klass|
            klass.class_eval { include ::Lotus::Action }
            klass.class_eval(&blk)

            shares.each do |code|
              klass.class_eval(&code)
            end
          end
        end

        # Share behaviors across actions.
        #
        # Often a controller exposes a set of similar actions that needs similar
        # behaviors.
        def share(&blk)
          shares.push(blk)
        end

        private
        def shares
          @shares ||= Array.new
        end
      end
    end
  end
end
