require 'nokogiri'
require 'open-uri'

class BinsearchNzb
  DEFAULT_OPTIONS = {
    m: '',
    max: 500,
    adv_g: '',
    adv_age: 999,
    adv_sort: 'date',
    adv_col: 'on',
    minsize: '',
    maxsize: '',
    postdate: ''
  }

  UNITS_TO_MULTIPLIER = {
    b: 0,
    kb: 1024,
    mb: 1024*1024,
    gb: 1024*1024*1024
  }

  # Example usage: BinsearchNzb.search('foo bar', max: 250)
  #
  # Available options:
  #   m          Set to '' for searching subject/filename or 'n' for searching body
  #   max        Max results to return
  #   adv_g      Newsgroup to search in
  #   adv_age    Maximum age of post
  #   adv_sort   How to sort results. Options:
  #                'date'       most recent first
  #                'asc_date'   oldest first
  #                'poster'     alphabetical by poster
  #                'subject'    alphabetical by subject
  #   adv_col    Only show collections, not individual files. Set to '' or false to search all, or 'on' for true
  #   minsize    Minimum size of post
  #   maxsize    Maximum size of post
  #   postdate   How to display post date. Set to '' for relative age or 'date' for calendar date

  def self.search(q, options = {})
    options = DEFAULT_OPTIONS.merge(options)
    options[:min] = (options[:page] || 0) * options[:max].to_i
    options[:q] = q
    options.delete(:adv_col) if ['', false].include?(options[:adv_col])
    query("https://binsearch.info/index.php?#{URI.encode_www_form(options)}")
  end

  private

  def self.query(url)
    results = []
    results_page = Nokogiri::HTML(open(url))
    results_page.css('table#r2 tr').each do |row|
      detail_cells = row.css('td')
      next if detail_cells.length < 6

      result = {}

      result[:title] = detail_cells[2].css('.s').text.strip
      collection_link = detail_cells[2].css('.d > a').find {|a| a.text == 'collection'}
      result[:collection_url] = "https://binsearch.info#{collection_link['href']}" if collection_link

      /size: (?<size>[^\s]+) (?<units>[^,]+)/i =~ detail_cells[2].css('.d').text.gsub(/[[:space:]]/, ' ')
      result[:size] = (size.to_f * UNITS_TO_MULTIPLIER[units.downcase.to_sym]).round if size
      result[:size_text] = size if size

      poster = detail_cells[3].css('a')[0]
      result[:poster] = {
        name: poster.text.strip,
        url: "https://binsearch.info#{poster['href']}"
      }

      group = detail_cells[4].css('a')[0]
      result[:group] = {
        name: group.text.strip,
        url: "https://binsearch.info/#{group['href']}"
      }

      result[:age] = detail_cells[5].text.strip

      results << result
    end

    results
  end
end
