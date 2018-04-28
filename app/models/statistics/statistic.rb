class Statistic < ApplicationRecord
  VALID_TYPES = {
    EXP: 'ExpulsionAction',
    DAE: 'AlternativePlacement',
    ISS: 'InSchoolSuspension',
    OSS: 'OutOfSchoolSuspension'
  }

  belongs_to :district
  belongs_to :ethnicity
end
