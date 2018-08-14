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
#include <deque>

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

// C++17 - support lvalue and rvalue as a paramenter for container!
template<typename Container, typename Index>
auto handleAndAccess(Container&& c, Index i)
{
	// handle();
	return std::forward<Container>(c)[i] ;
}

// Helper
template<typename T> class TD;

std::deque<int> makeContainer()
{
	std::deque<int> d;
	d.push_back(10);
	d.push_back(20);
	d.push_back(30);
	d.push_back(40);
	d.push_back(50);
	d.push_back(60);
	return d;
}

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
	NSLog(@"--- decltype ---");
	NSLog(@"---  WRONG   ---");
	
//	TD< decltype(getStringDecltypeReference()) > Fn;
	XCTAssertEqual( true, std::is_reference_v< decltype(getStringDecltypeReference()) > );
	NSLog(@" ->>> TD< decltype(getStringDecltypeReference()) > Fn;  => TD<std::string<char> &> - REFERENCE : ERROR!!!");
	
//	TD< decltype(getStringDecltypeCopy()) > Fn;
	XCTAssertEqual( false, std::is_reference_v< decltype(getStringDecltypeCopy()) > );
	XCTAssertEqual( true,  std::is_object_v< decltype(getStringDecltypeCopy()) >);
	NSLog(@" ->>> TD< decltype(getStringDecltypeCopy()) > Fn;  => TD<std::string<char> &> - COPY : GOOD");

//	TD< decltype(getStringAutoCopyA()) > Fn;
	XCTAssertEqual( false, std::is_reference_v< decltype(getStringAutoCopyA()) > );
	XCTAssertEqual( true,  std::is_object_v< decltype(getStringAutoCopyA()) >);
	NSLog(@" ->>> TD< decltype(getStringAutoCopyA()) > Fn;  => TD<std::string<char> &> - COPY : GOOD");
	
//	TD< decltype(getStringAutoCopyB()) > Fn;
	XCTAssertEqual( false, std::is_reference_v< decltype(getStringAutoCopyB()) > );
	XCTAssertEqual( true,  std::is_object_v< decltype(getStringAutoCopyB()) >);
	NSLog(@" ->>> TD< decltype(getStringAutoCopyB()) > Fn;  => TD<std::string<char> &> - COPY : GOOD");
}

- (void)testDecltype
{
	NSLog(@"--- decltype ---");
	NSLog(@"---   GOOD   ---");

	std::deque<int> d;	// l-value
	d.push_back(10);
	d.push_back(20);
	d.push_back(30);
	d.push_back(40);
	d.push_back(50);
	d.push_back(60);
	
	// TEST - l-value
	
	XCTAssertEqual( true, std::is_reference_v< decltype( processAndAccess(d, 2) ) > );
	XCTAssertEqual( true, std::is_reference_v< decltype( workAndAccess(d, 3) ) > );
	XCTAssertEqual( true, std::is_reference_v< decltype( workAndAccess(d, 4) ) > );
	
	XCTAssertEqual(30, d[2]);
	processAndAccess(d, 2) = 15;
	XCTAssertEqual(15, d[2]);
	
	XCTAssertEqual(40, d[3]);
	workAndAccess(d, 3) = 25;
	XCTAssertEqual(25, d[3]);

	XCTAssertEqual(50, d[4]);
	workAndAccess(d, 4) = 35;
	XCTAssertEqual(35, d[4]);

	// TEST - r-value
	
	auto a = processAndAccess(makeContainer(), 2);
	auto b = workAndAccess(makeContainer(), 3);
	auto c = handleAndAccess(makeContainer(), 4);
	
	XCTAssertEqual( true, std::is_object_v< decltype( a ) > );
	XCTAssertEqual( true, std::is_object_v< decltype( b ) > );
	XCTAssertEqual( true, std::is_object_v< decltype( c ) > );
	
	XCTAssertEqual(30, a);
	XCTAssertEqual(40, b);
	XCTAssertEqual(50, c);
	
	a = 25;
	b = 35;
	c = 45;
	
	XCTAssertEqual(25, a);
	XCTAssertEqual(35, b);
	XCTAssertEqual(45, c);
}

@end




































