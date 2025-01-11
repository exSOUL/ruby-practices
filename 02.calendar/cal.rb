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
WDAY_US = %w[Su Mo Tu We Th Fr Sa].freeze

class Calendar
  def print_cal

    puts cal_header

    puts cal_weekdays

    # 1週間で分割して出力
    cal_days.each_slice(7) do |week|
      puts week.join(' ')
    end
  end

  private

  def initialize
    opt = OptionParser.new

    opt.on('-m MONTH') { |month| @month = month.to_i }
    opt.on('-y YEAR') { |year| @year = year.to_i }

    opt.parse!(ARGV)

    @today = Date.today
    @month ||= @today.month
    @year ||= @today.year
  end

  def cal_header
    return "#{@month}月 #{@year}".center(20) if lang_ja?

    "#{Date::MONTHNAMES[@month]} #{@year}".center(20)
  end

  def cal_weekdays
    return WDAY_JA.join(' ') if lang_ja?

    WDAY_US.join(' ')
  end

  def cal_days
    first_wday = Date.new(@year, @month, 1).wday
    last_day = Date.new(@year, @month, -1).day

    # 1日の曜日が一致するように日付配列に空白を追加
    cal_days = Array.new(first_wday, '  ')

    (1..last_day).each do |day|
      cal_days << format('%2d', day)
    end

    today_highlight(cal_days) if include_today?

    cal_days
  end

  def include_today?
    @today.year == @year && @today.month == @month
  end

  def lang_ja?
    @lang_ja ||= (ENV['LC_ALL'] || ENV['LANG']).start_with?('ja')
  end

  def today_highlight(cal_days)
    today_day = @today.strftime('%2d')
    today_index = cal_days.find_index(today_day)
    cal_days[today_index] = "\e[7m#{today_day}\e[0m"
    cal_days
  end
end

Calendar.new.print_cal
