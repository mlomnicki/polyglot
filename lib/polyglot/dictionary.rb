require 'yaml'

DICT = 'en'

module Polyglot
  class Dictionary

    attr_reader :current_question, :current_answer, :current_key

    def initialize( revert = false )
      dict = YAML.load_file( File.join( File.dirname( __FILE__ ), 'dict.yml' ) )
      unless revert
        @base_questions = dict #.inject({}) { |hsh, (k,v)| hsh[k] = v; hsh }
      else
        @base_questions = {} 
        dict.each_pair { |k, v| @base_questions[k] = v.inject({}) { |hsh, (k,v)| hsh[v] = k; hsh } }
      end
      @questions = @base_questions.dup
    end

    def next_question!
      @current_question, @current_answer = current_hash.first
      remove_current_question!
      @current_question
    end

    protected
    def remove_current_question!
      hsh = @questions[@current_key]
      hsh.delete( @current_question )
      @questions.delete( @current_key ) if hsh.empty?
    end

    def next_key
      @questions = @base_questions.dup if @questions.empty?
      @current_key = @questions.keys[rand(@questions.keys.size)]
    end
    
    def current_hash
      @questions[next_key]
    end

  end
end
