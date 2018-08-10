//
//  enum_test.m
//  modern_cpp_test
//
//  Created by Viktor Levchenko on 8/10/18.
//  Copyright © 2018 LVA. All rights reserved.
//

#import <XCTest/XCTest.h>
#include <type_traits>
#include <string>
#include <tuple>

// MARK: - DATA

template<typename E>
constexpr auto toUType( E e ) noexcept {
	return static_cast<std::underlying_type_t<E>>(e);
}

// MARK: - TEST

@interface enum_test : XCTestCase

@end

@implementation enum_test

- (void)testExample
{
	enum class Color : short
	{
		black, white, red
	};
	
	Color ec = Color::white;
	auto  ac = Color::white;
	
	// declaration
	
	enum unscopedEnum : int;
	enum class scopedEnum : int;
	
	// Use scoped enum with cast:
	
	enum class ATTR { ID, SEX, NAME, MAIL };
	
	using STUDENT = std::tuple<int, char, std::string, std::string>;
	STUDENT a { 111, 'M', "Vitya", "vitya@google.com" };
	STUDENT b { 222, 'F', "Olga" , "olga@google.com"  };
	
	auto name  = std::get< toUType(ATTR::NAME) >( a );
	auto mail  = std::get< toUType(ATTR::MAIL) >( b );
	auto index = std::get< toUType(ATTR::ID  ) >( a );
}

@end
























































