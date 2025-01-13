#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'optparse'

WDAY_JA = %w[日 月 火 水 木 金 土].freeze
WDAY_US = %w[Su Mo Tu We Th Fr Sa].freeze

class OptionParser::InvalidcalendarMonth < OptionParser::ParseError; end

class Calendar
  def main
    print print_cal
    exit 1 if @is_error
  end

  def print_cal
    return if @is_error

    outputs = []
    outputs << "#{cal_header}  "

    outputs << "#{cal_weekdays}  "

    # 1週間で分割して出力
    cal_days.each_slice(7) do |week|
      outputs << "#{week.join(' ')}  "
    end
    "#{outputs.join("\n")}\n"
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

    valid_month?
  rescue OptionParser::InvalidOption, OptionParser::MissingArgument, OptionParser::InvalidcalendarMonth => e
    @is_error = true
    warn e.message
    warn opt.help
  end

  def valid_month?
    return if (1..12).cover?(@month)

    raise OptionParser::InvalidcalendarMonth, "invalid month: #{@month}"
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

    # カレンダー上で1日の曜日が一致するように日付配列に空白を追加
    cal_days_array = Array.new(first_wday, '  ')

    (1..last_day).each do |day|
      cal_days_array << format('%2d', day)
    end

    # 日付配列の要素数がカレンダーの最大マス目数7＊6の42になるように空白を追加
    cal_days_array << '  ' until cal_days_array.size == 42

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

Calendar.new.main

require 'rspec'

RSpec.describe 'calendar' do
  describe '#print_cal' do
    subject { Calendar.new.print_cal }
    context '言語設定が日本語の場合' do
      before do
        allow_any_instance_of(Calendar).to receive(:lang_ja?).and_return(true)
      end

      it '月の桁が1桁である1970年1月のカレンダーがcalコマンドと一致すること' do
        ARGV.replace(['-m', '1', '-y', '1970'])
        command_output = `LANG="ja_JP.UTF-8" cal 1 1970`
        expect(subject).to eq command_output
      end

      it '月の桁が2桁である1970年12月のカレンダーがcalコマンドと一致すること' do
        ARGV.replace(['-m', '12', '-y', '1970'])
        command_output = `LANG="ja_JP.UTF-8" cal 12 1970`
        expect(subject).to eq command_output
      end

      context '今月のカレンダーの場合' do
        before do
          allow(Date).to receive(:today).and_return(Date.new(2025, 1, 15))
        end

        it '今月のカレンダー当日に文字反転のANSIエスケープシーケンスが設定されていること' do
          expect(subject).to include("\e\[7m15\e\[0m")
        end
      end

      context '引数 -m の範囲が1から12でない場合' do
        it '引数 -m が0の場合、エラーメッセージが表示されること' do
          ARGV.replace(['-m', '0', '-y', '2024'])
          expect { subject }.to output(/invalid month: 0\n/).to_stderr
        end

        it '引数 -m が13の場合、エラーメッセージが表示されること' do
          ARGV.replace(['-m', '13', '-y', '2024'])
          expect { subject }.to output(/invalid month: 13\n/).to_stderr
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
        expect(subject).to eq command_output
      end

      it 'JanuaryからDecemberまでのカレンダーがcalコマンドと一致すること' do
        (1..12).each do |month|
          ARGV.replace(['-m', month.to_s, '-y', '2100'])
          command_output = `LANG=C cal #{month} 2100`
          # subjectの文字列とcommand_outputの文字列が一致すること
          expect(Calendar.new.print_cal).to eq command_output
        end
      end
    end
  end

  describe '#main' do
    subject { Calendar.new.main }
    context '引数が指定されていない場合' do
      before do
        allow(Date).to receive(:today).and_return(Date.new(2024, 1, 15))
        allow_any_instance_of(Calendar).to receive(:lang_ja?).and_return(true)
        # calコマンドから取得した出力ではANSIエスケープシーケンスが消えてしまい
        # 当日日付でdiffが発生するため、include_today?をfalseに設定し反転表記を無効にしている
        allow_any_instance_of(Calendar).to receive(:include_today?).and_return(false)
      end

      it 'カレンダーがcalコマンドと一致すること' do
        command_output = `LANG="ja_JP.UTF-8" cal 1 2024`
        expect { subject }.to output(command_output).to_stdout
      end
    end

    context '引数が指定されている場合' do
      before do
        allow_any_instance_of(Calendar).to receive(:lang_ja?).and_return(true)
      end

      it '2024年1月のカレンダーがcalコマンドと一致すること' do
        ARGV.replace(['-m', '1', '-y', '2024'])
        command_output = `LANG="ja_JP.UTF-8" cal 1 2024`
        expect { subject }.to output(command_output).to_stdout
      end
    end
  end
end
