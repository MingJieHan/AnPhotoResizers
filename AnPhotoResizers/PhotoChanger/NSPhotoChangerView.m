//
//  NSPhotoChangerView.m
//  PhotoChanger
//
//  Created by Han Mingjie on 2020/6/25.
//  Copyright © 2020 MingJie Han. All rights reserved.
//

#import "NSPhotoChangerView.h"

#define LAST_PATH_KEY @"LAST_PATH_KEY"
#define LASR_Bookmark_DATA_KEY @"LASR_Bookmark_DATA_KEY"
@interface NSPhotoChangerView(){
    
}
@property (nonatomic) IBOutlet NSButton *convert_button;
@property (nonatomic) IBOutlet NSPathCell *path_cell;
@property (nonatomic) IBOutlet NSButton *source_image_button;
@end

@implementation NSPhotoChangerView
@synthesize path_cell;
@synthesize convert_button;
@synthesize source_image_button;

-(IBAction)target_path_action:(id)sender{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"\nSelect target folder.\n All images content in this folder will be changed with source image."];
    if (path_cell && path_cell.URL){
        [panel setDirectoryURL:path_cell.URL];
    }
    panel.allowsMultipleSelection = NO;
    panel.canChooseDirectories = YES;
    panel.canChooseFiles = NO;
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        NSError *error = nil;
        if (NSModalResponseOK != result){
            return;
        }
        if (nil == panel.URL){
            return;
        }
        NSData *fileURLSecureData = [panel.URL bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
                                       includingResourceValuesForKeys:nil
                                                        relativeToURL:nil
                                                                error:&error];
        if (error) {
            NSLog(@"Error securing bookmark %@", error);
            return;
        }else{
            NSUserDefaults *use = [NSUserDefaults standardUserDefaults];
            [use setValue:[panel.URL path] forKey:LAST_PATH_KEY];
            [use setValue:fileURLSecureData forKey:LASR_Bookmark_DATA_KEY];
            [use synchronize];
        }

        self->path_cell.URL = panel.URL;
        if (self->source_image_button.image != nil){
            self->convert_button.enabled = YES;
        }
    }];
    return;
}

-(void)selectDirWithTip:(NSString *)tip{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowsMultipleSelection = NO;
    panel.canChooseDirectories = NO;
    panel.canChooseFiles = YES;
    if (tip && tip.length > 0){
        [panel setMessage:tip];
    }
    panel.allowedFileTypes = @[@"PNG",@"JPG",@"BMP",@"JPEG"];
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (NSModalResponseOK != result){
            return;
        }
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:panel.URL];
        if (nil == image){
            self->convert_button.enabled = NO;
            [self selectDirWithTip:@"Your selected file is invalid image file."];
//        }else if (image.size.width != 1024 || image.size.height != 1024){
//            self->convert_button.enabled = NO;
//            [self selectDirWithTip:@"Your selected file's size isn't 1024x1024."];
        }else{
            self->source_image_button.image = image;
            if (self->path_cell.URL != nil){
                self->convert_button.enabled = YES;
            }
        }
    }];
}

-(IBAction)source_image_button_action:(id)sender{
    [self selectDirWithTip:@"Select your source image."];
    return;
}

-(void)viewDidMoveToWindow{
    [super viewDidMoveToWindow];
    NSString *str = [[NSUserDefaults standardUserDefaults] valueForKey:LAST_PATH_KEY];
    if (str){
        path_cell.URL = [NSURL fileURLWithPath:str];
    }
}
+(BOOL)writeImage:(NSImage *)image into:(NSURL *)url sourceSize:(CGSize)sourceSize{
    NSBitmapImageRep *savedImageBitmapRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentationUsingCompression:NSTIFFCompressionNone factor:1.0]];

    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithFloat:1.0], kCGImageDestinationLossyCompressionQuality,
                                [NSNumber numberWithInteger:72], kCGImagePropertyDPIHeight,
                                [NSNumber numberWithInteger:72], kCGImagePropertyDPIWidth,
                                [NSNumber numberWithInteger:sourceSize.height],kCGImagePropertyPixelHeight,
                                [NSNumber numberWithInteger:sourceSize.width],kCGImagePropertyPixelWidth,
                                nil];

    NSMutableData *imageData = [[NSMutableData alloc] init];
    CGImageDestinationRef imageDest =  CGImageDestinationCreateWithData((CFMutableDataRef)imageData, kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(imageDest, [savedImageBitmapRep CGImage], (CFDictionaryRef)properties);
    CGImageDestinationFinalize(imageDest);
    return [imageData writeToURL:url atomically:YES];
}

+ (NSImage *)imageWithImage:(NSImage *)originalImage scaledToSize:(CGSize)desiredSize {
    NSImage *newImage = [[NSImage alloc] initWithSize:CGSizeMake(desiredSize.width/2.f, desiredSize.height/2.f)];
    [newImage lockFocus];
    [originalImage drawInRect:NSMakeRect(0, 0, desiredSize.width/2.f, desiredSize.height/2.f) fromRect:NSMakeRect(0, 0, originalImage.size.width, originalImage.size.height) operation:NSCompositingOperationSourceOver fraction:1.f];
    [newImage unlockFocus];
    return newImage;
}

-(IBAction)show_target_in_finder:(id)sender{
    NSError *error = nil;
    BOOL stale = NO;
    NSData *data =  [[NSUserDefaults standardUserDefaults] valueForKey:LASR_Bookmark_DATA_KEY];
    NSURL *target_path_url = [NSURL URLByResolvingBookmarkData:data options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:&stale error:&error];
    [target_path_url startAccessingSecurityScopedResource];
    BOOL success = [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:[target_path_url path]];
    if (!success){
        NSLog(@"open finder failed.");
    }
    return;
}

-(IBAction)convert_action:(id)sender{
    NSInteger numOfConvert = 0;
    NSImage *source_image = source_image_button.image;
    NSError *error = nil;
    
    BOOL stale;
    NSData *data =  [[NSUserDefaults standardUserDefaults] valueForKey:LASR_Bookmark_DATA_KEY];
    NSURL *target_path_url = [NSURL URLByResolvingBookmarkData:data options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:&stale error:&error];
    if (error){
        NSLog(@"load data error%@.",error);
        return;
    }
    [target_path_url startAccessingSecurityScopedResource];
    NSArray *result = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:target_path_url includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:&error];
    if (error){
        NSLog(@"load error:%@",error);
        return;
    }
    for (NSURL *url in result){
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
        if (image){
            NSImage *out_image = [NSPhotoChangerView imageWithImage:source_image scaledToSize:image.size];
            if (out_image){
                numOfConvert ++;
                [NSPhotoChangerView writeImage:out_image into:url sourceSize:source_image.size];
            }
        }
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Completed";
    alert.informativeText = [NSString stringWithFormat:@"Selected image had convert size saved into %lu images.",numOfConvert];;
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        
    }];
    return;
}

-(id)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self){
        
    }
    return self;
}


@end
