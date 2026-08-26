# João opera a Pousada do Thor. Maria é dona dos pets Thor, Luna e Bidu.

joao = User.find_or_initialize_by(email: "joao@email.com")
joao.name = "João"
joao.password = "senha123"
joao.save!

maria = joao.owners.find_or_initialize_by(email: "maria@email.com")
maria.name = "Maria"
maria.phone = "(11) 99999-0000"
maria.save!

thor = joao.pets.find_or_initialize_by(name: "Thor")
thor.species = "cão"
thor.owner = maria
thor.save!

luna = joao.pets.find_or_initialize_by(name: "Luna")
luna.species = "gato"
luna.owner = maria
luna.save!

bidu = joao.pets.find_or_initialize_by(name: "Bidu")
bidu.species = "cão"
bidu.owner = maria
bidu.save!

today = Date.current

thor_stay = joao.stays.find_or_initialize_by(pet: thor, status: :checked_in)
thor_stay.check_in = today
thor_stay.check_out = today + 3
thor_stay.nightly_rate_cents = 8000
thor_stay.save!

luna_stay = joao.stays.find_or_initialize_by(pet: luna, status: :scheduled)
luna_stay.check_in = today + 5
luna_stay.check_out = today + 8
luna_stay.nightly_rate_cents = 7000
luna_stay.save!

puts "Seeds ok. Login: joao@email.com / senha123"
