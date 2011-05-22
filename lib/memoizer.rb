module Memoizer
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    attr_accessor :_memoizer_methods

    def memoize(*method_names)
      @_memoizer_methods ||= []

      method_names.each do |method_name|
        # save method names in class constant
        @_memoizer_methods << method_name.to_sym

        memoized_ivar_name = "_memoized_#{method_name}"
        aliased_original_method_name = "_unmemoized_#{method_name}"
        attr_accessor memoized_ivar_name
        alias_method aliased_original_method_name, method_name

        no_args = self.instance_method(aliased_original_method_name).arity == 0
        is_private = self.private_method_defined?(aliased_original_method_name)
        is_protected = self.protected_method_defined?(aliased_original_method_name)

        define_method method_name do |*args|
          memoized_value = self.instance_variable_get("@#{memoized_ivar_name}")

          # if the method takes no inputs, store the value in an array
          if no_args
            if !memoized_value.is_a?(Array)
              memoized_value = [self.send("_unmemoized_#{method_name}")]
              self.instance_variable_set("@#{memoized_ivar_name}", memoized_value)
            end
            memoized_value.first

          #otherwise store in a hash indexed by the arguments
          else
            if !memoized_value.is_a?(Hash)
              memoized_value = {args => self.send("_unmemoized_#{method_name}", *args)}
              self.instance_variable_set("@#{memoized_ivar_name}", memoized_value)
            elsif !memoized_value.has_key?(args)
              memoized_value[args] = self.send("_unmemoized_#{method_name}", *args)
            end
            memoized_value[args]
          end
        end

        if is_private
          private method_name
        elsif is_protected
          protected method_name
        end

      end
    end
  end

  module InstanceMethods
    def unmemoize(method_name)
      self.instance_variable_set("@_memoized_#{method_name}", nil)
    end

    def unmemoize_all
      self.class.instance_variable_get('@_memoizer_methods').to_a.each do |method_name|
        unmemoize(method_name)
      end
    end
  end

end
