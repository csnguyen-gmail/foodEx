#import "HFImageEditorViewController.h"

@interface HFImageEditorViewController (Private)

@property (nonatomic,strong) IBOutlet UIView<HFImageEditorFrame> *frameView;

- (void)startTransformHook;
- (void)endTransformHook;

@end


