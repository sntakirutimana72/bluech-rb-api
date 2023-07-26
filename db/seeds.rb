users_meta = 5.times.map do |i|
  { name: "Steve#{i + 1}", email: "steve#{i + 1}@gmail.com", password: 'pass@123' }
end

users = User.create(users_meta)
recipient = users.first

users[1..].each do |author|
  Message.create(rand(1..5).times.map { |i| { desc: "Hi-#{i + 1}!", recipient:, author: } })
end
