class DeliveryAudit < ActiveRecord::Base
  store :info, :accessors => [:deliveries, :errors]
end
