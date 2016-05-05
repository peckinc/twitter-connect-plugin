
#import <Foundation/Foundation.h>
#import "TwitterConnect.h"

#import <Twitter/Twitter.h>
#import <TwitterKit/TwitterKit.h>

@implementation TwitterConnect

- (void)pluginInitialize
{
    
    NSString* consumerKey = [self.commandDelegate.settings objectForKey:[@"TwitterConsumerKey" lowercaseString]];
    NSString* consumerSecret = [self.commandDelegate.settings objectForKey:[@"TwitterConsumerSecret" lowercaseString]];
    
    [[Twitter sharedInstance] startWithConsumerKey:consumerKey consumerSecret:consumerSecret];
  
}

- (void)login:(CDVInvokedUrlCommand*)command
{
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
		if (session){
			NSLog(@"signed in as %@", [session userName]);
            NSLog(@"userID %@", [session userID]);

            TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
            [client loadUserWithID:[session userID]
                                      completion:^(TWTRUser *user,
                                                   NSError *error)
            {
                if (user) {
                    NSDictionary *userSession = @{
										  @"userName": [session userName],
										  @"userId": [session userID],
										  @"secret": [session authTokenSecret],
										  @"token" : [session authToken],
										  @"name"  : user.name,
										  @"screenName" : user.screenName,
										  @"profileImageURL" : user.profileImageURL,
                                          };
                    CDVPluginResult* pir = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userSession];
                    [self.commandDelegate sendPluginResult:pir callbackId:command.callbackId];

                } else {
                    NSLog(@"Twitter error getting profile : %@", [error localizedDescription]);
                    CDVPluginResult* pir = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
                    [self.commandDelegate sendPluginResult:pir callbackId:command.callbackId];
                }
            }];

        } else {
			NSLog(@"error: %@", [error localizedDescription]);
			CDVPluginResult* pir = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
            [self.commandDelegate sendPluginResult:pir callbackId:command.callbackId];
		}
    }];
}

- (void)logout:(CDVInvokedUrlCommand*)command
{
    [[Twitter sharedInstance] logOut];
    CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
