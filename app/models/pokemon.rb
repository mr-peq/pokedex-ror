class Pokemon < ApplicationRecord
  include AlgoliaSearch

  has_many :pokemon_types
  has_many :types, through: :pokemon_types

  algoliasearch do
    attribute :types do
      types.map(&:name)
    end
  end
end
