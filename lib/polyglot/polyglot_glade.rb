#!/usr/bin/env ruby

require 'libglade2'
require 'yaml'

DICT = ENV['DICT'] || 'en'

module Polyglot

  class PolyglotGlade
    include GetText

    attr :glade

    attr_accessor :current_word, :current_key

    def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
      bindtextdomain(domain, localedir, nil, "UTF-8")
      @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
      @show_next = false
      dict = YAML.load_file( File.join( File.dirname( __FILE__ ), 'dict.yml' ) )
      @questions = dict.inject({}) { |hsh, (k,v)| hsh[k] = CyclicHash.new(v, DICT == 'pl'); hsh }
      @current_key = @questions.keys.first
      @good_answers = 0
      @all_answers = 0
    end

    def show
      @window = glade['main_window']
      @window.show_all
      set_next_word
      @window.signal_connect( 'destroy' ) { Gtk.main_quit }
    end

    def on_chb_show_next_toggled( widget )
      @show_next = widget.active?
    end

    def on_txt_answer_enter_notify_event
      @all_answers += 1
      if current_answer == @questions[current_key][current_word]
        @good_answers += 1
        show_status( "#{current_answer} - good answer! (#{@good_answers} / #{@all_answers})" )
        set_next_word
      else
        show_status( "#{current_answer} - bad answer. Try again. (#{@good_answers} / #{@all_answers})" )
        clear_answer
      end
    end

    def on_btn_help_clicked( widget )
      dialog = Gtk::MessageDialog.new(@window, Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::INFO, Gtk::MessageDialog::BUTTONS_OK, "#{current_word} - #{@questions[current_key][current_word]}" )
      dialog.run
      dialog.destroy
      @all_answers += 1
      show_status( "Bad answer. (#{@good_answers} / #{@all_answers})" )
      set_next_word
      glade['txt_answer'].grab_focus
    end

    def current_word=( value )
      glade['lbl_word'].text = "#{value} (#{current_key})"
      @current_word = value
    end

    def current_answer
      glade['txt_answer'].text
    end

    def set_next_word
      clear_answer
      @current_key = @questions.keys[rand(@questions.size)]
      self.current_word = @questions[@current_key].next!.key
    end

    def clear_answer
      glade['txt_answer'].text = ''
    end

    protected
    def show_status( text, content = 'answer' )
      status_bar=glade['status_bar']
      status_bar_context = status_bar.get_context_id('answer')
      status_bar.push( status_bar_context, text )
    end

  end

end

