#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate, WKScriptMessageHandler>
@property (strong) NSWindow *window;
@property (strong) WKWebView *webView;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)note {
    // ─── Window ───
    NSRect rect = NSMakeRect(0, 0, 1200, 800);
    self.window = [[NSWindow alloc]
        initWithContentRect:rect
        styleMask:NSWindowStyleMaskTitled |
                  NSWindowStyleMaskClosable |
                  NSWindowStyleMaskMiniaturizable |
                  NSWindowStyleMaskResizable |
                  NSWindowStyleMaskFullSizeContentView
        backing:NSBackingStoreBuffered
        defer:NO];

    self.window.titlebarAppearsTransparent = YES;
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.movableByWindowBackground = YES;
    self.window.backgroundColor = [NSColor blackColor];
    self.window.minSize = NSMakeSize(400, 300);
    [self.window center];

    // ─── WKWebView ───
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.preferences setValue:@YES forKey:@"developerExtrasEnabled"];

    // Add message handler for native file save
    WKUserContentController *ucc = [[WKUserContentController alloc] init];
    [ucc addScriptMessageHandler:(id)self name:@"saveFile"];
    [ucc addScriptMessageHandler:(id)self name:@"pasteFromClipboard"];

    // Inject native flag so JS knows we're in the native app
    WKUserScript *nativeScript = [[WKUserScript alloc]
        initWithSource:@"window.__isNativeApp = true;"
        injectionTime:WKUserScriptInjectionTimeAtDocumentStart
        forMainFrameOnly:YES];
    [ucc addUserScript:nativeScript];

    config.userContentController = ucc;

    self.webView = [[WKWebView alloc]
        initWithFrame:self.window.contentView.bounds
        configuration:config];
    self.webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;

    [self.window.contentView addSubview:self.webView];

    // ─── Load HTML from bundle ───
    NSString *htmlPath = [[NSBundle mainBundle]
        pathForResource:@"index" ofType:@"html"
        inDirectory:@"Web"];
    if (htmlPath) {
        NSURL *url = [NSURL fileURLWithPath:htmlPath];
        [self.webView loadFileURL:url
            allowingReadAccessToURL:[url URLByDeletingLastPathComponent]];
    } else {
        NSLog(@"⚠️ index.html not found in bundle");
    }

    self.window.delegate = (id)self;
    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

// Allow web permissions (camera, mic, screen)
- (void)webView:(WKWebView *)webView
    requestMediaCapturePermissionForOrigin:(WKSecurityOrigin *)origin
    initiatedByFrame:(WKFrameInfo *)frame
    type:(WKMediaCaptureType)type
    decisionHandler:(void (^)(WKPermissionDecision))decisionHandler {
    decisionHandler(WKPermissionDecisionGrant);
}

