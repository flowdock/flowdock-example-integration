class FlowdockIntegration < ActiveRecord::Base
  validates :token, presence: true, length: { minimum: 1 }
  validates_uniqueness_of :token
  validates :flowdock_id, presence: true
  validates_uniqueness_of :flowdock_id
end
