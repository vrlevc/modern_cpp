//
//  type_test.m
//  modern_cpp_test
//
//  Created by Viktor Levchenko on 8/14/18.
//  Copyright © 2018 LVA. All rights reserved.
//

#import <XCTest/XCTest.h>

template<typename T>
class TD;

@interface type_test : XCTestCase

@end

@implementation type_test

- (void)testType
{
	const int theAnswer = 42;
	auto x =  theAnswer;
	auto y = &theAnswer;
	XCTAssertEqual(42, x);
	XCTAssertTrue(nullptr != y);
	
	int array[] = { 1, 2, 3, 4, 5 };
	NSLog(@" ->>> int array[] = { 1, 2, 3, 4, 5 }");
	
	auto  xs = array;  NSLog(@" ->>> auto  xs = array; => TD<int *>");
	auto& ys = array;  NSLog(@" ->>> auto& ys = array; => TD<int (&)[5]>");
	
	// Show type of x in error message!!!!
	
//	TD< decltype(x) > xType;
//	TD< decltype(y) > yType;

//	TD< decltype(xs) > xsType;
//	TD< decltype(ys) > ysType;
	
}

@end

























