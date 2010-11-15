//
//  YLFloatingView.m
//  Nally
//
//  Created by Jjgod Jiang on 12/29/08.
//  Copyright 2008 Jjgod Jiang. All rights reserved.
//

#import "YLFloatingView.h"
#import "YLImageView.h"

@interface NSBezierPath (RoundRect)

- (void) appendBezierPathWithRoundedRect:(NSRect)rect cornerRadius: (float)radius;
+ (NSBezierPath *) bezierPathWithRoundedRect:(NSRect)rect cornerRadius: (float)radius;

@end


@implementation NSBezierPath (RoundRect)

- (void) appendBezierPathWithRoundedRect:(NSRect)rect cornerRadius: (float)radius {
    if (! NSIsEmptyRect(rect))
    {
        if (radius > 0.0) {
            // Clamp radius to be no larger than half the rect's width or height.
            float clampedRadius = MIN(radius, 0.5 * MIN(rect.size.width,  
                                                        rect.size.height));
            
            NSPoint topLeft = NSMakePoint(NSMinX(rect), NSMaxY(rect));
            NSPoint topRight = NSMakePoint(NSMaxX(rect), NSMaxY(rect));
            NSPoint bottomRight = NSMakePoint(NSMaxX(rect), NSMinY(rect));
            
            [self moveToPoint:NSMakePoint(NSMidX(rect), NSMaxY(rect))];
            [self appendBezierPathWithArcFromPoint:topLeft      
                                           toPoint:rect.origin radius:clampedRadius];
            [self appendBezierPathWithArcFromPoint:rect.origin  
                                           toPoint:bottomRight radius:clampedRadius];
            [self appendBezierPathWithArcFromPoint:bottomRight  
                                           toPoint:topRight    radius:clampedRadius];
            [self appendBezierPathWithArcFromPoint:topRight    
                                           toPoint:topLeft    radius:clampedRadius];
            [self closePath];
        } else {
            // When radius == 0.0, this degenerates to the simple case of a plain rectangle.
            [self appendBezierPathWithRect:rect];
        }
    }
}

+ (NSBezierPath *) bezierPathWithRoundedRect:(NSRect)rect cornerRadius: (float)radius 
{
    NSBezierPath *result = [NSBezierPath bezierPath];
    [result appendBezierPathWithRoundedRect:rect cornerRadius:radius];
    return result;
}

@end

@implementation YLFloatingView

- (void) drawRect: (NSRect)rect
{
    NSColor *color = [NSColor colorWithCalibratedRed: 0 
                                               green: 0 
                                                blue: 0 
                                               alpha: 1];
    [color set];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect: rect
                                                    cornerRadius: 10.0];
    [path fill];
    
    NSString *imageFile = @"HUDSave";
    if (mouseDown)
        imageFile = @"HUDSaveActive";
    NSImage *img = [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: imageFile 
                                                                                            ofType: @"tiff"]];
    [img compositeToPoint: NSMakePoint((rect.size.width - [img size].width) / 2, 
                                       (rect.size.height - [img size].height) / 2)
                operation: NSCompositeCopy];
    [img release];
}

- (void) mouseDown: (NSEvent *)event
{
    mouseDown = YES;
    [self setNeedsDisplay: YES];
}

- (void) mouseUp: (NSEvent *)event
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    YLImagePreviewer *previewer = [(YLImageView *)[self superview] previewer];

    if ([panel runModalForDirectory: nil 
                               file: [previewer filename]] == NSFileHandlingPanelOKButton)
    {
        /* BOOL ret = */ [[previewer receivedData] writeToFile: [panel filename] 
                                                    atomically: YES];
        // NSLog(@"save as %@: %s", [panel filename], ret == YES ? "done" : "failed");
    }
    
    mouseDown = NO;
    [self setNeedsDisplay: YES];
}


@end
