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
    puts "#{cal_header}  "

    puts "#{cal_weekdays}  "

    # 1週間で分割して出力
    cal_days.each_slice(7) do |week|
      puts "#{week.join(' ')}  "
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
    cal_days_array = Array.new(first_wday, '  ')

    (1..last_day).each do |day|
      cal_days_array << format('%2d', day)
    end

    cal_days_array.size.upto(41) { cal_days_array << '  ' }

    today_highlight(cal_days_array) if include_today?

    cal_days_array
  end

  def include_today?
    @today.year == @year && @today.month == @month
  end

  def lang_ja?
    @lang_ja ||= (ENV['LC_ALL'] || ENV['LANG']).start_with?('ja')
  end

  def today_highlight(cal_days_array)
    today_day = @today.strftime('%2d')
    today_index = cal_days_array.find_index(today_day)
    cal_days_array[today_index] = "\e[7m#{today_day}\e[0m"
    cal_days_array
  end
end

Calendar.new.print_cal

require 'rspec'

RSpec.describe 'calendar' do
  context '言語設定が日本語の場合' do
    before do
      allow_any_instance_of(Calendar).to receive(:lang_ja?).and_return(true)
    end

    it '月の桁が1桁である1970年1月のカレンダーがcalコマンドと一致すること' do
      ARGV.replace(['-m', '1', '-y', '1970'])
      command_output = `LANG="ja_JP.UTF-8" cal 1 1970`
      expect { Calendar.new.print_cal }.to output(command_output).to_stdout
    end

    it '月の桁が2桁である1970年12月のカレンダーがcalコマンドと一致すること' do
      ARGV.replace(['-m', '12', '-y', '1970'])
      command_output = `LANG="ja_JP.UTF-8" cal 12 1970`
      expect { Calendar.new.print_cal }.to output(command_output).to_stdout
    end

    context '今月のカレンダーの場合' do
      before do
        allow(Date).to receive(:today).and_return(Date.new(2021, 7, 15))
      end

      it '今月のカレンダー当日に文字反転のANSIエスケープシーケンスが設定されていること' do
        expect { Calendar.new.print_cal }.to output(/\e\[7m15\e\[0m/).to_stdout
      end
    end
  end

  context '言語設定が日本語以外の場合' do
    before do
      allow_any_instance_of(Calendar).to receive(:lang_ja?).and_return(false)
    end

    it '2100年12月のカレンダーがcalコマンドと一致すること' do
      ARGV.replace(['-m', '12', '-y', '2100'])
      command_output = `LANG=C cal 12 2100`
      expect { Calendar.new.print_cal }.to output(command_output).to_stdout
    end

    it 'JanuaryからDecemberまでのカレンダーがcalコマンドと一致すること' do
      (1..12).each do |month|
        ARGV.replace(['-m', month.to_s, '-y', '2100'])
        command_output = `LANG=C cal #{month} 2100`
        expect { Calendar.new.print_cal }.to output(command_output).to_stdout
      end
    end
  end
end
