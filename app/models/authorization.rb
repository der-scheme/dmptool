class Authorization < ActiveRecord::Base

  belongs_to :user
  belongs_to :role
  validates :role_id, presence: true
  validates :user_id, presence: true, numericality: true

  validates :id, uniqueness: {scope: [:user_id, :role_id]}
end


