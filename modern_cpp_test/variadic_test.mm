//
//  variadic_test.m
//  modern_cpp_test
//
//  Created by Viktor Levchenko on 8/15/18.
//  Copyright © 2018 LVA. All rights reserved.
//

#import <XCTest/XCTest.h>
#include <iostream>
#include <string>
#include <vector>

// MARK: - DATA

// Function wrapper:

template<typename F, typename... Ts>
decltype(auto) logAndCall( F& f, Ts&&... args )
{
	std::cout << "--------------\n";
	auto ret = f(std::forward<Ts>(args)...);
	std::cout << "==============\n";
	return ret;
}

static std::string getString(const char * text, bool print);
static std::vector<float> getTemperature(int t0ID, int t1ID, int t2ID, double epsilon, bool fromCatche);

// Try move ctor
class A
{
public:
	A() { std::cout << "A()\n"; }
	A(A&& a) { std::cout << "move CTOR !!!!\n"; }
	
	template<typename T>
	static T GET() {
		T a;
		return std::forward<T>(a);
	}
};

template<typename T>
T foo(T&& a) {
	return std::forward<T>(a);
}

// Safe object creation
class Object {};
class Car : public Object {};
class Driver : public Object {
	std::unique_ptr<Car> car;
public:
	bool SetUp(int id, std::string&& name) { return false; }
};

template<typename T, bool V, typename...Ts>
auto CreateDriver(int carId, Ts...args)
{
	auto driver = std::make_unique<T>();
	if ( !driver->SetUp(std::forward<Ts>(args)..., V ? "vitya" : "olga") )
		driver = nullptr;
	return driver;
}


// MARK: - TEST

@interface variadic_test : XCTestCase
@end

@implementation variadic_test

- (void)testVariadic
{
	
	std::cout << "<<< variadicTemplatesMAIN >>>\n";
	
	auto driver = CreateDriver<Driver, true>(55, 22);
	
	//	TD< decltype(getString) > getString_TYPE;
	//	TD< decltype(getTemperature) > getTemperature_TYPE;
	
	auto s0 = logAndCall( getString, "Just a good string!!!", true);
	std::cout << "s0 = " << s0 << std::endl;
	auto s1 = logAndCall( getString, "Just a good string!!!", false);
	std::cout << "s1 = " << s1 << std::endl;
	
	std::cout << "--- MOVE ??? ---\n";
	A aa = logAndCall( foo<A>, A::GET<A>() );
	
	std::cout << "--- MOVE ??? ---\n";
	
}

@end


std::string getString(const char * text, bool print)
{
	std::string ret = text;
	if (print) std::cout << "String is a : " << ret << std::endl;
	return ret;
}

static std::vector<float> getTemperature(int t0ID, int t1ID, int t2ID, double epsilon, bool fromCatche)
{
	std::vector<float> ret = { float(epsilon+t0ID), float(epsilon+t1ID), float(epsilon+t2ID) };
	if (fromCatche) std::cout << "Array with values from catche" << std::endl;
	return ret;
}




















