# frozen_string_literal: true

# 1から20までの数をプリントするプログラムを書け。ただし3の倍数のときは数の代わりに｢Fizz｣と、
# 5の倍数のときは｢Buzz｣とプリントし、3と5両方の倍数の場合には｢FizzBuzz｣とプリントすること。

module FizzBuzz
  refine Integer do
    def fizz? = (self % 3).zero?
    def buzz? = (self % 5).zero?
    def fizzbuzz? = fizz? && buzz?
  end
end

using FizzBuzz

def fizzbuzz(int)
  return 'FizzBuzz' if int.fizzbuzz?
  return 'Fizz' if int.fizz?
  return 'Buzz' if int.buzz?

  int
end

(1..20).each do |i|
  puts fizzbuzz i
end

require 'rspec'

RSpec.describe 'fizzbuzz' do

  describe 'fizzbuzz' do
    it 'returns Fizz when the number is a multiple of 3' do
      expect(fizzbuzz(3)).to eq 'Fizz'
      expect(fizzbuzz(6)).to eq 'Fizz'
      expect(fizzbuzz(9)).to eq 'Fizz'
      expect(fizzbuzz(12)).to eq 'Fizz'
      expect(fizzbuzz(18)).to eq 'Fizz'
    end

    it 'returns Buzz when the number is a multiple of 5' do
      expect(fizzbuzz(5)).to eq 'Buzz'
      expect(fizzbuzz(10)).to eq 'Buzz'
      expect(fizzbuzz(20)).to eq 'Buzz'
    end

    it 'returns FizzBuzz when the number is a multiple of 3 and 5' do
      expect(fizzbuzz(15)).to eq 'FizzBuzz'
    end

    it 'returns the number when the number is not a multiple of 3 or 5' do
      expect(fizzbuzz(1)).to eq 1
      expect(fizzbuzz(2)).to eq 2
      expect(fizzbuzz(4)).to eq 4
      expect(fizzbuzz(7)).to eq 7
      expect(fizzbuzz(8)).to eq 8
      expect(fizzbuzz(11)).to eq 11
      expect(fizzbuzz(13)).to eq 13
      expect(fizzbuzz(14)).to eq 14
      expect(fizzbuzz(16)).to eq 16
      expect(fizzbuzz(17)).to eq 17
      expect(fizzbuzz(19)).to eq 19
    end
  end
end
