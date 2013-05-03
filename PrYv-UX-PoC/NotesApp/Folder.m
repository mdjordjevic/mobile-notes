//
//  Folder.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "Folder.h"
#import <PryvApiKit/PryvApiKit.h>

@implementation Folder

- (id)initWithPYFolder:(PYFolder *)pyFolder {
    self = [super init];
    if(self) {
        self.folderName = [[pyFolder name] copy];
        self.folderId = [[pyFolder folderId] copy];
    }
    return self;
}

@end
