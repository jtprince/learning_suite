
module LearningSuite
  module Grades
    GRADE_LETTER_TO_GRADE_POINTS = {
      'A' => 4,
      'A-' => 3.7,
      'B+' =>	3.4,
      'B' => 3,
      'B-' => 2.7,
      'C+' => 2.4,
      'C'	=> 2,
      'C-' =>	1.7,
      'D+' => 1.4,
      'D'	=> 1,
      'D-' => 0.7,
      'E'	=> 0,
    }

    RANGE_TO_GRADE_LETTER = {
      93..100 => 'A',
      90..92 => 'A-',
      87..89 => 'B+',
      83..86 => 'B',
      80..82 => 'B-',
      77..79 => 'C+',
      73..76 => 'C',
      70..72 => 'C-',
      67..69 => 'D+',
      63..66 => 'D',
      60..62 => 'D-',
      0..59 => 'E',
    }

    # uses RANGE_TO_GRADE_WHOLE_NUMBERS and GRADE_TO_GRADE_POINTS to calculate
    # the gpa pts of a given grade (given as 0-100).  If given a letter grade,
    # converts it to gpa points.  
    def self.to_gpa(arg)
      case arg
      when String
        GRADE_LETTER_TO_GRADE_POINTS[arg.capitalize]
      when Float, Integer
        raise ArgumentError, 'percent must be between 0 and 100' unless (0..100).===(arg)
        letter = RANGE_TO_GRADE_LETTER.find {|range, letter| range === arg }.last
        GRADE_LETTER_TO_GRADE_POINTS[letter]
     end
    end

  end
end
