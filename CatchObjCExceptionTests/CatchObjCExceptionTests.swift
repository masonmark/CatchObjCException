// CatchObjCExceptionTests.swift Created by mason on 2015-10-31. Copyright © 2015 mason. All rights reserved.

import XCTest

class CatchObjCExceptionTests: XCTestCase
{
  
  func test_catch_exception_thrown()
  {
    let t = NSTask()
    t.launchPath = "/nope/bogus/launch/path/will/cause/exception"
    
    let thrownException = CatchObjCException
    {
      t.launch()
    }
    
    XCTAssertNotNil(thrownException)
    XCTAssertTrue(thrownException.isKindOfClass(NSException))
    XCTAssertEqual(thrownException.name, "NSInvalidArgumentException")
    XCTAssertEqual(thrownException.reason, "launch path not accessible")
  }
  
  
  func test_do_nothing_when_exception_not_thrown()
  {
    let t = NSTask()
    t.launchPath = "/bin/ls"
    //exists, so won't throw exception on launch
    
    var didWork = false
    let thrownException = CatchObjCException
    {
      t.launch()
      didWork = true
    }
    
    XCTAssertNil(thrownException)
    XCTAssertTrue(didWork)
  }
  
  
  func test_typical_usage_example()
  {
    let twoElementArray = [0,1] as NSArray
    
    let exception = CatchObjCException
    {
      let foo = twoElementArray.objectAtIndex(8675309)
      print("This line won't execute because an objc exception was thrown above, so we never get here...\(foo)")
    }
    
    guard exception == nil else
    {
      // Do whatever is necessary in response to the exception...
      return
    }
    
    XCTFail("Exception should have occurred, and the guard statement above should have excuted. ")
  }
  
  
  func test_just_ignore_exceptions_example()
  {
    var result = "The freedom of birds is an insult to me..."
    
    CatchObjCException
    {
      let theWord = result as NSString
      
      result += "OK, gonna do something that throws an exception..."
      
      theWord.addObserver(self, forKeyPath: "yourMom", options: .Initial, context: nil)
      
      result += ("This line won't execute because an objc exception was thrown above, so we never get here...")
    }
    
    result += ("All done!")
    
    XCTAssertEqual(result, "The freedom of birds is an insult to me...OK, gonna do something that throws an exception...All done!")
  }
  
  
  func test_readme_example_compiles_and_works()
  {
    func doFreakyStuff() -> Int
    {
      self.addObserver(self, forKeyPath: "blartblart", options: .Initial, context: nil)
      return 666
    }
    
    enum FreakyError : ErrorType { case FreakyError, NoError }
    
    var error : FreakyError?
    
    // BEGIN EXAMPLE +++++++++++++++++++++++++++++++++++++++
    
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

    // END EXAMPLE +++++++++++++++++++++++++++++++++++++++
    print("avoid 'written to but never read' error by printing this:", error)
    XCTFail("We should not have ever gotten here.")
  }
  
}
