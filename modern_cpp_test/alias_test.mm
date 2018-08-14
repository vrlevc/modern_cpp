//
//  alias_test.m
//  modern_cpp_test
//
//  Created by Viktor Levchenko on 8/14/18.
//  Copyright © 2018 LVA. All rights reserved.
//

#import <XCTest/XCTest.h>
#include <list>

// MARK: - TYPES

// c++98
template<typename Page>
struct Book98 {
	typedef std::list<Page> type;
};

// c++11
template<typename Page>
using Book11 = std::list<Page>;

// Usage
template<typename Page>
class AnatomyISO
{
	typename Book98<Page>::type	iso98;	// c++98
	Book11<Page>				iso11;	// c++11
};

// MARK: - TEST

@interface alias_test : XCTestCase
@end

@implementation alias_test

- (void)testExample
{
	Book98<int>::type	iso98;	// c++98  == std::list<int>
	Book11<int>			iso11;  // c++11  == std::list<int>
	
	AnatomyISO<int>		iso;
}

@end




























