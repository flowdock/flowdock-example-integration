class FlowdockIntegration < ActiveRecord::Base
  validates :token, presence: true, length: { minimum: 1 }
  validates_uniqueness_of :token
end
