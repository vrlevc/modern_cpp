//
//  smart_pointers_test.m
//  modern_cpp_test
//
//  Created by Viktor Levchenko on 8/1/18.
//  Copyright © 2018 LVA. All rights reserved.
//

#import <XCTest/XCTest.h>

#include <memory>
#include <vector>
#include <unordered_map>
#include <iostream>

// MARK: - uniqe/shared usage

enum class Type { Stock, Bond, Estate };

class Investment {
public:
	virtual ~Investment() = default;
};

class Stock 	 : public Investment {
public:
	Stock() 	{ std::cout << " ->>> new Stock\n"; }
	~Stock()	{ std::cout << " ->>> ~Stock\n"; }
};

class Bond  	 : public Investment {
public:
	Bond() 	{ std::cout << " ->>> new Bond\n"; }
	~Bond()	{ std::cout << " ->>> ~Bond\n"; }
};

class RealEstate : public Investment {
public:
	RealEstate() 	{ std::cout << " ->>> new RealEstate\n"; }
	~RealEstate()	{ std::cout << " ->>> ~RealEstate\n"; }
};

template<typename... _Args>
auto makeInvestment(Type type, _Args&&... __args)
{
	auto delInvmt = [](Investment* pInvestment)
	{
		std::cout << " ->>> delete Investment\n";
		delete pInvestment;
	};
	
	std::unique_ptr<Investment, decltype(delInvmt)> pInv(nullptr, delInvmt);
	
	if ( Type::Stock == type )
		pInv.reset( new Stock( std::forward<_Args>(__args)... ) );
	else if ( Type::Bond == type )
		pInv.reset( new Bond( std::forward<_Args>(__args)... ) );
	else if ( Type::Estate == type )
		pInv.reset( new RealEstate( std::forward<_Args>(__args)... ) );
	
	return pInv;
}

// MARK: - cache loading via weak ptr using

using InvestmentID = int;

std::shared_ptr<Investment> fastCreateInvestment(InvestmentID idx)
{
	static std::unordered_map<InvestmentID, std::weak_ptr<Investment>> cache;
	
	auto objPtr = cache[idx].lock();
	
	if ( !objPtr )
	{
		objPtr = makeInvestment(Type::Bond);
		cache[idx] = objPtr;
	}
	
	return objPtr;
}

// MARK: - enable_shared_from_this

class A;
std::vector<std::shared_ptr<A>> processedObjects;

class A : public std::enable_shared_from_this<A> {
	A() = default;
public:
	~A() { std::cout << " ->>> A::~A()\n"; }
	
	template<typename... Ts>
	static auto create(Ts&&... params)
	{
		std::cout << " ->>> A::create(Ts&&... params)\n";
		return std::shared_ptr<A>( new A(std::forward<Ts>(params)...) );
	}
	
	void process()
	{
		std::cout << " ->>> A::process() -> processedObjects.emplace_back\n";
		processedObjects.emplace_back( shared_from_this() );
	}
};

// MARK: - TESTS

@interface SmartPointers_test : XCTestCase

@end

@implementation SmartPointers_test

- (void)testUniquPtr
{
	std::cout << " ->>> MAKE Investments:\n";
	{
		auto invA = makeInvestment(Type::Stock);
		auto invB = makeInvestment(Type::Bond);
		auto invC = makeInvestment(Type::Estate);
	}
	std::cout << " ->>> DONE Investments:\n";
}

- (void)testSharedPtr
{
	{
		std::shared_ptr<Investment> A, B, C;
		std::cout << " ->>> MAKE Investments:\n";
		{
			std::shared_ptr<Investment> invA = makeInvestment(Type::Stock);
			std::shared_ptr<Investment> invB = makeInvestment(Type::Bond);
			std::shared_ptr<Investment> invC = makeInvestment(Type::Estate);
			
			A = invA;
			B = invB;
			C = invC;
		}
		std::cout << " ->>> DONE Investments\n";
	}
	std::cout << " ->>> DONE External Investments\n";
}

- (void)testSharedThis
{
	{
		std::vector<std::shared_ptr<A>> objects;
		
		std::cout << " ->>> Reatin 10 A ...\n";
		for (int i=0; i<10; ++i)
			objects.emplace_back(A::create());
		
		std::for_each(objects.begin(), objects.end(), [](auto obj){ obj->process(); });
		
		std::cout << " ->>> Release 10 A ...\n";
	}
	
	std::cout << " ->>> for_each processed A ...\n";
	std::for_each(processedObjects.begin(), processedObjects.end(), [](auto obj){ std::cout << (obj ? " ->>> Object\n" : " ->>> NO Object\n"); });
}

- (void)testWeakPtr
{
	std::shared_ptr<Investment> spInv = makeInvestment(Type::Stock);
	XCTAssertEqual(1, spInv.use_count());
	
	std::weak_ptr<Investment> wpInv( spInv );
	XCTAssertEqual(1, spInv.use_count());
	
	spInv = nullptr;
	XCTAssertTrue( wpInv.expired() );		// Non atomic
	
	std::shared_ptr<Investment> spInv1 = wpInv.lock();	// atomic - create shared from weak
	XCTAssertTrue( nullptr == spInv1 );
	
	auto spInv2 = wpInv.lock();
	XCTAssertTrue( nullptr == spInv2 );
	
	try
	{
		std::shared_ptr<Investment>	spInv3(wpInv);	// if wpw's expired, throw std::bad_weak_ptr
	}
	catch (std::bad_weak_ptr ex)
	{
		std::cout << ex.std::exception::what() << std::endl;
	}
	catch (...)
	{
		XCTFail();
	}
}

- (void)testWeakPtr_forCaching
{
	auto inv0 = fastCreateInvestment(0);
	XCTAssertNotEqual(inv0, nullptr);
	XCTAssertEqual(inv0.use_count(), 1);
	
	{
		auto inv1 = fastCreateInvestment(1);
		XCTAssertNotEqual(inv1, nullptr);
		XCTAssertEqual(inv1.use_count(), 1);
	}
	auto inv00 = fastCreateInvestment(0);
	auto inv01 = fastCreateInvestment(1);
	
	XCTAssertNotEqual(inv00, nullptr);
	XCTAssertNotEqual(inv01, nullptr);
	
	XCTAssertEqual(inv0.use_count(), 2);
	XCTAssertEqual(inv00.use_count(), 2);
	XCTAssertEqual(inv01.use_count(), 1);
}

@end








