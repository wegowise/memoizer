module Memoizer
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  def self.safe_name(method_name)
    method_name.to_s.sub(/\?\Z/, '_query').sub(/!\Z/, '_bang').to_sym
  end

  module ClassMethods
    attr_accessor :_memoizer_methods

    def memoize(*method_names)
      method_names.each do |method_name|
        safe_method_name = Memoizer.safe_name(method_name)

        memoized_ivar_name = "_memoized_#{safe_method_name}"
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
              memoized_value = [self.send(aliased_original_method_name)]
              self.instance_variable_set("@#{memoized_ivar_name}", memoized_value)
            end
            memoized_value.first

          #otherwise store in a hash indexed by the arguments
          else
            if !memoized_value.is_a?(Hash)
              memoized_value = {args => self.send(aliased_original_method_name, *args)}
              self.instance_variable_set("@#{memoized_ivar_name}", memoized_value)
            elsif !memoized_value.has_key?(args)
              memoized_value[args] = self.send(aliased_original_method_name, *args)
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
      self.instance_variable_set("@_memoized_#{Memoizer.safe_name(method_name)}", nil)
    end

    def unmemoize_all
      (methods + private_methods + protected_methods).each do |method|
        if method.to_s =~ /^_unmemoized_(.*)/
          unmemoize($1)
        end
      end
    end
  end

end
