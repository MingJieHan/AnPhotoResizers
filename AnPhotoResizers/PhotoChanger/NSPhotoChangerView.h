//
//  NSPhotoChangerView.h
//  PhotoChanger
//
//  Created by Han Mingjie on 2020/6/25.
//  Copyright © 2020 MingJie Han. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPhotoChangerView : NSView
+(BOOL)writeImage:(NSImage *)image into:(NSURL *)url sourceSize:(CGSize)sourceSize;
+ (NSImage *)imageWithImage:(NSImage *)originalImage scaledToSize:(CGSize)desiredSize;
@end

NS_ASSUME_NONNULL_END
