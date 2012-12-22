require 'spec_helper'

require 'learning_suite/grades'

describe LearningSuite::Grades do
  it 'converts a percent to grade points' do
    LearningSuite::Grades.to_gpa(98.0).should == 4
    LearningSuite::Grades.to_gpa(70.0).should == 1.7
  end

  it 'raises an error for bad values' do
    lambda { LearningSuite::Grades.to_gpa(11000.0) }.should raise_error
  end

  it 'converts letter grades to grade points' do
    LearningSuite::Grades.to_gpa('D+').should == 1.4
  end

end
