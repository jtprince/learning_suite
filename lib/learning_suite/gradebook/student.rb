
module LearningSuite
  class Gradebook
    Student = Struct.new(:first, :last, :netid, :grades) do

      # returns a value 0-100 representing the final grade or nil if none
      # found
      def final_grade_percent
        (tot_percent, tot_points) = ["Total Percent", "Total Points"].map do |tot_cat|
          found = grades.find {|cat,val| tot_cat == cat }
          found.last if found
        end
        if tot_percent
          tot_percent.to_f * 100
        else
          tot_points.to_f
        end
      end
    end
  end
end
