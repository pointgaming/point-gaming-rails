module Tire
  module Model

    # Main module containing the infrastructure for automatic updating
    # of the _Elasticsearch_ index on model instance create, update or delete.
    #
    # Include it in your model: `include Tire::Model::Callbacks`
    #
    # The model must respond to `after_save` and `after_destroy` callbacks
    # (ActiveModel and ActiveRecord models do so, by default).
    #
    module CustomCallbacks

      # A hook triggered by the `include Tire::Model::CustomCallbacks` statement in the model.
      #
      def self.included(base)

        # Update index on model instance change or destroy.
        #
        if base.respond_to?(:after_save) && base.respond_to?(:after_destroy)
          base.send :after_save,    :update_tire_index
          base.send :after_destroy, :update_tire_index
        end

        # Add neccessary infrastructure for the model, when missing in
        # some half-baked ActiveModel implementations.
        #
        if base.respond_to?(:before_destroy) && !base.instance_methods.map(&:to_sym).include?(:destroyed?)
          base.class_eval do
            before_destroy  { @destroyed = true }
            def destroyed?; !!@destroyed; end
          end
        end

      end

      private

      def update_tire_index
        tire.update_index
      rescue Errno::ECONNREFUSED
        Rails.logger.warn 'Failed to connect to tire when trying to update_index!'
      end

    end

  end
end
