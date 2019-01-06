class Room < ApplicationRecord
  has_many :rooms_user
  has_many :users, through: :rooms_user
  accepts_nested_attributes_for :rooms_user
  has_many :messages

  validates :name, presence: true
end
