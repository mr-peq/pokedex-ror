require "open-uri"
require "nokogiri"

puts "Clearing database..."

PokemonType.destroy_all
Pokemon.destroy_all
Type.destroy_all


# puts "Creating 9 first Pokemons..."

# pokemons = [
#   {
#     name: "Bulbasaur",
#     sprite: "https://3dmodels.org/wp-content/uploads/2023/08/28/Bulbasaur_3d_model_1000_0001.jpg",
#     types: %w[grass poison]
#   },
#   {
#     name: "Ivysaur",
#     sprite: "https://i.pinimg.com/736x/e7/91/72/e79172fef348260adb1de1406b332deb.jpg",
#     types: %w[grass poison]
#   },
#   {
#     name: "Venusaur",
#     sprite: "https://i.etsystatic.com/20838977/r/il/2afa41/4292447434/il_570xN.4292447434_cmm0.jpg",
#     types: %w[grass poison]
#   },
#   {
#     name: "Charmander",
#     sprite: "https://i.etsystatic.com/20838977/r/il/6bf90e/4339669865/il_570xN.4339669865_qbvx.jpg",
#     types: %w[fire]
#   },
#   {
#     name: "Charmeleon",
#     sprite: "https://static.wikia.nocookie.net/pokemon-the-islands/images/4/4b/Charmeleon.jpg/revision/latest?cb=20230627201459",
#     types: %w[fire]
#   },
#   {
#     name: "Charizard",
#     sprite: "https://files.cults3d.com/uploaders/21424024/illustration-file/2a143a8f-f573-4e58-850b-c5748941405b/charizard.png",
#     types: %w[fire flying]
#   },
#   {
#     name: "Squirtle",
#     sprite: "https://www.goodstickers.fr/4611/pokemon-squirtle.jpg",
#     types: %w[water]
#   },
#   {
#     name: "Wartortle",
#     sprite: "https://thegreatnodnarb.files.wordpress.com/2013/07/wartortle.gif",
#     types: %w[water]
#   },
#   {
#     name: "Blastoise",
#     sprite: "https://i.etsystatic.com/20838977/r/il/2e63a0/4339635875/il_570xN.4339635875_kuls.jpg",
#     types: %w[water]
#   },
# ]

# 9.times do |i|
#   Pokemon.create!(index: i+1, name: pokemons[i][:name], sprite: pokemons[i][:sprite] )
# end


puts "Creating all types..."

Type.create!(name: "grass")
Type.create!(name: "poison")
Type.create!(name: "fire")
Type.create!(name: "flying")
Type.create!(name: "water")
Type.create!(name: "normal")
Type.create!(name: "electric")
Type.create!(name: "ice")
Type.create!(name: "fighting")
Type.create!(name: "ground")
Type.create!(name: "psychic")
Type.create!(name: "bug")
Type.create!(name: "rock")
Type.create!(name: "ghost")
Type.create!(name: "dragon")
Type.create!(name: "dark")
Type.create!(name: "steel")
Type.create!(name: "fairy")
Type.create!(name: "stellar")


# puts "Assigning types to created Pokemons..."

# Pokemon.all.each do |pokemon|
#   types = pokemons[pokemon.index - 1][:types]
#   types.each do |type|
#     assigned_type = Type.find_by(name: type)
#     PokemonType.create!(pokemon:, type: assigned_type)
#   end
# end


puts "Testing nokogiri..."

def get_sprite(pokemon_name)
  url = "https://bulbapedia.bulbagarden.net/wiki/#{pokemon_name}_(Pokemon)"
  html_file = URI.open(url).read
  html_doc = Nokogiri::HTML.parse(html_file)
  img = html_doc.at("img").attributes["src"].content
  "https:#{img}"
end

def create_pokemon(content, sprite)
  index = content[0][1..].to_i
  name = content[1]
  types = content[2..]
  pokemon = Pokemon.create!(index:, name:, sprite:)
  types.each do |type_name|
    type = Type.find_by(name: type_name.downcase)
    PokemonType.create!(pokemon:, type:)
  end
end

url = "https://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_National_Pok%C3%A9dex_number"
html_file = URI.open(url).read
html_doc = Nokogiri::HTML.parse(html_file)

first_table_rows = html_doc.at("table.roundy tbody").search("tr")

first_table_rows[1..].each do |row|
  content = row.content.split("\n").reject(&:empty?)
  if content[0].start_with?("#")
    sprite = get_sprite(content[1])
    create_pokemon(content, sprite)
  end
end


puts "Indexing all Pokemons for algolia..."

Pokemon.all.each do |pokemon|
  pokemon.index!
end
