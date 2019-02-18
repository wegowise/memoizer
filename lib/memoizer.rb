module Memoizer
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  def self.safe_name(method_name)
    method_name.to_s.sub(/\?\Z/, '_query').sub(/!\Z/, '_bang').to_sym
  end

  def self.ivar_name(method_name)
    :"@_memoized_#{self.safe_name(method_name)}"
  end

  module ClassMethods
    def memoize(*method_names)
      method_names.each do |method_name|
        memoized_ivar_name = Memoizer.ivar_name(method_name)
        unmemoized_method = "_unmemoized_#{method_name}"

        alias_method unmemoized_method, method_name

        arity = instance_method(unmemoized_method).arity

        case arity
        when 0
          module_eval(<<-RUBY)
            def #{method_name}()
              #{memoized_ivar_name} ||= [send(:#{unmemoized_method})]
              #{memoized_ivar_name}.first
            end
          RUBY

        when -1
          module_eval(<<-RUBY)
            def #{method_name}(*args)
              #{memoized_ivar_name} ||= {}
              if #{memoized_ivar_name}.has_key?(args)
                #{memoized_ivar_name}[args]
              else
                #{memoized_ivar_name}[args] = send(:#{unmemoized_method}, *args)
              end
            end
          RUBY

        else
          arg_names = (0..(arity - 1)).map { |i| "arg#{i}" }
          args_ruby = arg_names.join(', ')

          module_eval(<<-RUBY)
            def #{method_name}(#{args_ruby})
              args = [#{args_ruby}]
              #{memoized_ivar_name} ||= {}
              if #{memoized_ivar_name}.has_key?(args)
                #{memoized_ivar_name}[args]
              else
                #{memoized_ivar_name}[args] = send(:#{unmemoized_method}, #{args_ruby})
              end
            end
          RUBY
        end

        if self.private_method_defined?(unmemoized_method)
          private method_name
        elsif self.protected_method_defined?(unmemoized_method)
          protected method_name
        end
      end
    end
  end

  module InstanceMethods
    def unmemoize(method_name)
      self.instance_variable_set(Memoizer.ivar_name(method_name), nil)
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
