/*
 SMProblem.h
 SMARTFramework
 
 Generated by build-obj-c-classes.py on 2012-10-01.
 Copyright (c) 2012 CHIP, Boston Children's Hospital
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#import "SMDocument.h"

@class SMCodedValue, SMEncounter, SMMedicalRecord;


/**
 *  A class representing "http://smartplatforms.org/terms#Problem" objects, generated from smart.owl.
 */
@interface SMProblem : SMDocument

/// Representing http://smartplatforms.org/terms#belongsTo
@property (nonatomic, strong) SMMedicalRecord *belongsTo;

/// Representing http://smartplatforms.org/terms#encounters
@property (nonatomic, copy) NSArray *encounters;

/// Representing http://smartplatforms.org/terms#endDate
@property (nonatomic, copy) NSString *endDate;

/// Representing http://smartplatforms.org/terms#notes
@property (nonatomic, copy) NSString *notes;

/// Representing http://smartplatforms.org/terms#problemName
@property (nonatomic, strong) SMCodedValue *problemName;

/// Representing http://smartplatforms.org/terms#problemStatus
@property (nonatomic, strong) SMCodedValue *problemStatus;

/// Representing http://smartplatforms.org/terms#startDate
@property (nonatomic, copy) NSString *startDate;


@end
