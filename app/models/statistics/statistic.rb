class Statistic < ApplicationRecord
  VALID_TYPES = {
    EXP: 'ExpulsionAction',
    DAE: 'AlternativePlacement',
    ISS: 'InSchoolSuspension',
    OSS: 'OutOfSchoolSuspension'
  }

  validates_presence_of :district_id, :ethnicity_id, :year, :relative_percentage, :total_population

  belongs_to :district
  belongs_to :ethnicity
end
