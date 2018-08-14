//
//  sfinae_test.m
//  modern_cpp_test
//
//  Created by Viktor Levchenko on 8/2/18.
//  Copyright © 2018 LVA. All rights reserved.
//

#import <XCTest/XCTest.h>

#include <type_traits>
#include <string>
#include <iostream>

using namespace std;

constexpr bool INTEGRAL = true;
constexpr bool OBJECT   = false;

bool fooImpl( int v, true_type ) // integral
{
	cout << "foo - INTEGRAL\n";
	return INTEGRAL;
}

template<typename T>
bool fooImpl( T&& v, false_type ) // others
{
	cout << "foo - OBJECT\n";
	return OBJECT;
}

template<typename T>
bool foo(T&& v)
{
	// Dispatch to correct one
	return fooImpl( forward<T>(v), is_integral< remove_reference_t<T> >() );
}

class Person : public string
{
public:
	template<
		typename T,
		typename  =
			enable_if_t<
				!is_integral_v<remove_reference_t<T>> ||
				is_base_of_v<string, decay_t<T>>
		>
	>
	explicit Person(T&& v) : string(forward<T>(v)) { cout << *this << endl; }
	
	explicit Person(int i) : string( nameByID(i) ) { cout << *this << endl; }
private:
	string nameByID(int i) { return "name by ID"; }
};

// MARK:- TESTS

@interface sfinae_test : XCTestCase
- (void)startTestWithName:(NSString*)theName;
@end

@implementation sfinae_test

- (void)setUp
{
	[super setUp];
	cout << "--------------------------------------------------------\n";
}

- (void)tearDown
{
	cout << "--------------------------------------------------------\n";
}

- (void)startTestWithName:(NSString*)theName
{
	cout << " ->>> " << theName.UTF8String << " <<<-" << endl << endl;
}

- (void)testPerson
{
	[self startTestWithName:@"test : Person"];
	
	Person fromStringA("vitya");
	XCTAssertTrue(fromStringA == "vitya");
	
	Person fromStringB(string("olga"));
	XCTAssertTrue(fromStringB == "olga");
	
	Person fromIntegerA((short)10);
	XCTAssertTrue(fromIntegerA == "name by ID");
	
	Person fromIntegerB(10);
	XCTAssertTrue(fromIntegerB == "name by ID");
	
	Person fromIntegerC(10L);
	XCTAssertTrue(fromIntegerC == "name by ID");
}

- (void)test_function
{
	[self startTestWithName:@"test : Function"];
	
	std::string s("AAAA");
	auto  id = 10;
	short idx = 5;
	
	XCTAssertEqual(INTEGRAL, foo( 10 ) );
	XCTAssertEqual(OBJECT,   foo( s )  );
	XCTAssertEqual(INTEGRAL, foo( id ) );
	XCTAssertEqual(INTEGRAL, foo( idx ));
	XCTAssertEqual(OBJECT,   foo( "aa"));
}


@end
