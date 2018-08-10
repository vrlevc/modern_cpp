//
//  auto_test.m
//  modern_cpp_test
//
//  Created by Viktor Levchenko on 8/10/18.
//  Copyright © 2018 LVA. All rights reserved.
//

#import <XCTest/XCTest.h>
#include <initializer_list>
#include <string>

// MARK: - TEST

@interface auto_test : XCTestCase
@end

@implementation auto_test

- (void)testAuto
{
	auto x = 27;
	const auto cx = x;
	const auto& rx = x;
	
	XCTAssertEqual(27, x);
	XCTAssertEqual(27, cx);
	XCTAssertEqual(27, rx);
	
	auto&& uref1 = x;	// x is int and lvalue => uref1 is int&
	auto&& uref2 = cx;  // cx is const int and lvalue => uref2 is const int&
	auto&& uref3 = 27;	// 27 is int and rvalue => uref3 is int&&
	
	XCTAssertEqual(27, uref1);
	XCTAssertEqual(27, uref2);
	XCTAssertEqual(27, uref3);
	
	const char name[] = "R. N. Briggs";
	auto  arr1 = name; 	// arr1 is const char*
	auto& arr2 = name; 	// arr2 is const char (&)[13]
	
	XCTAssertEqual("R. N. Briggs", std::string(arr1));
	XCTAssertEqual("R. N. Briggs", std::string(arr2));
	
	auto x1 = 27;		// type is int, value is 27
	auto x2(27);		// type is int, value is 27
	auto x3 = { 27 };	// type is std::initializer_list<int>
	auto x4{ 27 };		// type is std::initializer_list<int>
	
	XCTAssertEqual( 27, x1 );
	XCTAssertEqual( 27, x2 );
}

@end































