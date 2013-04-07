//
//  DBWrapper.h
//  CommandLineDBWrapper
//
//  Created by Adeesha on 4/4/13.
//  Copyright (c) 2013 Adeesha Ekanayake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONKit.h"

#define GETALLDATAURL @"http://mordor.adeeshaek.com/api/getall"
#define GETROWWITHIDURL @"http://mordor.adeeshaek.com/api/getrow"
#define GETTEXTWITHIDURL @"http://mordor.adeeshaek.com/api/gettext"

@interface DBWrapper : NSObject
{
    
}
#pragma mark top level methods

/**
 *	@brief	returns an array with all the buildings in the database
 *
 *	@return	array with the buildings. Element is a dictionary
 */
-(NSArray*)getAllBuildingsWithCallback:(void(^)(void))errorCallback;
/**
 *	@brief	returns a dictionary with a row corresponding to the id
 *
 *	@param 	rowId 	the id of the row
 *
 *	@return	a dictionary with the data in a row
 */
-(NSDictionary*)getRowWithRowId:(NSInteger)rowId andCallback:(void(^)(void))errorCallback;;

/**
 *	@brief	gets the text description for a given entry
 *
 *	@param 	rowId 	the row id for the entry
 *
 *	@return	the text description
 */
-(NSDictionary*)getTextWithRowId:(NSInteger)rowId andCallback:(void(^)(void))errorCallback;;


#pragma mark lower level methods

/**
 *	@brief	conducts an http request and returns the response
 *
 *	@param 	url 	url destination of the http request
 *
 *	@return	the http response
 */
-(NSString*) getHTTPDataWithUrl:(NSString*)url;

/**
 *	@brief	conducts an http request and returns the response
 *
 *	@param 	url 	url destination of the http request
 *  @param andCallback callback executed on http request error
 *
 *	@return	the http response
 */
-(NSString*) getHTTPDataWithUrl:(NSString*)url andCallback:(void(^)(void))errorCallback;

/**
 *	@brief	parses the string and returns a JSON array
 *
 *  @param dataString string to parse into JSON
 *
 *	@return	an array with the JSON data
 */
-(NSArray*)parseJSONToArray:(NSString*) dataString;


/**
 *	@brief	parses the string and returns a JSON dictionary
 *
 *	@param 	dataString 	the string to parse into JSON
 *
 *	@return	a dictionary with the JSON data
 */
-(NSDictionary*)parseJSONToDict:(NSString *)dataString;


@end


