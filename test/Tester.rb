require 'YARTI'

twit = YARTI.new

user = gets.chomp
pass = gets.chomp

twit.setCreds user, pass