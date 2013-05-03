//
//  Folder.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PYFolder;

@interface Folder : NSObject

@property (nonatomic, strong) NSString *folderName;
@property (nonatomic, strong) NSString *folderId;

- (id)initWithPYFolder:(PYFolder*)pyFolder;

@end
