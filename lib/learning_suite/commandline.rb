require 'learning_suite'

require 'trollop'
require 'yaml'

module LearningSuite
  class Commandline
    ICLICKER_EXT = ".iclicker_update.csv"
    def self.run(argv)
      parser = CmdParser.new(CmdParser::SUB_COMMANDS)
      argv = parser.parse!(argv)
      argv = parser.parse_subcommand!(argv)

      case parser.subcommand
      when :gb_to_iclicker_roster
        gb = LearningSuite::Gradebook.new(argv[0])
        gb.write_roster
      when :iclicker_to_gb
        if argv.size == 1 && argv.first == 'AUTO'
          candidates = Dir["*.csv"].select {|f| f =~ /\d{4}-\d{2}-\d{2}/ }
          latest_gb_csv = candidates.sort_by {|f| f[/\d{4}-(\d{2}-\d{2})/, 1].split('-').join.to_i }.last
          iclicker_grade_file = 'UploadFile.csv'
          abort "couldn't find any gradebook export .csv files (need dddd-dd-dd in filename)" unless latest_gb_csv
          abort "couldn't find #{iclicker_grade_file}" unless File.exist?(iclicker_grade_file)
          abort "couldn't find date_to_assignment.yml" unless File.exist?("date_to_assignment.yml")
          argv = [latest_gb_csv, iclicker_grade_file, "date_to_assignment.yml"]
        end
        unless argv.size == 3
          parser.educate_with_subcommand && exit
        end
        (gb_csv, iclicker_csv, date_to_assignment) = argv
        gb = LearningSuite::Gradebook.new(gb_csv)
        gb.merge_iclicker!(iclicker_csv, date_to_assignment, parser.subcommand_opts[:points_per_day])
        gb_base = gb_csv.chomp(File.extname(gb_csv))
        gb.write_file( gb_base + ICLICKER_EXT )
      when :fill_scores
        unless argv.size == 1
          parser.educate_with_subcommand && exit
        end
        gb_csv = argv.first
        gb = LearningSuite::Gradebook.new(gb_csv)
        gb.fill_scores!(parser.subcommand_opts[:fill_val])
        gb_base = gb_csv.chomp(File.extname(gb_csv))
        gb.write_file( gb_base + ".filled_scores.csv" )
      when :curve_final_grade
        unless argv.size == 2
          parser.educate_with_subcommand && exit
        end
        (gb_csv, target_gpa) = argv
        gb = LearningSuite::Gradebook.new(gb_csv)
        gb.curve_final_grade!(target_gpa.to_f, parser.subcommand_opts[:curve_type].to_sym)
        gb.write_file( gb_base + ".final_grade_curved.csv" )
      end
    end
  end

  class CmdParser
    SUB_COMMANDS = {
      gb_to_iclicker_roster: "convert learning suite grade export (Grades.csv) into #{LearningSuite::Iclicker::ROSTER} [General, (No CMS specified)]",
      iclicker_to_gb: "convert iclicker export into format suitable for gradebook",
      #curve_exam: "curve the latest exam",
      curve_final_grade: "curve the final grade (simple percent export)",
      fill_scores: "writes scores in for missing data",
    }

    attr_accessor :global_parser
    attr_accessor :global_opts

    attr_accessor :subcommand_parser
    # as a symbol
    attr_accessor :subcommand
    attr_accessor :subcommand_opts

    # sub_commands is a hash of the command and a description
    def initialize(sub_commands)
      @global_parser = Trollop::Parser.new do
        banner "usage: #{File.basename(__FILE__)} <subcommand> [OPTIONS]"
        text ""
        text "subcommands: "
        sub_commands.each do |k,v|
          text "  #{k}  #{v}"
        end
        text ""
        stop_on sub_commands.keys.map(&:to_s)
      end
    end

    # returns the modified argv
    def parse!(argv)
      begin 
        @global_opts = @global_parser.parse(argv)
      rescue Trollop::HelpNeeded
        @global_parser.educate && exit 
      end
      @global_parser.educate && exit unless argv.size > 0
      argv
    end

    # returns argv
    def parse_subcommand!(argv)
      @subcommand = argv.shift.to_sym
      @subcommand_parser = 
        case @subcommand
        when :gb_to_iclicker_roster
          Trollop::Parser.new do
            banner "learning_suite.rb gb_to_iclicker_roster <gb_grades>.csv"
            text "output: #{LearningSuite::Iclicker::ROSTER}"
          end
        when :iclicker_to_gb
          Trollop::Parser.new do
            banner "learning_suite.rb iclicker_to_gb <gb_grades>.csv <iclicker_export>.csv date_to_assignment.yml [OPTIONS]"
            text "<or>"
            text "learning_suite.rb iclicker_to_gb AUTO"
            text "(requires one file named UploadFile.csv)"
            text "output: <gb_grades>#{LearningSuite::Commandline::ICLICKER_EXT}"
            opt :points_per_day, "number of points to grant", :default => 2.0
          end
        when :fill_scores
          Trollop::Parser.new do
            banner "learning_suite.rb fill_scores <gb_grades>.csv [OPTIONS]"
            text "output: <gb_grades>.filled_scores.csv"
            opt :fill_val, "fill with this score", :default => 0.0
          end
        when :curve_final_grade
          Trollop::Parser.new do
            banner "learning_suite.rb curve_final_grade <gb_grades>.csv target_GPA [OPTIONS]"
            text "output: <gb_grades>.final_grade_curved.csv"
            opt :curve_type, "kind of curve to use", :default => 'flat'
          end
        end
      @subcommand_opts = @subcommand_parser.parse(argv) if @subcommand_parser
      argv
    end

    # returns self
    def educate_with_subcommand
      @global_parser.educate
      puts ""
      @subcommand_parser.educate
      self
    end
  end
end
