*2015-11-01*

# CatchObjCException
WHEREAS, apps written in Swift crash when an Objective-C exception is thrown, and

WHEREAS, although developers have been discouraged from the practice of throwing exceptions for many years, both AppKit and Foundation on OS X nevertheless throw exceptions in various places, often in not-especially-exceptional circumstances, and

WHEREAS, Swift 2.1 offers no mechanism whatsoever to handle such exceptions being thrown, and to thereby avoid having your app crash,

NOW, THEREFORE, each of the parties hereto (currently "me", "myself", and "I") agree to seek the simplest possible solution to Not Have My Fucking App Crash Whenever The System Frameworks Decide To Throw An Exception (hereafter "NHMFACWTSFDTTAE").

--

### TL;DR

A Swift app will crash if an exception is thrown, and it isn't caught and dealt with. Therefore, a mechanism to catch and deal with exceptions in a Swift app would be a useful thing. Something like:

    var freakyResult: Int = -1
    
    let freakyException = CatchObjCException
    {
        freakyResult = doFreakyStuff()
          // doFreakyStuff() reads and writes to NSFileHandle
          // objects, launches a bunch of NSTasks, and does a
          // bunch of KVO stuff, all of which might cause
          // Foundation to throw exceptions...
    }
    
    guard freakyException == nil else
    {
      print("oops, exception was thrown: \(freakyException)")
      error = .FreakyError
      return
    }
    
    print("woo hoo, we are this freaky: \(freakyResult)")
    
Unfortunately, Swift 2.1 offers no such mechanism. Moreover, there is no way to write such a mechansim in Swift.

To avoid crashing when the OS frameworks (or you) throw an exception, you must add an Objective-C file to your app, and implement some kind of exception handling in that Objective-C code.

The simplest possible way to do that (that I could think of) is to create a function that takes a generic block as its single parameter. Then, within that function, use normal Objective-C `@try { ... } @catch { ... }` code to stop the exception from bubbling up into Swift-land and crashing your app. Instead, just return the exception. Like this:

	NSException * CatchObjCException(void (^block)())
	{
	  NSException * result = nil;
	  
	  @try
	  {
	    if (block != nil)
	    {
	      block();
	    }
	  }
	  @catch (NSException * e)
	  {
	    result = e;
	  }
	  
	  return result;
	}

The exception will almost always be an instance of `NSException`; the Swift code that receives the returned exception is free to inspect it, ignore it, or do whatever else it needs to.

That's the [gist](https://gist.github.com/masonmark/ea1431df9e8d05385871) of it; the rest of this README is superfluous (but cathartic), and the code in this repo is just an app to run the tests showing that the above code works.

### NHMFACWTSFDTTAE FTW (or, the backstory)

It was a dark and stormy night, and I was writing my very first Swift code -- porting an internal build tool.

This tool is written in Objective-C, and is composed of exactly one class (BuildTool), plus thirteen classes from our shared code base. It's mainly a command line tool (it normally runs as an Xcode build phase), but it also has a simple single-window GUI app for running it manually.

So a port of this small but frequently-used tool seemed like a perfect candidate to become My Little Pony® Baby's First™ Swift App℠. 

At first I was all like, *Ooh, optionals, like nil pointers with benefits*, and then Swift was all like, *Bro, check out my enums on 'roids*, and then I was all like, *Cool, but since you are borrowing all these features from everyone why the fuck didn't you borrow Ruby's `unless` bro,* and then Swift was all like:

    2015-11-02 23:00:24.861 PerversionTool[36480:14811735] *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'launch path not accessible'
    *** First throw call stack:
    (
    0   CoreFoundation                      0x00007fff98233e32 __exceptionPreprocess + 178
    1   libobjc.A.dylib                     0x00007fff911abdd4 objc_exception_throw + 48
    2   CoreFoundation                      0x00007fff9829a65d +[NSException raise:format:] + 205
    3   Foundation                          0x00007fff9616549b -[NSConcreteTask launchWithDictionary:] + 476
    4   PerversionTool                      0x000000010025c502 main + 242
    5   libdyld.dylib                       0x00007fff926fe5ad start + 1
    )
    libc++abi.dylib: terminating with uncaught exception of type NSException

A user-specified path was not valid. The app crashed, which made sense, because I hadn't ported the exception-handling part of the code yet (because I didn't know how).

