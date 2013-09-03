
module LearningSuite
  module Grades
    GRADE_LETTER_TO_GRADE_POINTS = {
      'A' => 4.0,
      'A-' => 3.7,
      'B+' =>	3.4,
      'B' => 3.0,
      'B-' => 2.7,
      'C+' => 2.4,
      'C'	=> 2.0,
      'C-' =>	1.7,
      'D+' => 1.4,
      'D'	=> 1.0,
      'D-' => 0.7,
      'E'	=> 0.0,
    }

    RANGE_TO_GRADE_LETTER_ROUNDED = {
      92.5..100.0 => 'A',
      89.5...92.5 => 'A-',
      86.5...89.5 => 'B+',
      82.5...86.5 => 'B',
      79.5...82.5 => 'B-',
      76.5...79.5 => 'C+',
      72.5...76.5 => 'C',
      69.5...72.5 => 'C-',
      66.5...69.5 => 'D+',
      62.5...66.5 => 'D',
      59.5...62.5 => 'D-',
      0.0...59.5 => 'E',
    }

    RANGE_TO_GRADE_LETTER = {
      93.0..100.0 => 'A',
      90.0...93.0 => 'A-',
      87.0...90.0 => 'B+',
      83.0...87.0 => 'B',
      80.0...83.0 => 'B-',
      77.0...80.0 => 'C+',
      73.0...77.0 => 'C',
      70.0...73.0 => 'C-',
      67.0...70.0 => 'D+',
      63.0...67.0 => 'D',
      60.0...63.0 => 'D-',
      0.0...60.0 => 'E',
    }

    # takes a value from 0 to 100 and returns the letter grade
    def self.to_letter(percent, round=false)
      to_grade_letter = round ? RANGE_TO_GRADE_LETTER_ROUNDED : RANGE_TO_GRADE_LETTER
      to_grade_letter.find {|range, letter| range === percent }.last
    end

    # uses RANGE_TO_GRADE_WHOLE_NUMBERS and GRADE_TO_GRADE_POINTS to calculate
    # the gpa pts of a given grade (given as 0-100).  If given a letter grade,
    # converts it to gpa points.  
    def self.to_gpa(arg, round=false)
      to_grade_letter = round ? RANGE_TO_GRADE_LETTER_ROUNDED : RANGE_TO_GRADE_LETTER
      case arg
      when String
        GRADE_LETTER_TO_GRADE_POINTS[arg.capitalize]
      when Float, Integer
        raise ArgumentError, 'percent must be between 0 and 100' unless (0..100).===(arg)
        letter = to_grade_letter.find {|range, letter| range === arg }.last
        GRADE_LETTER_TO_GRADE_POINTS[letter]
     end
    end

  end
end
