// CatchObjCException.m　Created by mason on 2015-10-30. Copyright © 2015 mason. All rights reserved.

#import "CatchObjCException.h"

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
