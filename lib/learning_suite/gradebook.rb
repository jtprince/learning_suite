require 'csv'
require 'date'
require 'yaml'
require 'set'

require 'learning_suite/iclicker'
require 'learning_suite/gradebook/student'
require 'learning_suite/grades'

module LearningSuite

  # NOTE: when you export scores, make sure to also check 'Points'!!!!
  # (this should be in addition to Percent)
  class Gradebook
    OUTFILE = "gb.csv"
    NET_ID = "Net ID"

    FIRST=0
    LAST=1
    NETID=2

    attr_accessor :init_filename
    attr_accessor :students
    attr_accessor :students_by_netid

    def initialize(csv)
      @init_filename = csv
      @students = csv_to_students(csv)
      @students_by_netid = {}
      @students.each do |student|
        @students_by_netid[student.netid] = student
      end
    end

    # nil -> nil, '' -> nil, everything else to_f
    def csv_to_f(val)
      if val
        ( val == '' ? nil : val.to_f )
      end
    end

    # takes an array of header items and returns the 3 key indices
    def first_last_netid_indices(header)
      [/First|Preferred/i, /Last/i, /Net ID/i].map do |re|
        header.index {|ar| re.match(ar) }
      end
    end

    def csv_to_students(csv)
      rows = CSV.read(csv)
      header = rows.shift
      rows.map do |row|
        student = Student.new( row[FIRST], row[LAST], row[NETID] )
        student.grades = Hash[ header[3..-1].zip( row[3..-1] ).map.to_a ]

        non_nil_grades = {}
        student.grades.each do |k,v|
          non_nil_grades[k] = csv_to_f(v) 
        end
        student.grades = non_nil_grades
        student
      end
    end

    def bad_date_string_to_date_obj(string)
      parts = string.split('/')
      Date.parse([parts[2], parts[0], parts[1]].join("-"))
    end

    def iclicker_date_to_assignment_hash(hash_or_yamlfile)
      date_to_assignment = 
        if hash_or_yamlfile.is_a?(Hash)
          hash_or_yamlfile
        else
          YAML.load_file(hash_or_yamlfile)
        end
      Hash[ date_to_assignment.map {|k,v| [bad_date_string_to_date_obj(k), v] } ]
    end

    def better_grade(a, b)
      if a && b
        [a,b].max 
      else
        a ? a : b
      end
    end

    def default_if_gt_zero(val, default)
      if val && val > 0 && default
        default
      else
        val
      end
    end

    def curve_final_grade!(target_gpa, type=:flat, adjust_letters=true)
      @students.each do |student|
        p student.grades
        abort 'here'
      end
    end

    #def curve_exam(exam_number, exams_fraction_of_score=0.6, exam_re=/Exam/i)
      #@students.each do |student| 
        #exams = student.grades.keys.select {|k| k =~ exam_re }
        #exam_grade_doublets = student.grades.select {|exam, val| !val.nil? }
        #p exam_grade_doublets.map(&:last).reduce(:+)
        #abort 'here'
      #end
    #end

    def class_gpa(round_up=true, add=0.0)
      gpas = @students.map do |s| 
        adjusted = s.final_grade_percent + add
        adjusted = 100.0 if adjusted > 100
        adjusted = 0 if adjusted < 0
        LearningSuite::Grades.to_gpa(adjusted, round_up) 
      end
        
      gpas.reduce(:+) / @students.size
    end

    # returns the curve amount and the gpa that gives
    def curve_final_grade(target_gpa, type=:flat, round_up=true)
      final_grade_percent_ar = @students.map(&:final_grade_percent)
      prev_gpa = nil
      prev_add = nil
      (0..20.0).step(0.1) do |add|
        cgpa = class_gpa(round_up, add)
        return [prev_add, prev_gpa] if cgpa > target_gpa
        prev_gpa = cgpa
        prev_add = add
      end
      [nil, nil]
    end

    def fill_scores!(score=0.0)
      @students.each do |student|
        grades = student.grades
        grades.each do |assignment, val|
          grades[assignment] = score if val.nil?
        end
      end
    end

    # merges iclicker scores with the current csv; if default_points is
    # present, coerces anything > 0 to be default points; removes all grades
    # except those found as values in the date_to_assignment hash/file.
    def merge_iclicker!(iclicker_csv, date_to_assignment, default_points=nil)
      default = default_points
      date_to_assignment = iclicker_date_to_assignment_hash(date_to_assignment)

      # TODO: remove the default_if_gt_zero redundancy

      iclicker_rows = CSV.read(iclicker_csv)
      iclicker_header = iclicker_rows.shift
      iclicker_dates = iclicker_header[2..-1]
      iclicker_rows.each do |row|
        student = students_by_netid[row[0]]
        if student
          iclicker_dates.zip(row[2..-1]) do |date_string, igrade|
            igrade = csv_to_f(igrade)
            date_obj = bad_date_string_to_date_obj(date_string)
            assignment = date_to_assignment[date_obj]
            previous_grade = student.grades[assignment]
            to_record = better_grade(previous_grade, default_if_gt_zero(igrade, default))
            student.grades[assignment] = default_if_gt_zero(to_record, default)
          end
        end
      end
      iclicker_assignments = Set.new(date_to_assignment.values)
      students.each do |student|
        sgrades = student.grades
        sgrades.each do |k,v|
          unless iclicker_assignments.include?(k)
            sgrades.delete(k) 
          end
        end
      end
      remove_empty_assignments!
      self
    end

    def remove_empty_assignments!
      ea = empty_assignments
      students.each do |student|
        sgrades = student.grades
        ea.each do |empty_assign|
          sgrades.delete empty_assign
        end
      end
    end

    # returns a Set of empty assignments (no students have scores)
    def empty_assignments
      assignment_to_scores = Hash.new {|h,k| h[k] = [] }
      students.each do |student|
        student.grades.each do |assignment, score|
          assignment_to_scores[assignment] << score
        end
      end
      a_to_s = Hash[ assignment_to_scores.map {|k,v| [k, v.compact] } ]
      a_to_s.select {|k,v| v.size == 0 }.map(&:first)
    end

    def write_file(outfile=OUTFILE, no_empty_rows=true)
      CSV.open(outfile, 'w') do |csv|
        header = ["First Name", "Last Name", "Net ID"]
        csv << header.push(*@students.first.grades.keys)
        students.each do |student|
          data = [:first, :last, :netid].map {|v| student.send(v) }
          csv << data.push(*student.grades.values)
        end
      end
    end

    # writes the roster file needed for iclicker to work
    def write_roster(outfile=LearningSuite::Iclicker::ROSTER)
      File.open(outfile, 'w') do |out|
        students.each do |student|
          out.print [student.last, student.first, student.netid].join(", "), "\r\n"
        end
      end
      puts "wrote: #{outfile}" if $VERBOSE
    end
  end
end
