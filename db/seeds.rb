# Simulate users meta data
def simulate_user(name)
  { name:, email: "#{name.downcase}@gmail.com", password: 'pass@123' }
end

# Simulate messages meta data
def simulate_chat(i: Integer, rec: User, author: User)
  contents = %w(Hi Hello Hey Salute Greetings)
  {
    desc: "#{contents[i]}, #{rec.name}!",
    recipient: rec,
    author:
  }
end

# Generate users
users = User.create(%w(Tester Steve Eve Erica Emmy Ibrahim).map(&method(:simulate_user)))

# Pick a recipient user by random
rec = users.first

# Generate chat messages
users[1..].each do |author|
  Message.create(rand(1..5).times.map { |i| simulate_chat(i:, rec:, author:) })
end
