require "open-uri"
require "nokogiri"

puts "Clearing database..."

PokemonType.destroy_all
Pokemon.destroy_all
Type.destroy_all


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


puts "Creating all Pokemons..."

def get_sprite(pokemon_name)
  return if pokemon_name.start_with?("Nidoran")

  puts "Getting sprite for #{pokemon_name}"

  url = "https://bulbapedia.bulbagarden.net/wiki/#{pokemon_name.gsub(' ', '_')}_(Pokemon)"
  html_file = URI.open(url).read
  html_doc = Nokogiri::HTML.parse(html_file)
  img = html_doc.at("table.roundy img").attributes["src"].content
  "https:#{img}"
end

def create_pokemon(content, sprite)
  return if content[1].start_with?("Nidoran")

  index = content[0][1..].to_i
  name = content[1]
  types = content[2..]
  pokemon = Pokemon.create!(index:, name:, sprite:)
  types.each do |type_name|
    type = Type.find_by(name: type_name.downcase)
    PokemonType.create!(pokemon:, type:)
  end
  p name
end

url = "https://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_National_Pok%C3%A9dex_number"
html_file = URI.open(url).read
html_doc = Nokogiri::HTML.parse(html_file)

first_table_rows = html_doc.at("table.roundy tbody").search("tr")

first_table_rows[1..].each do |row|
  content = row.content.split("\n").reject(&:empty?)
  puts "Fetching Pokemon ##{content[0][1..].to_i}: #{content[1]}"
  if content[0].start_with?("#")
    sprite = get_sprite(content[1])
    create_pokemon(content, sprite)
  else
    puts "Special Pokemon, skipping"
    next
  end
end


puts "Indexing all Pokemons for algolia..."

Pokemon.all.each do |pokemon|
  pokemon.index!
end
