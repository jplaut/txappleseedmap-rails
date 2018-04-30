class Statistic < ApplicationRecord
  VALID_TYPES = {
    EXP: 'ExpulsionAction',
    DAE: 'AlternativePlacement',
    ISS: 'InSchoolSuspension',
    OSS: 'OutOfSchoolSuspension'
  }.with_indifferent_access.freeze

  validates_presence_of :district_id, :ethnicity_id, :year, :relative_percentage, :total_population

  belongs_to :district
  belongs_to :ethnicity
end
