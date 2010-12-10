//
//  YLImagePreviewer.m
//  Nally
//
//  Created by Jjgod Jiang on 2/17/08.
//  Copyright 2008 Jjgod Jiang. All rights reserved.
//

#import "CommonType.h"
#import "YLSite.h"
#import "YLImagePreviewer.h"
#import "YLImageView.h"

@interface NSHTTPURLResponse (Corrected)
- (NSString *) correctedFileNameWithEncoding: (NSStringEncoding) encoding;
@end

@implementation NSHTTPURLResponse (Corrected)

- (NSString *) correctedFileNameWithEncoding: (NSStringEncoding) encoding
{
    NSString *fileName = nil, *disposition;

    disposition = [[self allHeaderFields] objectForKey: @"Content-Disposition"];
    if (! disposition)
        return [self suggestedFilename];

    NSRange start = [disposition rangeOfString: @"filename="];
    if (start.location != NSNotFound)
        fileName = [disposition substringFromIndex: start.location + start.length];

    if (fileName)
    {
        int i, max = [fileName length];
        char *nbytes = (char *) malloc(max + 1);

        for (i = 0; i < max; i++)
        {
            unichar ch = [fileName characterAtIndex: i];
            nbytes[i] = (char) ch;
        }

        nbytes[i] = '\0';

        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *str = [NSString stringWithCString: nbytes
                                           encoding: enc];
        free(nbytes);

        return str;
    }

    return nil;
}

@end


@implementation YLImagePreviewer

- (id) initWithURL: (NSURL *) url
{
    if ([super init])
    {
        // create the request
        NSURLRequest *request = [NSURLRequest requestWithURL: url
                                                 cachePolicy: NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval: 60.0];
        
        // create the connection with the request
        // and start loading the data
        _connection = [[NSURLConnection alloc] initWithRequest: request 
                                                      delegate: self];
        if (_connection)
        {
            // Create the NSMutableData that will hold
            // the received data
            // receivedData is declared as a method instance elsewhere
            _receivedData = [[NSMutableData data] retain];
            
            [self showLoadingWindow];
        } else {
            // inform the user that the download could not be made
            NSLog(@"inform the user that the download could not be made");
        }        
    }
    
    return self;
}

- (void) dealloc
{
    // NSLog(@"dealloc everything in YLImagePreviewer");
    
    // if we are still connecting, should cancel now and release
    // related resource.
    if (_connection)
    {
        [_connection cancel];
        [self releaseConnection];
    }

    [_window release];

    [super dealloc];
}

- (void) windowWillClose: (NSNotification *) notification
{
    if ([_window isReleasedWhenClosed])
        _window = nil;
    
    [self autorelease];
}

- (void) showLoadingWindow
{
    unsigned int style = NSTitledWindowMask | 
        NSMiniaturizableWindowMask | NSClosableWindowMask | 
        NSHUDWindowMask | NSUtilityWindowMask;

    _window = [[NSPanel alloc] initWithContentRect: NSMakeRect(0, 0, 400, 30)
                                         styleMask: style
                                           backing: NSBackingStoreBuffered 
                                             defer: NO];
    [_window setFloatingPanel: NO];
    [_window setDelegate: self];
    [_window setOpaque: YES];
    [_window center];
    [_window setTitle: @"Loading..."];
    [_window setViewsNeedDisplay: NO];
    [_window makeKeyAndOrderFront: nil];
    
    _indicator = [[HMBlkProgressIndicator alloc] initWithFrame: NSMakeRect(10, 10, 380, 10)];
    [[_window contentView] addSubview: _indicator];
    // [_indicator release];

    [_indicator startAnimation: self];
}

