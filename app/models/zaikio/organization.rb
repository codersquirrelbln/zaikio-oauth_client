module Zaikio
  class Organization < ApplicationRecord
    # Concerns
    include Zaikio::TokenBearer

    # Associations
    has_many :memberships, class_name: 'Zaikio::OrganizationMembership', dependent: :destroy
    has_many :members, through: :memberships, source: :person

    # Validations
    validates :name, presence: true, uniqueness: true
  end
end