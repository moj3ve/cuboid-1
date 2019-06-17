#import "CBDManager.h"
#import "Tweak.h"

@implementation CBDManager

+(instancetype)sharedInstance {
	static CBDManager *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [CBDManager alloc];
		sharedInstance.defaults = [NSUserDefaults standardUserDefaults];
		sharedInstance.savedLayouts = [NSMutableDictionary new];
		[sharedInstance load];
	});
	return sharedInstance;
}

-(id)init {
	return [CBDManager sharedInstance];
}

-(void)load {
	self.hideIconLabels = [self.defaults boolForKey:@"hideIconLabels"];
	self.homescreenColumns = [self.defaults integerForKey:@"homescreenColumns"];
	self.homescreenRows = [self.defaults integerForKey:@"homescreenRows"];
	self.verticalOffset = [self.defaults floatForKey:@"verticalOffset"];
	self.horizontalOffset = [self.defaults floatForKey:@"horizontalOffset"];
	self.verticalPadding = [self.defaults floatForKey:@"verticalPadding"];
	self.horizontalPadding = [self.defaults floatForKey:@"horizontalPadding"];

	NSDictionary *savedLayouts = [self.defaults objectForKey:@"savedLayouts"];
	if (savedLayouts && [savedLayouts isKindOfClass:[NSDictionary class]]) {
		self.savedLayouts = [savedLayouts mutableCopy];
	}
}

-(void)save {
	[self.defaults setBool:self.hideIconLabels forKey:@"hideIconLabels"];
	[self.defaults setInteger:self.homescreenColumns forKey:@"homescreenColumns"];
	[self.defaults setInteger:self.homescreenRows forKey:@"homescreenRows"];
	[self.defaults setFloat:self.verticalOffset forKey:@"verticalOffset"];
	[self.defaults setFloat:self.horizontalOffset forKey:@"horizontalOffset"];
	[self.defaults setFloat:self.verticalPadding forKey:@"verticalPadding"];
	[self.defaults setFloat:self.horizontalPadding forKey:@"horizontalPadding"];
	[self.defaults setObject:self.savedLayouts forKey:@"savedLayouts"];
	[self.defaults synchronize];
}

-(void)reset {
	self.hideIconLabels = 0;
	self.homescreenColumns = 0;
	self.homescreenRows = 0;
	self.verticalOffset = 0;
	self.horizontalOffset = 0;
	self.verticalPadding = 0;
	self.horizontalPadding = 0;
	[self save];
	[self relayoutAll];
}

-(void)relayout {
	SBIconController *iconController = [NSClassFromString(@"SBIconController") sharedInstance];
	SBRootIconListView *listView = [iconController rootIconListAtIndex:[iconController currentIconListIndex]];
	[UIView animateWithDuration:(0.15) delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		[listView layoutIconsNow];
	} completion:NULL];
}

-(void)relayoutAll {
	SBIconController *iconController = [NSClassFromString(@"SBIconController") sharedInstance];
	[iconController relayout];
	[self.view.superview bringSubviewToFront:self.view];
}

-(void)loadLayoutWithName:(NSString *)name {
	if (!self.savedLayouts[name]) return;
	NSDictionary *layout = self.savedLayouts[name];
	self.hideIconLabels = [layout[@"hideIconLabels"] boolValue];
	self.homescreenColumns = [layout[@"homescreenColumns"] intValue];
	self.homescreenRows = [layout[@"homescreenRows"] intValue];
	self.verticalOffset = [layout[@"verticalOffset"] floatValue];
	self.horizontalOffset = [layout[@"horizontalOffset"] floatValue];
	self.verticalPadding = [layout[@"verticalPadding"] floatValue];
	self.horizontalPadding = [layout[@"horizontalPadding"] floatValue];
	[self relayoutAll];
}

-(void)saveLayoutWithName:(NSString *)name {
	self.savedLayouts[name] = @{
		@"hideIconLabels": @(self.hideIconLabels),
		@"homescreenColumns": @(self.homescreenColumns),
		@"homescreenRows": @(self.homescreenRows),
		@"verticalOffset": @(self.verticalOffset),
		@"horizontalOffset": @(self.horizontalOffset),
		@"verticalPadding": @(self.verticalPadding),
		@"horizontalPadding": @(self.horizontalPadding),
	};
	[self save];
}

-(void)deleteLayoutWithName:(NSString *)name {
	[self.savedLayouts removeObjectForKey:name];
	[self save];
}

-(void)renameLayoutWithName:(NSString *)name toName:(NSString *)newName {
	self.savedLayouts[newName] = self.savedLayouts[name];
	[self.savedLayouts removeObjectForKey:name];
	[self save];
}

-(void)deleteAllLayouts {
	self.savedLayouts = [NSMutableDictionary new];
	[self save];
}

@end