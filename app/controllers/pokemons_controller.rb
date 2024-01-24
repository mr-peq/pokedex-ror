class PokemonsController < ApplicationController
  def index
    begin
      @pokemons = Pokemon.all
      if params[:types].present?
        @pokemons = filtered_pokemons
      elsif params[:not_types].present?
        @pokemons = exclude_query
      end
    rescue => exception
      @errors = exception
    end
    if @errors
      render json: @errors
    else
      render json: @pokemons
    end
  end


  private

  def filtered_pokemons
    types = params[:types].split
    pokemons = []
    types.each do |type|
      pokemons.push(Pokemon.search(type))
    end
    pokemons.flatten.uniq.sort_by(&:index)
  end

  def exclude_query
    all_types = Type.all.map(&:name)
    excluded_types = params[:not_types].split
    types = all_types - excluded_types
    pokemons = exclude_pokemons(types, excluded_types)

    pokemons.flatten.uniq.sort_by(&:index)
  end

  def exclude_pokemons(types, excluded_types)
    pokemons = []
    types.each do |type|
      matching_pokemons = Pokemon.search(type)
      matching_pokemons.each do |pokemon|
        pokemons << pokemon unless has_excluded_type?(pokemon, excluded_types)
      end
    end
    pokemons
  end

  def has_excluded_type?(pokemon, excluded_types)
    pokemon_types = pokemon.types.map(&:name)

    # This line returns ONLY the values contained in BOTH arrays
    matches = pokemon_types & excluded_types
    matches.empty? ? false : true
  end
end
