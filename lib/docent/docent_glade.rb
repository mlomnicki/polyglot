#!/usr/bin/env ruby

require 'libglade2'

module Docent

  class DocentGlade
    include GetText

    attr :glade

    attr_accessor :current_word

    def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
      bindtextdomain(domain, localedir, nil, "UTF-8")
      @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
      @show_next = false
      @questions = CyclicHash.new( { :word => 'słowo', :letter => 'litera', :old => 'stary', :young => 'młody', :stinky => 'śmierdzący', 'to insist' => 'nalegać' } )
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
      if current_answer == @questions[current_word]
        show_status( "#{current_answer} - good answer!" )
        set_next_word
      else
        show_status( "#{current_answer} - bad answer. Try again." )
      end
    end

    def on_btn_help_clicked( widget )
      dialog = Gtk::MessageDialog.new(@window, Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::INFO, Gtk::MessageDialog::BUTTONS_OK,
        "#{current_word} - #{@questions[current_word]}" )
      dialog.run
      dialog.destroy
    end

    def current_word=( value )
      glade['lbl_word'].text = value.to_s
      @current_word = value
    end

    def current_answer
      glade['txt_answer'].text
    end

    def set_next_word
      clear_answer
      self.current_word = @questions.next!.key
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