// ─── Native file save via JS bridge ───
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"saveFile"]) {
        NSDictionary *body = message.body;
        NSString *base64 = body[@"data"];
        NSString *filename = body[@"filename"] ?: @"recording.mp4";

        NSData *fileData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
        if (!fileData) return;

        NSString *dlDir = [@"~/Downloads" stringByExpandingTildeInPath];
        NSString *path = [dlDir stringByAppendingPathComponent:filename];

        // Avoid overwriting — append number if exists
        NSString *base = [filename stringByDeletingPathExtension];
        NSString *ext = [filename pathExtension];
        int n = 1;
        while ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            path = [dlDir stringByAppendingPathComponent:
                [NSString stringWithFormat:@"%@-%d.%@", base, n, ext]];
            n++;
        }

        [fileData writeToFile:path atomically:YES];
        NSLog(@"✅ Saved: %@", path);

        if ([[path pathExtension].lowercaseString isEqualToString:@"webm"]) {
            NSString *mp4Path = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp4"];
            NSString *ffmpegPath = @"/opt/homebrew/bin/ffmpeg";
            BOOL hasFFmpeg = [[NSFileManager defaultManager] isExecutableFileAtPath:ffmpegPath];
            NSTask *task = [[NSTask alloc] init];
            if (hasFFmpeg) {
                task.launchPath = ffmpegPath;
                task.arguments = @[@"-y", @"-i", path, @"-c:v", @"libx264", @"-preset", @"slow", @"-crf", @"12", @"-pix_fmt", @"yuv420p", @"-movflags", @"+faststart", mp4Path];
            } else {
                task.launchPath = @"/usr/bin/avconvert";
                task.arguments = @[@"-i", path, @"-o", mp4Path, @"-f", @"mp4"];
            }
            @try {
                [task launch];
                [task waitUntilExit];
                if (task.terminationStatus == 0) {
                    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                    NSLog(@"✅ Converted MP4: %@", mp4Path);
                } else {
                    NSLog(@"⚠️ MP4 conversion failed, kept WebM: %@", path);
                }
            } @catch (NSException *exception) {
                NSLog(@"⚠️ MP4 converter unavailable, kept WebM: %@", path);
            }
        }
    } else if ([message.name isEqualToString:@"pasteFromClipboard"]) {
        NSPasteboard *pb = [NSPasteboard generalPasteboard];
        NSArray *objects = [pb readObjectsForClasses:@[[NSImage class]] options:@{}];
        NSImage *image = objects.count > 0 ? objects.firstObject : nil;

        if (image) {
            NSData *tiffData = [image TIFFRepresentation];
            NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:tiffData];
            NSData *pngData = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
            NSString *base64 = [pngData base64EncodedStringWithOptions:0];
            NSString *js = [NSString stringWithFormat:@"window.__nativePasteImage('data:image/png;base64,%@')", base64];
            [self.webView evaluateJavaScript:js completionHandler:nil];
            return;
        }

        NSString *text = [pb stringForType:NSPasteboardTypeString];
        if (text.length > 0) {
            NSString *escaped = [text stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
            escaped = [escaped stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            escaped = [escaped stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
            NSString *js = [NSString stringWithFormat:@"window.__nativePasteText('%@')", escaped];
            [self.webView evaluateJavaScript:js completionHandler:nil];
        }
    }
}

// ─── Navigation: handle downloads ───
- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
    decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if ([navigationResponse canShowMIMEType]) {
        decisionHandler(WKNavigationResponsePolicyAllow);
    } else {
        decisionHandler(WKNavigationResponsePolicyDownload);
    }
}

// ─── Download delegate: save to ~/Downloads ───
- (void)webView:(WKWebView *)webView
    navigationResponse:(WKNavigationResponse *)navigationResponse
    didBecomeDownload:(WKDownload *)download {
    download.delegate = (id)self;
}

- (void)download:(WKDownload *)download
    decideDestinationUsingResponse:(NSURLResponse *)response
    suggestedFilename:(NSString *)suggestedFilename
    completionHandler:(void (^)(NSURL *destination))completionHandler {

    NSString *dlDir = [@"~/Downloads" stringByExpandingTildeInPath];
    NSString *filename = suggestedFilename ?: @"download";
    NSString *path = [dlDir stringByAppendingPathComponent:filename];

    // Avoid overwriting
    NSString *base = [filename stringByDeletingPathExtension];
    NSString *ext = [filename pathExtension];
    int n = 1;
    while ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = [dlDir stringByAppendingPathComponent:
            [NSString stringWithFormat:@"%@-%d.%@", base, n, ext]];
        n++;
    }

    completionHandler([NSURL fileURLWithPath:path]);
}

- (void)downloadDidFinish:(WKDownload *)download {
    NSLog(@"✅ Download saved to ~/Downloads");
}

- (void)download:(WKDownload *)download
    didFailWithError:(NSError *)error
    resumeData:(NSData *)resumeData {
    NSLog(@"❌ Download failed: %@", error.localizedDescription);
}

@end

int main() {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        [app setDelegate:[[AppDelegate alloc] init]];
        [app run];
    }
    return 0;
}
