//
//  AppDelegate.m
//  PhotoChanger
//
//  Created by Han Mingjie on 2020/6/25.
//  Copyright © 2020 MingJie Han. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//    NSScreen *s = [[NSScreen alloc] init];
//    s.mainScreen
    return;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{
    [[NSApp windows].firstObject makeKeyAndOrderFront:self];
    return YES;
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}
@end
