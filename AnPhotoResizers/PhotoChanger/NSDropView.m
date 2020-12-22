//
//  NSDropView.m
//  AnPhotoResizers
//
//  Created by Han Mingjie on 2020/10/20.
//  Copyright © 2020 MingJie Han. All rights reserved.
//

#import "NSDropView.h"
#import "NSPhotoChangerView.h"

@interface NSDropView(){
    NSMutableArray *urlsArray;
}

@end

@implementation NSDropView
-(IBAction)openFinder:(id)sender{
    if (nil == urlsArray){
        return;
    }
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:urlsArray];
    return;
}


-(id)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self){
        [self registerForDraggedTypes:@[NSPasteboardTypeFileURL]];
        self.wantsLayer = YES;
        self.layer.backgroundColor = [NSColor grayColor].CGColor;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}


-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    urlsArray = [[NSMutableArray alloc] init];
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray<Class> *classes = @[[NSURL class]];
    NSDictionary *options = @{};
    NSArray<NSURL*> *files = [pboard readObjectsForClasses:classes options:options];
    for (NSURL *url in files){
        NSString *str = [url path];
        if ([[str.pathExtension uppercaseString] isEqualToString:@"PNG"]){
            NSImage *image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:str]];
            
            NSImage *x2Image = [NSPhotoChangerView imageWithImage:image scaledToSize:CGSizeMake(2.f * image.size.width/3.f, 2.f * image.size.height/3.f)];
            NSString *name = [[str lastPathComponent] stringByReplacingOccurrencesOfString:@"@3x" withString:@"@2x"];
            NSString *targetFile = [NSHomeDirectory() stringByAppendingFormat:@"/Downloads/%@",name];
            NSURL *x2ImageURL = [[NSURL alloc] initFileURLWithPath:targetFile];
            BOOL success = [NSPhotoChangerView writeImage:x2Image into:x2ImageURL sourceSize:image.size];
            if (!success){
                NSLog(@"save error.");
            }else{
                [urlsArray addObject:x2ImageURL];
            }
            
            NSImage *x1Image = [NSPhotoChangerView imageWithImage:image scaledToSize:CGSizeMake(image.size.width/3.f, image.size.height/3.f)];
            name = [[str lastPathComponent] stringByReplacingOccurrencesOfString:@"@3x" withString:@""];
            targetFile = [NSHomeDirectory() stringByAppendingFormat:@"/Downloads/%@",name];
            NSURL *x1ImageURL = [[NSURL alloc] initFileURLWithPath:targetFile];
            success = [NSPhotoChangerView writeImage:x1Image into:x1ImageURL sourceSize:image.size];
            if (!success){
                NSLog(@"save error.");
            }else{
                [urlsArray addObject:x1ImageURL];
            }
        }
    }
    return NSDragOperationNone;
}

@end
