//
//  closure_32_test.m
//  modern_cpp_test
//
//  Created by Viktor Levchenko on 10/18/18.
//  Copyright © 2018 LVA. All rights reserved.
//
//  Item 32: Use init capture to move object into closures.

#import <XCTest/XCTest.h>

#include <memory>
#include <vector>
#include <functional>

// MARK: Widget

/**
 *  - Move only object like std::unique_ptr or std::feature
 *  - Expencive to copy but cheap to move
 */
class Widget
{
public:
	bool isValidated() const { return true; }
	bool isArchived () const { return true; }
};

//---------------------------------------------------

@interface closure_32_test : XCTestCase

@end

@implementation closure_32_test

// MARK: - TESTS

- (void)testInitClosure
{
	// Create move only or cheap moving object
	auto pw = std::make_unique<Widget>();
	
	// configure pw ...
	
	auto funcA = [pw = std::move(pw)]  // init data mbr in closure w = std::move(pw)
				 { return pw->isValidated() && pw->isArchived(); };
	
	// Note: "pw = std::move(pw)" means "create a data member pw in the closure, and initialize
	//       that data member with the result of applaying std::move to the local variable pw"
	
	auto funcB = [pw = std::make_unique<Widget>()] // do not need to configure widget object
				 { return pw->isValidated() && pw->isArchived(); };
	
	auto funcC11 =
		std::bind(
			[](const std::unique_ptr<Widget>& pw)
			{ return pw->isValidated() && pw->isArchived(); },
			std::make_unique<Widget>()
		);
}

- (void)testC14vsC11
{
	std::vector<double> dataA; // object to be moved into closure
	std::vector<double> dataB; // object to be moved into closure
	std::vector<double> dataC; // object to be moved into closure

	// ... populate data ...
	
	auto funcC14 = [data = std::move(dataA)]	// C++14 init capture
				   {  /* use of data */ };
	
	auto funcC11 =
		std::bind(
			[](const std::vector<double>& data)	// C++11 emulation of init capture
			{ /* use of data */ },
			std::move(dataB)
		);
	
	// Omit const by mutable
	auto funcbC11 =
		std::bind(
			[](std::vector<double>& data) mutable // C++11 emulation of init capture
			{ /* use of data */ },
			std::move(dataB)
		);
	
}


@end





















