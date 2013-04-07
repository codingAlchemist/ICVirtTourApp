//
//  DBWrapper.m
//  CommandLineDBWrapper
//
//  Created by Adeesha on 4/4/13.
//  Copyright (c) 2013 Adeesha Ekanayake. All rights reserved.
//

#import "DBWrapper.h"

@implementation DBWrapper

-(NSArray*)getAllBuildingsWithCallback:(void(^)(void))errorCallback;
{
    //test - call getHTTPData, parse it and send out result
    NSString* HTTPResponse = [self getHTTPDataWithUrl:GETALLDATAURL andCallback:^
                              {
                                  errorCallback();
                              }];
    NSArray* buildings = [self parseJSONToArray:HTTPResponse];
    
    return buildings;
}

-(NSDictionary*)getRowWithRowId:(NSInteger)rowId andCallback:(void(^)(void))errorCallback;
{
    NSString *url = [[NSString alloc] initWithFormat:@"%@?id=%ld",GETROWWITHIDURL, (long)rowId];
    
    NSString* HTTPResponse = [self getHTTPDataWithUrl:url andCallback:^
                              {
                                  errorCallback();
                              }];
    NSArray* row = [self parseJSONToArray:HTTPResponse];
    NSDictionary* output = [row objectAtIndex:0];
    
    /*
    for (int i=0; i<row.count; i++)
    {
        NSLog(@"%@",[row objectAtIndex:i]);
    }
    */
    
    return output;
}

-(NSDictionary*)getTextWithRowId:(NSInteger)rowId andCallback:(void(^)(void))errorCallback;
{
    NSString* url = [[NSString alloc] initWithFormat:@"%@?id=%ld",GETTEXTWITHIDURL, (long)rowId];
    
    NSString* HTTPResponse = [self getHTTPDataWithUrl:url andCallback:^
                              {
                                  errorCallback();
                              }];

    NSArray* responseArray = [self parseJSONToArray:HTTPResponse];
    NSDictionary* output = [responseArray objectAtIndex:0];
    
    //NSLog(@"%@",[output allValues]);
    
    return output;
}


-(NSString*)getHTTPDataWithURL:(NSString*)url
{
    NSString* theData;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        //NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        
        //if you need to use a callback method here, use the getHTTPDataWithCallback method
        NSLog(@"Error with JSON request"); //call the error handler
        
        return nil;
    }
    else{
        NSString* output = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
        theData = output;
    }
    
    return theData;
}

-(NSString*)getHTTPDataWithUrl:(NSString*)url andCallback:(void (^)(void))errorCallback
{
    NSString* theData;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        //NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        
        errorCallback(); //call the error handler
        
        return nil;
    }
    else{
        NSString* output = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
        theData = output;
    }
    
    return theData;
}

-(NSDictionary*)parseJSONToDict:(NSString *)dataString
{
    NSDictionary* output = [dataString objectFromJSONString];
    return output;
}

-(NSArray*)parseJSONToArray:(NSString *)dataString
{
    NSArray* output = [dataString objectFromJSONString];
    return output;
}


@end
