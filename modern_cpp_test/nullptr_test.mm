//
//  nullptr_test.m
//  modern_cpp_test
//
//  Created by Viktor Levchenko on 8/13/18.
//  Copyright © 2018 LVA. All rights reserved.
//

#import <XCTest/XCTest.h>
#include <memory>
#include <mutex>

// MARK:- DATA
enum class PARAM { integer, boolean, pointer };
PARAM f(int)   { return PARAM::integer; }
PARAM f(bool)  { return PARAM::boolean; }
PARAM f(void*) { return PARAM::pointer; }
void* g() { return nullptr; }

// MARK: -
class Widget {};
enum class PTR { shared, unique, raw };
PTR f1(std::shared_ptr<Widget> spw) {return PTR::shared;} // call these only when
PTR f2(std::unique_ptr<Widget> upw) {return PTR::unique;} // the appropriate
PTR f3(Widget* pw)					{return PTR::raw;}    // mutex is locked

using MuxGuard = std::lock_guard<std::mutex>;
template<typename Fnc, typename Mux, typename Ptr>
auto safeCall( Fnc fnc, Mux& mux, Ptr ptr ) {
	MuxGuard guard(mux);
	return fnc( ptr );
}

// MARK:- TEST

@interface nullptr_test : XCTestCase

@end

@implementation nullptr_test

- (void)testOverloadedFunc
{
	XCTAssertEqual(PARAM::integer, f(0));
//	f(NULL);		ambigous!!!
	XCTAssertEqual(PARAM::pointer, f(nullptr));
	
	auto res = g();
	XCTAssertTrue(res == 0);
	XCTAssertTrue(res == NULL);
	XCTAssertTrue(res == nullptr);
}

- (void) testGuarderNullptr
{
	std::mutex f1m, f2m, f3m;	// mutexes for f1, f2, and f3
	
	{
		MuxGuard g(f1m);
		XCTAssertEqual(PTR::shared, f1(0));		  // pass 0 as null ptr to f1 : works but is sad
		XCTAssertEqual(PTR::shared, f1(NULL)); 	  // pass NULL as null ptr to f1 : works but is sad
		XCTAssertEqual(PTR::shared, f1(nullptr)); // pass nullptr as null ptr to f1 : GOOD !!!
	}
	{
		MuxGuard g(f2m);
		XCTAssertEqual(PTR::unique, f2(0));		  // pass 0 as null ptr to f1 : works but is sad
		XCTAssertEqual(PTR::unique, f2(NULL)); 	  // pass NULL as null ptr to f1 : works but is sad
		XCTAssertEqual(PTR::unique, f2(nullptr)); // pass nullptr as null ptr to f1 : GOOD !!!
	}
	{
		MuxGuard g(f3m);
		XCTAssertEqual(PTR::raw, f3(0));		  // pass 0 as null ptr to f1 : works but is sad
		XCTAssertEqual(PTR::raw, f3(NULL)); 	  // pass NULL as null ptr to f1 : works but is sad
		XCTAssertEqual(PTR::raw, f3(nullptr)); 	  // pass nullptr as null ptr to f1 : GOOD !!!
	}
	
	// Use safeCall for
	// 1. Remove DUPLICATION CODE
	// 2. Do not allow pass 0 or NULL - only nullptr
	
//	XCTAssertEqual(PTR::shared, safeCall( f1, f1m, 0 ) );			// ERROR!!!
//	XCTAssertEqual(PTR::shared, safeCall( f1, f1m, NULL ) );		// ERROR!!!
	XCTAssertEqual(PTR::shared, safeCall( f1, f1m, nullptr ) );
	
//	XCTAssertEqual(PTR::unique, safeCall( f2, f2m, 0 ) );			// ERROR!!!
//	XCTAssertEqual(PTR::unique, safeCall( f2, f2m, NULL ) );		// ERROR!!!
	XCTAssertEqual(PTR::unique, safeCall( f2, f2m, nullptr ) );

//	XCTAssertEqual(PTR::raw, safeCall( f3, f3m, 0 ) );				// ERROR!!!
//	XCTAssertEqual(PTR::raw, safeCall( f3, f3m, NULL ) );			// ERROR!!!
	XCTAssertEqual(PTR::raw, safeCall( f3, f3m, nullptr ) );

}

@end




































