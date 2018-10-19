//
//  decltype_33_test.m
//  modern_cpp_test
//
//  Created by Viktor Levchenko on 10/19/18.
//  Copyright © 2018 LVA. All rights reserved.
//
//  Item 33: Use decltype on auto&& parameter to std::forward them.

#import <XCTest/XCTest.h>

#include <type_traits>

@interface decltype_33_test : XCTestCase

@end

@implementation decltype_33_test

// MARK: TESTS

- (void)testExample
{
	// Perfect-forward parameter into function
	
	auto f =
		[](auto&& param)
		{
			return func( normalize( std::forward< decltype(param) >(param) ) );
		};
	
	auto F =
		[](auto&&... params)
		{
			return func( normalize( std::forward< decltype(params) >(params)... ) );
		};
}

@end
