#!/usr/bin/env ruby
# frozen_string_literal: true

# ./cal.rb で実行できること(ruby cal.rb としなくてよいこと)
# [rubyでコマンドを作る](https://bootcamp.fjord.jp/articles/40) を参考にしてください
# -mで月を、-yで年を指定できる
# ただし、-yのみ指定して一年分のカレンダーを表示する機能の実装は不要
# 引数を指定しない場合は、今月・今年のカレンダーが表示される
# MacやWSLに入っているcalコマンドと同じ見た目になっている
# OSのcalコマンドと自分のcalコマンドの両方の実行結果を載せてください
# 少なくとも1970年から2100年までは正しく表示される
require 'date'
require 'optparse'

WDAY_JA = %w[日 月 火 水 木 金 土].freeze

opt = OptionParser.new

opt.on('-m MONTH') { |month| @month = month.to_i }
opt.on('-y YEAR') { |year| @year = year.to_i }

opt.parse!(ARGV)

@month ||= Date.today.month
@year ||= Date.today.year

first_wday = Date.new(@year, @month, 1).wday
last_day = Date.new(@year, @month, -1).day

# calの1行目の月と年を出文字列
cal_line1 = "      #{@month}月 #{@year}"
puts cal_line1

# calの2行目の曜日を出力
cal_line2 = WDAY_JA.join(' ')
puts cal_line2

# 1日までの空白を追加
cal_daybox = Array.new(first_wday, '  ')

# 1日から月末までの日付を追加
(1..last_day).each do |day|
  cal_daybox << format('%2d', day)
end

# 1週間で分割して出力
cal_daybox.each_slice(7) do |week|
  puts week.join(' ')
end
