# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

=begin
  user_x = User.create(name: 'Steve', email: 'steve@email.test', password: 'pass@123')
  user_y = User.create(name: 'Jean', email: 'jean@email.test', password: 'pass@123')

  x_y_channel = ChatsQuarter.create
  x_y_channel.chats
  x_y_channel.memberships
  x_y_channel.members
  x_y_channel.members << user_x
  x_y_channel.members << user_y

  x_channel = ChatsQuarter.create
  x_channel << user_x

  x_to_y = Message.create(desc: 'Hey there!', author: user_x, channel: x_y_channel)
  y_to_x = Message.create(desc: 'Hi!', author: user_y, channel: x_y_channel)

  user_x.messages
  user_x.memberships
  user_x.quarters
=end
