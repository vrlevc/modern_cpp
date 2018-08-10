//
//  tuple_test.m
//  modern_cpp_test
//
//  Created by Viktor Levchenko on 8/10/18.
//  Copyright © 2018 LVA. All rights reserved.
//

#import <XCTest/XCTest.h>
#include <tuple>
#include <string>
#include <type_traits>

// MARK: - DATA

enum ATTR { GPA = 0, GRADE = 1, NAME = 2 };
std::tuple<double, char, std::string> getStudent(int id) noexcept(false)
{
	switch (id)
	{
		case 1:
			return {3.8, 'A', "Lisa Simpson"};
		case 2:
			return {2.9, 'B', "Olga Levchenko"};
		case 3:
			return {1.7, 'C', "Doom Star"};
	}
	throw std::invalid_argument("id");
}

enum class Attr : std::int32_t { GPA, GRADE, NAME };

template<typename E>
constexpr auto toUType(E e) {							// !!! MUST BE CONSTEXPR for std::get<...>()
	return static_cast<std::underlying_type_t<E>>(e);
}

// MARK: - TEST

@interface tuple_test : XCTestCase
@end

@implementation tuple_test

- (void)testTuple
{
	auto student1 = getStudent(1);
	
	XCTAssertEqual( 		  3.8, std::get<GPA>  (student1) );
	XCTAssertEqual( 		  'A', std::get<GRADE>(student1) );
	XCTAssertEqual("Lisa Simpson", std::get<NAME> (student1) );

	XCTAssertEqual( 		  3.8, std::get<toUType(Attr::GPA)  > (student1) );
	XCTAssertEqual( 		  'A', std::get<toUType(Attr::GRADE)> (student1) );
	XCTAssertEqual("Lisa Simpson", std::get<toUType(Attr::NAME) > (student1) );
	
	double gpa2;
	char grade2;
	std::string name2;
	std::tie(gpa2, grade2, name2) = getStudent(2);
	
	XCTAssertEqual( 		    2.9, gpa2   );
	XCTAssertEqual( 		    'B', grade2 );
	XCTAssertEqual("Olga Levchenko", name2  );

	auto [gpa3, grade3, name3] = getStudent(3);
	
	XCTAssertEqual( 	   1.7, gpa3   );
	XCTAssertEqual( 	   'C', grade3 );
	XCTAssertEqual("Doom Star", name3  );
}

@end















































