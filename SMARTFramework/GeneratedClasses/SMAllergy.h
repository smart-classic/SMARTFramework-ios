/*
 SMAllergy.h
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

@class SMCodedValue, SMMedicalRecord;


/**
 *  A class representing "http://smartplatforms.org/terms#Allergy" objects, generated from smart.owl.
 */
@interface SMAllergy : SMDocument

/// Representing http://smartplatforms.org/terms#allergicReaction
@property (nonatomic, strong) SMCodedValue *allergicReaction;

/// Representing http://smartplatforms.org/terms#belongsTo
@property (nonatomic, strong) SMMedicalRecord *belongsTo;

/// Representing http://smartplatforms.org/terms#category
@property (nonatomic, strong) SMCodedValue *category;

/// Representing http://smartplatforms.org/terms#drugAllergen
@property (nonatomic, strong) SMCodedValue *drugAllergen;

/// Representing http://smartplatforms.org/terms#drugClassAllergen
@property (nonatomic, strong) SMCodedValue *drugClassAllergen;

/// Representing http://smartplatforms.org/terms#otherAllergen
@property (nonatomic, strong) SMCodedValue *otherAllergen;

/// Representing http://smartplatforms.org/terms#severity
@property (nonatomic, strong) SMCodedValue *severity;


@end
