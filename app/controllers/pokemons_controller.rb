class PokemonsController < ApplicationController
  def index
    begin
      @pokemons = Pokemon.all
      if params[:types].present?
        @pokemons = filtered_pokemons
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
end
