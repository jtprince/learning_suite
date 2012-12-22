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
    lines.first.should == "First Name,Last Name,Net ID,p 1,p 10,p 11,p 12,p 13,p 14,p 15,p 16,p 17,p 18,p 19,p 2,p 20,p 21,p 22,p 23,p 24,p 25,p 26,p 27,p 28,p 29,p 3,p 30,p 31,p 32,p 33,p 34,p 35,p 36,p 37,p 38,p 39,p 4,p 40,p 41,p 5,p 6,p 7,p 8,p 9\n"
    lines.size.should == 5
    lines[1].should == "Peter,Parker,pparker222,0.0,,,,,,,,,,,,,,,,,,,,,,0.0,,,,,,,,,,,0.0,,,0.0,0.0,0.0,0.0,\n"
    lines[4].should == "Rudolph,Bartok,rbartok,1.0,,,,,,,,,,,,,,,,,,,,,,0.0,,,,,,,,,,,2.0,,,2.0,2.0,2.0,2.0,\n"
    File.unlink(outfile)
  end
end
