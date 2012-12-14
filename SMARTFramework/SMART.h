/*
 SMART.h
 SMARTFramework
 
 Created by Pascal Pfiffner on 7/12/12.
 Copyright (c) 2012 Children's Hospital Boston
 
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


/**
 *  SMART Header file with constants, blocks and typedefs
 */


// Dictionary keys
extern NSString *const SMARTErrorKey;						/// Dictionaries return an NSError for this key
extern NSString *const SMARTRecordIDKey;					/// Dictionaries return an NSString for this key. The key reflects the oauth URL param name.
extern NSString *const SMARTResponseDataKey;				/// Dictionaries return the server's response as NSData for this key
extern NSString *const SMARTResponseArrayKey;				/// Dictionaries return an NSArray for this key
extern NSString *const SMARTResponseDocumentKey;			/// Dictionaries return an IndivoDocument for this key

// Other globals
extern NSString *const SMARTInternalScheme;					/// The URL scheme we use to identify when the framework should intercept a request
extern NSString *const SMARTOAuthRecordIDKey;				/// The name of the OAuth parameter carrying the record_id when we request a token

// Notifications
extern NSString *const SMARTRecordDocumentsDidChangeNotification;	/// Notifications with this name will be posted if documents did change, right AFTER the callback has been called
extern NSString *const SMARTRecordUserInfoKey;						/// For SMARTRecordDocumentsDidChangeNotification notifications, use this key on the userInfo to find the record object

/**
 *  A block returning a success flag and a user info dictionary.
 *  If success is NO, you might find an NSError object in userInfo with key "SMARTErrorKey". If no error is present, the operation was cancelled.
 */
typedef void (^SMSuccessRetvalueBlock)(BOOL success, NSDictionary * __autoreleasing userInfo);

/**
 *  A block returning a flag whether the user cancelled and an error message on failure, nil otherwise.
 *  If userDidCancel is NO and errorMessage is nil, the operation completed successfully.
 */
typedef void (^SMCancelErrorBlock)(BOOL userDidCancel, NSString * __autoreleasing errorMessage);

/// DLog only displays if -DSMART_DEBUG is set, ALog always displays output regardless of the DEBUG setting
#ifndef DLog
# ifdef SMART_DEBUG
#  define DLog(fmt, ...) NSLog((@"%s (line %d) " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
# else
#  define DLog(...) do { } while (0)
# endif
#endif
#ifndef ALog
# define ALog(fmt, ...) NSLog((@"%s (line %d) " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#endif

/// Macro to create an error in the NSCocoaErrorDomain domain
#ifndef ERR
# define ERR(p, s, c)\
	if (p != NULL && s) {\
		*p = [NSError errorWithDomain:NSCocoaErrorDomain code:(c ? c : 0) userInfo:[NSDictionary dictionaryWithObject:s forKey:NSLocalizedDescriptionKey]];\
	}\
	else {\
		DLog(@"Ignored Error: %@", s);\
	}
#endif

/// This creates an error object with NSXMLParserErrorDomain domain
#define XERR(p, s, c)\
	if (p != NULL && s) {\
		*p = [NSError errorWithDomain:NSXMLParserErrorDomain code:(c ? c : 0) userInfo:[NSDictionary dictionaryWithObject:s forKey:NSLocalizedDescriptionKey]];\
	}

/// Make callback or logging easy
#ifndef CANCEL_ERROR_CALLBACK_OR_LOG_USER_INFO
# define CANCEL_ERROR_CALLBACK_OR_LOG_USER_INFO(cb, didCancel, userInfo)\
	NSError *errorFromUserInfoInBlock = [userInfo objectForKey:SMARTErrorKey];\
	if (cb) {\
		cb(didCancel, [errorFromUserInfoInBlock localizedDescription]);\
	}\
	else if (!didCancel) {\
		DLog(@"No callback on this method, logging to debug. Error: %@", [errorFromUserInfoInBlock localizedDescription]);\
	}
#endif
#ifndef CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING
# define CANCEL_ERROR_CALLBACK_OR_LOG_ERR_STRING(cb, didCancel, errStr)\
	if (cb) {\
		cb(didCancel, errStr);\
	}\
	else if (errStr || didCancel) {\
		DLog(@"No callback on this method, logging to debug. Error: %@ (Cancelled: %d)", errStr, didCancel);\
	}
#endif
#ifndef SUCCESS_RETVAL_CALLBACK_OR_LOG_USER_INFO
# define SUCCESS_RETVAL_CALLBACK_OR_LOG_USER_INFO(cb, success, userInfo)\
	if (cb) {\
		cb(success, userInfo);\
	}\
	else if (!success) {\
		DLog(@"No callback on this method, logging to debug. Result: %@", [[userInfo objectForKey:SMARTErrorKey] localizedDescription]);\
	}
#endif
#ifndef SUCCESS_RETVAL_CALLBACK_OR_LOG_ERR_STRING
# define SUCCESS_RETVAL_CALLBACK_OR_LOG_ERR_STRING(cb, errStr, errCode)\
	if (cb) {\
		NSError *errorFromErrStrInBlock = nil;\
		if (errStr) {\
			errorFromErrStrInBlock = [NSError errorWithDomain:NSCocoaErrorDomain code:(errCode ? errCode : 0) userInfo:[NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey]];\
		}\
		cb((nil == errorFromErrStrInBlock), errorFromErrStrInBlock ? [NSDictionary dictionaryWithObject:errorFromErrStrInBlock forKey:SMARTErrorKey] : nil);\
	}\
	else if (errStr) {\
		DLog(@"No callback on this method, logging to debug. Error %d: %@", errCode, errStr);\
	}
#endif
