//
//  constexpr_test.m
//  modern_cpp_test
//
//  Created by Viktor Levchenko on 8/1/18.
//  Copyright © 2018 LVA. All rights reserved.
//

#import <XCTest/XCTest.h>

#include <type_traits>
#include <array>
#include <iostream>
#include <stdio.h>

// C++14
constexpr int pow14(int base, int exp) noexcept
{
	auto result = 1;
	for (int i=0; i<exp; ++i) result *= base;
		return result;
}

class Pos
{
public:
	constexpr Pos(double xVal = 0, double yVal = 0) noexcept : x(xVal), y(yVal) {}
	constexpr double xValue() const noexcept { return x; }
	constexpr double yValue() const noexcept { return y; }
	constexpr void setX(double newX) noexcept { x = newX; }
	constexpr void setY(double newY) noexcept { y = newY; }
private:
	double x, y;
};

constexpr Pos midpoint(const Pos& p1, const Pos& p2) noexcept
{
	return { (p1.xValue() + p1.xValue()) / 2,
		(p1.yValue() + p1.yValue()) / 2 };
}

constexpr Pos reflection(const Pos& p) noexcept
{
	Pos result;
	result.setX(-p.xValue());
	result.setY(-p.yValue());
	return result;
}

template<typename T, std::size_t N>
constexpr std::size_t arraySize( T (&)[N] ) // ! by reference !
{
	return N;
}

// MARK:- TESTS

@interface constexpr_test : XCTestCase
@end

@implementation constexpr_test

- (void)testArraySize
{
	NSLog(@" ->>> Define c array size in compile time");
	
	int keys[] = { 1, 3, 5, 7, 9, 11, 13 };
	std::array<int, arraySize(keys)> values;
	
	XCTAssertEqual(sizeof(keys)/sizeof(int), values.size());
	
	NSLog(@" ->>> The size of c array is %lu", sizeof(keys)/sizeof(int));
	NSLog(@" ->>> The size of values array is %zu", values.size());
}

- (void)testPos
{
	constexpr auto accuracy = 0.000'001;
	
	constexpr Pos p1(10.0, 20.0);
	constexpr Pos p2(20.8, 10.3);
	
	constexpr auto mid = midpoint(p1, p2);
	constexpr auto ref = reflection(mid);
	
	XCTAssertNotEqualWithAccuracy(mid.xValue(), 15.0, accuracy);
	XCTAssertNotEqualWithAccuracy(mid.yValue(), 15.0, accuracy);
	
	XCTAssertNotEqualWithAccuracy(ref.xValue(), 15.0, accuracy);
	XCTAssertNotEqualWithAccuracy(ref.yValue(), 15.0, accuracy);
}

- (void)testPow
{
	constexpr int b = pow14(2, 3);
	std::array<int, b> B1;
	std::array<int, pow14(2, 3)> B2;
	std::cout << "B1.size() : " << B1.size() << std::endl;
	std::cout << "B2.size() : " << B2.size() << std::endl;
	
	XCTAssertEqual(b, pow14(2, 3));
	XCTAssertEqual(b, B1.size());
	XCTAssertEqual(pow14(2, 3), B2.size());
}

@end

