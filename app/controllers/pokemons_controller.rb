class PokemonsController < ApplicationController
  def index
    begin
      @pokemons = Pokemon.all
    rescue => exception
      @errors = exception
    end
    if @errors
      render json: @errors
    else
      render json: @pokemons
    end
  end
end