- (void) showImage: (NSImage *) image 
         withTitle: (NSString *) title 
          tiffData: (NSDictionary *) tiffData
{
    YLImageView *view;
    NSImageRep *rep = [[image representations] objectAtIndex: 0];
    NSSize size = NSMakeSize([rep pixelsWide], [rep pixelsHigh]);
    NSSize visibleSize = [[NSScreen mainScreen] visibleFrame].size;
    NSSize viewSize = [[_window contentView] frame].size;
    NSSize frameSize = [_window frame].size;

    visibleSize.width -= 20;
    visibleSize.height -= 20;
    
    NSPoint origin = [[NSScreen mainScreen] visibleFrame].origin;
    
    double aspect = size.height / size.width;
    // Do some auto resizing in case the image size is too large
    if (size.width > visibleSize.width)
    {
        size.width = visibleSize.width;
        size.height = aspect * size.width;
    }

    if (size.height > visibleSize.height)
    {
        size.height = visibleSize.height;
        size.width = size.height / aspect;
    }
    
    origin.x += ([[NSScreen mainScreen] visibleFrame].size.width - size.width) / 2;
    
    // use Golden Ratio to place the window vertically
    origin.y += ([[NSScreen mainScreen] visibleFrame].size.height - size.height) / 1.61803399;
    
    [image setSize: size];
    // NSLog(@"image size: %g %g", size.width, size.height);
    
    [_window setTitle: title];
    
    NSRect viewRect = NSMakeRect(0, 0, size.width, size.height);
    view = [[YLImageView alloc] initWithFrame: viewRect previewer: self];
    
    [_indicator removeFromSuperview];
    [_indicator release];
    
    [[_window contentView] addSubview: view];
    [_window makeFirstResponder: view];
    [_window setAcceptsMouseMovedEvents: YES];
    [view release];

    [view setImage: image];
    [view setTiffData: tiffData];
    [image release];

    [_window setFrame: NSMakeRect(origin.x, origin.y,
                                  size.width + frameSize.width - viewSize.width,
                                  size.height + frameSize.height - viewSize.height)
              display: YES 
              animate: YES];
}

NSStringEncoding encodingFromYLEncoding(YLEncoding ylenc)
{
    CFStringEncoding cfenc = kCFStringEncodingBig5_HKSCS_1999;;
    
    switch (ylenc)
    {
        case YLGBKEncoding:
            cfenc = kCFStringEncodingGB_18030_2000;
            break;
            
        case YLBig5Encoding:
            cfenc = kCFStringEncodingBig5_HKSCS_1999;
            break;
    }
    
    return CFStringConvertEncodingToNSStringEncoding(cfenc);
}

- (void) connection: (NSURLConnection *) connection 
 didReceiveResponse: (NSURLResponse *) response
{
    /* FIXME: a hack to retrieve the correct file name, we need better
     *        ways to determine whether we need this hack or not, and
     *        which encoding to apply
     */
    NSString *fileName = [(NSHTTPURLResponse *) response correctedFileNameWithEncoding:
                            encodingFromYLEncoding(YLGBKEncoding)];

    if (fileName)
        _currentFileDownloading = [fileName retain];
    
    _totalLength = [response expectedContentLength];

    [_window setTitle: [NSString stringWithFormat: @"Loading %@...", _currentFileDownloading]];
    [_indicator setIndeterminate: NO];
    [_indicator setMaxValue: (double) _totalLength];
    [_indicator setDoubleValue: 0];

    [_receivedData setLength: 0];
}

- (void) connection: (NSURLConnection *) connection 
     didReceiveData: (NSData *) data
{
    // NSLog(@"didReceiveData: %d bytes", [data length]);
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [_receivedData appendData: data]; 
    [_indicator incrementBy: (double) [data length]];
}

- (void)connection: (NSURLConnection *) connection
  didFailWithError: (NSError *) error
{
    [self releaseConnection];

    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey: NSErrorFailingURLStringKey]);
}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    // NSLog(@"Succeeded! Received %d bytes of data", [_receivedData length]);
    
    [_indicator setDoubleValue: (double) [_receivedData length]];
    
    CGImageSourceRef exifSource = CGImageSourceCreateWithData((CFDataRef) _receivedData, NULL);
    NSDictionary *metaData = (NSDictionary*) CGImageSourceCopyPropertiesAtIndex(exifSource, 0, nil);
    NSDictionary *tiffData = [metaData objectForKey: (NSString *) kCGImagePropertyTIFFDictionary];

    CFRelease(exifSource);
	[metaData release];

    NSImage *image = [[NSImage alloc] initWithData: _receivedData];
    if (image == nil || [[image representations] count] == 0)
    {
        NSString *text = [NSString stringWithFormat: @"Failed to download file %@", _currentFileDownloading];
        NSAlert *alert = [NSAlert alertWithMessageText: @"Failed to download image." 
                                         defaultButton: @"OK" 
                                       alternateButton: nil 
                                           otherButton: nil 
                             informativeTextWithFormat: text];
        [alert runModal];
    }
    else
        [self showImage: image 
              withTitle: _currentFileDownloading 
               tiffData: tiffData];

    // [self releaseConnection];
}

- (void) releaseConnection
{
    [_connection release];
    _connection = nil;

    [_receivedData release];
    _receivedData = nil;
    
    [_currentFileDownloading release];
    _currentFileDownloading = nil;
}

- (NSMutableData *) receivedData
{
    return _receivedData;
}

- (NSString *) filename
{
    return _currentFileDownloading;
}

@end
