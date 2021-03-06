/*
 SMEncounter.h
 SMARTFramework
 
 Generated by build-obj-c-classes.py on 2013-06-14.
 Copyright (c) 2013 CHIP, Boston Children's Hospital
 
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

#import "SMBaseDocument.h"

@class SMCodedValue, SMMedicalRecord, SMOrganization, SMProvider;


/**
 *  A class representing "http://smartplatforms.org/terms#Encounter" objects, generated from the SMART ontology.
 */
@interface SMEncounter : SMBaseDocument

/// Representing http://smartplatforms.org/terms#belongsTo as SMMedicalRecord
@property (nonatomic, strong) SMMedicalRecord *belongsTo;

/// Representing http://smartplatforms.org/terms#encounterType as SMCodedValue
@property (nonatomic, strong) SMCodedValue *encounterType;

/// Representing http://smartplatforms.org/terms#endDate as NSString
@property (nonatomic, copy) NSString *endDate;

/// Representing http://smartplatforms.org/terms#facility as SMOrganization
@property (nonatomic, strong) SMOrganization *facility;

/// Representing http://smartplatforms.org/terms#provider as SMProvider
@property (nonatomic, strong) SMProvider *provider;

/// Representing http://smartplatforms.org/terms#startDate as NSString
@property (nonatomic, copy) NSString *startDate;


@end
