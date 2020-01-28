module Zaikio
  class Person < ApplicationRecord
    # Concerns
    include Zaikio::TokenBearer

    # Associations
    has_many :memberships, class_name: 'Zaikio::OrganizationMembership', dependent: :destroy
    has_many :organizations, through: :memberships

    # Validations
    validates :first_name, :name, presence: true
    validates :email, presence: true, uniqueness: true
  end
end
