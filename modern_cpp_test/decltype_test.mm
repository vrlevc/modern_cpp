//
//  decltype_test.m
//  modern_cpp_test
//
//  Created by Viktor Levchenko on 8/14/18.
//  Copyright © 2018 LVA. All rights reserved.
//

#import <XCTest/XCTest.h>
#include <type_traits>
#include <string>

// MARK: -

// C++11 - support lvalue and rvalue as a paramenter for container!
template<typename Container, typename Index>
auto processAndAccess(Container&& c, Index i) -> decltype(c[i])
{
	// process();
	return std::forward<Container>(c)[i];
}

// C++14 - support lvalue and rvalue as a paramenter for container!
template<typename Container, typename Index>
decltype(auto) workAndAccess(Container&& c, Index i)
{
	// work();
	return std::forward<Container>(c)[i] ;
}

// C++17 - do not need to add decltype
template<typename Container, typename Index>
auto handleAndAccess(Container&& c, Index i)
{
	// work();
	return std::forward<Container>(c)[i] ;
}

// Helper
template<typename T> class TD;

// **************!!!**************
decltype(auto) getStringDecltypeReference()
{
	std::string string = "Just a good string";
	return (string);	// return refence and delete internal data!!!
}

decltype(auto) getStringDecltypeCopy()
{
	std::string string = "Just a good string";
	return string;	// return copy
}

auto getStringAutoCopyA()
{
	std::string string = "Just a good string";
	return (string);	// return copy
}

auto getStringAutoCopyB()
{
	std::string string = "Just a good string";
	return string;	// return copy
}


// MARK: - TEST

@interface decltype_test : XCTestCase
@end

@implementation decltype_test

// **************!!!**************
- (void)testErrorUsage
{
//	TD< decltype(getStringDecltypeReference()) > Fn;
	XCTAssertEqual( true, std::is_reference_v< decltype(getStringDecltypeReference()) > );
	NSLog(@" ->>> TD< decltype(getStringDecltypeReference()) > Fn;  => TD<std::string<char> &> - REFERENCE : ERROR!!!");
	
//	TD< decltype(getStringDecltypeCopy()) > Fn;
	XCTAssertEqual( false, std::is_reference_v< decltype(getStringDecltypeCopy()) > );
	NSLog(@" ->>> TD< decltype(getStringDecltypeCopy()) > Fn;  => TD<std::string<char> &> - COPY : GOOD");

//	TD< decltype(getStringAutoCopyA()) > Fn;
	XCTAssertEqual( false, std::is_reference_v< decltype(getStringAutoCopyA()) > );
	NSLog(@" ->>> TD< decltype(getStringAutoCopyA()) > Fn;  => TD<std::string<char> &> - COPY : GOOD");
	
//	TD< decltype(getStringAutoCopyB()) > Fn;
	XCTAssertEqual( false, std::is_reference_v< decltype(getStringAutoCopyB()) > );
	NSLog(@" ->>> TD< decltype(getStringAutoCopyB()) > Fn;  => TD<std::string<char> &> - COPY : GOOD");
}

- (void)testExample
{
	
}

@end



























