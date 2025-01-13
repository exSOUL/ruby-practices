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
