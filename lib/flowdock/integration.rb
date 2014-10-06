class FlowdockIntegration < ActiveRecord::Base
  validates :token, presence: true, length: { minimum: 1 }, uniqueness: true
  validates :flowdock_id, presence: true, uniqueness: true
end
