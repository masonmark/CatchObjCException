// CatchObjCException.h　Created by mason on 2015-10-30. Copyright © 2015 mason. All rights reserved.

#import <Foundation/Foundation.h>

/// An Objective-C function that executes `block` using `\@catch` to trap and return any thrown NSException.
///
/// WHY: Although "discouraged" for years, Apple's system frameworks nevertheless throw exceptions in many places. There
/// is no way in Swift code to handle these exceptions; the application will simply crash whenever Foundation or AppKit
/// throws an exception. (It seems inconceivable that Apple would not address this somehow, someday, but it's still true
/// as of Swift 2.1 in October 2015. (Also, I suspect they might address it by fixing the frameworks, not Swift.))
///
/// Therefore, it may not be feasible to write am app in Swift, without some mechanism to deal with cases where
/// the system frameworks throw NSExceptions in normal/routine situations. This implementation doesn't do anything fancy;
/// it aims to be the simplest possible thing that solves this problem. Particularly, it doesn't try to replicate objc's
/// try/catch/finally.
///
/// FIXME: This assumes thrown objects will be NSException instances. Does this need to be updated for weird legacy code
/// that does not-recommended-but-technically-legal-in-ObjC shit like `\@throw "someString"`?
///
/// FIXME: Probably, this has the same ARC memory leak implications as ObjC exception throwing has.

NSException * CatchObjCException(void (^block)());

// EXAMPLE OF HOW TO USE THIS IN SWIFT:
//
//    var freakyResult: Int = -1
//
//    let freakyException = CatchObjCException
//    {
//      freakyResult = doFreakyStuff()
//      // doFreakyStuff() reads and writes to NSFileHandle
//      // objects, launches a bunch of NSTasks, and does a
//      // bunch of KVO stuff, all of which might cause
//      // Foundation to throw exceptions...
//    }
//
//    guard freakyException == nil else
//    {
//      print("oops, exception was thrown: \(freakyException)")
//      self.error = .FreakyError
//      return
//    }
//
//    print("woo hoo, we are this freaky: \(freakyResult)")