So, I googled "Swift catch exception", while a background thread in my brain pondered what I would do next, after reading the Stack Overflow post that would undoubtedly be the first search result, and would completely solve my trivial problem.

Whoops! Here is Colin Eberhart [explaining](http://blog.scottlogic.com/2015/01/27/swift-exception-handling.html) how to deal with KVO exceptions in Swift by writing exception-catching shims... in Objective-C. Hmm! Here is Russ Bishop [implementing](http://www.russbishop.net/handle-exceptions-in-swift) a simulacrum of `@try {} @catch {} @finally {}` for Swift... in Objective-C. And William Falcon [doing the same thing](https://medium.com/swift-programming/adding-try-catch-to-swift-71ab27bcb5b8#.kqvwrhge5).

Why on earth would these guys be doing that? It couldn't be that there is no way to catch exceptions in Swift! Swift is the future! And the frameworks throw exceptions!

To paraphrase Michael Tsai on his blog: [um... whut.](http://mjtsai.com/blog/2015/03/12/try/#comment-2402579)

Finally, I found the canonical, definitive statement from Apple in [this sidebar](https://developer.apple.com/library/mac/documentation/Swift/Conceptual/BuildingCocoaApps/AdoptingCocoaDesignPatterns.html#//apple_ref/doc/uid/TP40014216-CH7-NoLink_8) in the book *Using Swift with Cocoa and Objective-C (Swift 2.1)*: 

> "Although Swift error handling resembles exception handling in Objective-C, it is entirely separate functionality. If an Objective-C method throws an exception during runtime, Swift triggers a runtime error. There is no way to recover from Objective-C exceptions directly in Swift. Any exception handling behavior must be implemented in Objective-C code used by Swift."

Well. Perhaps I should have, uh, finished reading that book before starting this Swift port.

Aww... I had wanted to make this little app 100% Swift; that was the whole point of the exercise. But  Nakahara Xcode Build Tool loves it some NSTask, and NSTask, by turn, loves it some `-[NSException raise:]`.

There are other places, too — particularly NSFileHandle and the KVO bits — where the OS X system frameworks throw exceptions in response to routine error conditions, which are not feasible — or sometimes actually impossible — to check for in advance. E.g., writing to a file handle, as Matt Gallagher [mentions here](http://stackoverflow.com/a/24023248/164017).

I could whinge more extensively on this topic, but anyway it is clear (despite a lot of persistent confusion on the interweb tubes) that Swift code cannot handle exceptions. Which leaves only one more question:

### Why the fuck not??

Well, it's probably because even Objective-C (+ Cocoa) doesn't *really* support exceptions either, and Apple wants to say "fuck all this mess" once and for all. 

I've been doing the square brackets boogie for long enough that I remember when we got those nice `@try` and `@catch` keywords to replace the fugly `NS_DURING`/`NS_HANDLER` preprocessor macros. But as I recall, even back then Apple was [telling](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Exceptions/Exceptions.html) developers to confine exception throwing to their own code.

But that's easier said than done, and then once ARC came on the scene, we started [leaking memory by default most of the time we catch an exception](http://clang.llvm.org/docs/AutomaticReferenceCounting.html#exceptions) anyway.

Bill Bumgarner [explains](http://stackoverflow.com/a/4649224/164017) this a bit on Stack Overflow, and notes that "a small number of API" violate Apple's own rule that "exceptions are for non-recoverable errors only", and that they want to fix these inconsistencies.

If you put all that together, I think it might possibly be fair to say that the bug isn't that Swift can't catch exceptions — the bug is that the system frameworks throw exceptions in cases where they shouldn't.

That notwithstanding, though, having **_no mechanism whatsoever_** to trap exceptions thrown by libraries and frameworks seems <strike>insane</strike> rather aspirational. If Apple really wants Swift to be a big-boy language that doesn't need to bring its older brother along in order to write real apps, my first instinct is that they should fix this.

It's not the kind of thing I would personally invest the time to file a bug on, though. (It is, however, apparently the kind of thing about which I would for some reason invest the time write 1220 words about the 146-significant-characters-of-code solution I came up with...)

At least not until I reach the stage where I have a project and CatchObjCException.m is the only Objective-C file I need. And since even in my little build tool port that is only five source code files so far, there has already been another place where I needed to write a C/Obj-C wrapper (for a call to `ioctl()` that Swift couldn't handle) I think that day is probably still pretty far away.

以上

