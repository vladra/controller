module Lotus
  module Action
    module CacheControl

      # Cache-Control directives which have values
      #
      # @since 0.2.1
      # @api private
      VALUE_DIRECTIVES      = %i(max_age s_maxage min_fresh max_stale).freeze

      # Cache-Control directives which are implicitly true
      #
      # @since 0.2.1
      # @api private
      NON_VALUE_DIRECTIVES  = %i(public private no_cache no_store no_transform must_revalidate proxy_revalidate).freeze

      class ValueDirective
        attr_reader :name

        def initialize(name, value)
          @name, @value = name, value
        end

        def to_str
          "#{@name.to_s.tr('_', '-')}=#{value.to_i}"
        end

        def valid?
          VALUE_DIRECTIVES.include? @name
        end

        def value
          @value.is_a?(Time) ? @value - Time.now : @value
        end
      end

      class NonValueDirective
        attr_reader :name

        def initialize(name)
          @name = name
        end

        def to_str
          @name
        end

        def valid?
          NON_VALUE_DIRECTIVES.include? @name
        end
      end

      class Directives
        include Enumerable

        def initialize(*values)
          values.each do |directive_key|
            if directive_key.kind_of? Hash
              directive_key.each { |name, value| self.<< ValueDirective.new(name, value) }
            else
              self.<< NonValueDirective.new(directive_key)
            end
          end
        end

        def each
          @directives.each { |d| yield d }
        end

        def <<(directive)
          @directives ||= []
          @directives << directive if directive.valid?
        end

        def values
          @directives.delete_if do |directive|
            directive.name == :public && @directives.map(&:name).include?(:private)
          end
        end
      end
    end
  end
end
