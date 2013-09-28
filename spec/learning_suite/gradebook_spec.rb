require 'spec_helper'

require 'learning_suite/gradebook'

describe LearningSuite::Gradebook do
  before(:all) do
    @gbcsv = TESTFILES + "/Grades.csv"
    @iclicker_csv = TESTFILES + "/iclicker_481_120918_all.csv"
    @date_to_name = TESTFILES + "/date_to_assignment_name.yml"
  end

  it 'is initialized with students' do
    gb = LearningSuite::Gradebook.new(@gbcsv)
    gb.students.first.grades.size.should == 63
    gb.students.size.should == 4
    File.basename(gb.init_filename).should == "Grades.csv"
  end

  it 'can create a roster for iclicker upload' do
    outfile = TESTFILES + "/roster.tmp.csv"
    gb = LearningSuite::Gradebook.new(@gbcsv)
    gb.write_roster(outfile)
    File.exist?(outfile).should be_true
    lines = IO.readlines(outfile)
    lines.size.should == 4
    lines.first.chomp.should == 'Parker, Peter, pparker222'
    lines.last.chomp.should == 'Bartok, Rudolph, rbartok'
    File.unlink(outfile)
  end

  it 'can merge in iclicker scores' do
    outfile = TESTFILES + "/iclicker.merged.tmp.csv"
    gb = LearningSuite::Gradebook.new(@gbcsv)
    gb.merge_iclicker!(@iclicker_csv, @date_to_name) 
    gb.write_file(outfile)
    File.exist?(outfile).should be_true
    lines = IO.readlines(outfile)
    lines.first.should == "First Name,Last Name,Net ID,p 1,p 3,p 4,p 5,p 6,p 7,p 8\n"
    lines.size.should == 5
    lines[1].should == "Peter,Parker,pparker222,0.0,0.0,0.0,0.0,0.0,0.0,0.0\n"
    lines[4].should == "Rudolph,Bartok,rbartok,1.0,0.0,2.0,2.0,2.0,2.0,2.0\n"
    File.unlink(outfile)
  end

end

# learning suite doesn't export final grades yet, so use official
# gradebook.byu.edu to export this
describe 'official Gradebook export of final grades' do

  before(:all) do
    @gbcsv = TESTFILES + "/gradebook_export_of_final_grades.csv"
  end

  it 'can curve final scores' do
    gb = LearningSuite::Gradebook.new(@gbcsv)
    gb.curve_final_grade(3.1, :flat)
  end
end
